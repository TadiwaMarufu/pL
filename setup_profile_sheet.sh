#!/bin/bash
set -e

PROFILE_DIR="app/src/main/java/com/purple/launcher/profile/presentation"
MAIN_PRES_DIR="app/src/main/java/com/purple/launcher/launcher/presentation"

mkdir -p ${PROFILE_DIR}

# 1. Profile Selector Bottom Sheet Composable
cat << 'KOTLIN' > ${PROFILE_DIR}/ProfileSelectorSheet.kt
package com.purple.launcher.profile.presentation

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.purple.launcher.profile.domain.LauncherProfile

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProfileSelectorSheet(
    activeProfile: LauncherProfile,
    profiles: List<LauncherProfile>,
    onProfileSelect: (LauncherProfile) -> Unit,
    onDismiss: () -> Unit
) {
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = Color(0xFF1E1E24),
        scrimColor = Color.Black.copy(alpha = 0.6f)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(24.dp)
        ) {
            Text(
                text = "Switch Profile Context",
                color = Color.White,
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold
            )
            Spacer(modifier = Modifier.height(16.dp))

            profiles.forEach { profile ->
                val isSelected = profile.id == activeProfile.id
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 6.dp)
                        .clip(RoundedCornerShape)
                        .background(
                            if (isSelected) Color.Magenta.copy(alpha = 0.25f)
                            else Color.White.copy(alpha = 0.05f)
                        )
                        .clickable {
                            onProfileSelect(profile)
                            onDismiss()
                        }
                        .padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Column {
                        Text(
                            text = profile.name,
                            color = Color.White,
                            fontSize = 16.sp,
                            fontWeight = FontWeight.SemiBold
                        )
                        Text(
                            text = profile.description,
                            color = Color.Gray,
                            fontSize = 12.sp
                        )
                    }
                    if (isSelected) {
                        Text(text = "✓", color = Color.Magenta, fontSize = 18.sp, fontWeight = FontWeight.Bold)
                    }
                }
            }
            Spacer(modifier = Modifier.height(32.dp))
        }
    }
}
KOTLIN

# 2. Wire Profile Engine into MainActivity
cat << 'KOTLIN' > ${MAIN_PRES_DIR}/MainActivity.kt
package com.purple.launcher.launcher.presentation

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Surface
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.purple.launcher.apps.domain.AppModel
import com.purple.launcher.apps.domain.CategoryGroup
import com.purple.launcher.apps.engine.AppDiscoveryEngine
import com.purple.launcher.apps.presentation.AppDrawerSurface
import com.purple.launcher.nowbar.NowBarEngine
import com.purple.launcher.nowbar.NowBarSurface
import com.purple.launcher.profile.engine.ProfileEngine
import com.purple.launcher.profile.presentation.ProfileSelectorSheet
import com.purple.launcher.search.domain.SearchResult
import com.purple.launcher.search.engine.SearchEngine
import com.purple.launcher.search.presentation.SearchOverlay
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    @Inject lateinit var nowBarEngine: NowBarEngine
    @Inject lateinit var appDiscoveryEngine: AppDiscoveryEngine
    @Inject lateinit var searchEngine: SearchEngine
    @Inject lateinit var profileEngine: ProfileEngine

    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
        setContent {
            val nowBarState by nowBarEngine.nowBarState.collectAsState()
            val categories by appDiscoveryEngine.categorizedApps.collectAsState()
            val searchState by searchEngine.searchState.collectAsState()
            val activeProfile by profileEngine.activeProfile.collectAsState()
            val availableProfiles by profileEngine.availableProfiles.collectAsState()

            var showSearchOverlay by remember { mutableStateOf(false) }
            var showProfileSheet by remember { mutableStateOf(false) }

            LaunchedEffect(Unit) {
                appDiscoveryEngine.loadInstalledApps()
            }

            Surface(modifier = Modifier.fillMaxSize(), color = Color.Black) {
                Box(modifier = Modifier.fillMaxSize()) {
                    AppDrawerSurface(
                        categories = categories,
                        onAppLaunch = { app: AppModel -> launchPackage(app.packageName) },
                        modifier = Modifier.fillMaxSize()
                    )

                    NowBarSurface(
                        state = nowBarState,
                        onSearchClick = { showSearchOverlay = true },
                        onProfileClick = { showProfileSheet = true },
                        onAppClick = { pkg: String -> launchPackage(pkg) },
                        modifier = Modifier
                            .align(Alignment.BottomCenter)
                            .padding(bottom = 24.dp, start = 16.dp, end = 16.dp)
                    )

                    if (showProfileSheet) {
                        ProfileSelectorSheet(
                            activeProfile = activeProfile,
                            profiles = availableProfiles,
                            onProfileSelect = { selected -> profileEngine.setActiveProfile(selected.id) },
                            onDismiss = { showProfileSheet = false }
                        )
                    }

                    if (showSearchOverlay) {
                        SearchOverlay(
                            state = searchState,
                            onQueryChange = { query -> searchEngine.updateQuery(query) },
                            onDismiss = {
                                showSearchOverlay = false
                                searchEngine.clearQuery()
                            },
                            onResultClick = { result ->
                                when (result) {
                                    is SearchResult.AppMatch -> {
                                        launchPackage(result.app.packageName)
                                        showSearchOverlay = false
                                    }
                                    is SearchResult.WebQuery -> {
                                        startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(result.url)))
                                        showSearchOverlay = false
                                    }
                                    is SearchResult.QuickAction -> {
                                        result.action()
                                        showSearchOverlay = false
                                    }
                                }
                            }
                        )
                    }
                }
            }
        }
    }

    private fun launchPackage(packageName: String) {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        if (launchIntent != null) {
            startActivity(launchIntent)
        }
    }
}
KOTLIN

echo "Profile sheet component added and hooked to MainActivity!"
