#!/bin/bash
set -e

HOME_DIR="app/src/main/java/com/purple/launcher/launcher/presentation"
NOWBAR_DIR="app/src/main/java/com/purple/launcher/nowbar"
SEARCH_DIR="app/src/main/java/com/purple/launcher/search/presentation"

echo "Building Home UI Composables..."

mkdir -p ${SEARCH_DIR}

# 1. Now Bar UI Component
cat << 'KOTLIN' > ${NOWBAR_DIR}/NowBarUi.kt
package com.purple.launcher.nowbar

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Palette
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
fun NowBarSurface(
    state: NowBarState,
    onSearchClick: () -> Unit,
    onProfileClick: () -> Unit,
    onAppClick: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .height(64.dp)
            .clip(CircleShape)
            .background(Color.DarkGray.copy(alpha = 0.9f))
            .padding(horizontal = 16.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        // Search Trigger
        Box(
            modifier = Modifier
                .size(44.dp)
                .clip(CircleShape)
                .background(Color.White.copy(alpha = 0.15f))
                .clickable { onSearchClick() },
            contentAlignment = Alignment.Center
        ) {
            Icon(imageVector = Icons.Default.Search, contentDescription = "Search", tint = Color.White)
        }

        // Shortcuts
        Row(
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            state.items.filterIsInstance<NowBarItem.AppShortcut>().forEach { item ->
                Box(
                    modifier = Modifier
                        .size(40.dp)
                        .clip(CircleShape)
                        .background(Color.Magenta.copy(alpha = 0.3f))
                        .clickable { onAppClick(item.packageName) },
                    contentAlignment = Alignment.Center
                ) {
                    Text(text = item.label.take(1), color = Color.White, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                }
            }
        }

        // Profile Switcher Trigger
        Box(
            modifier = Modifier
                .size(44.dp)
                .clip(CircleShape)
                .background(Color.White.copy(alpha = 0.15f))
                .clickable { onProfileClick() },
            contentAlignment = Alignment.Center
        ) {
            Icon(imageVector = Icons.Default.Palette, contentDescription = "Profiles", tint = Color.White)
        }
    }
}
KOTLIN

# 2. Universal Search Overlay
cat << 'KOTLIN' > ${SEARCH_DIR}/SearchOverlay.kt
package com.purple.launcher.search.presentation

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.purple.launcher.search.domain.SearchResult
import com.purple.launcher.search.domain.SearchState

@Composable
fun SearchOverlay(
    state: SearchState,
    onQueryChange: (String) -> Unit,
    onDismiss: () -> Unit,
    onResultClick: (SearchResult) -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .background(Color.Black.copy(alpha = 0.92f))
            .padding(16.dp)
            .padding(top = 40.dp)
    ) {
        OutlinedTextField(
            value = state.query,
            onValueChange = onQueryChange,
            placeholder = { Text("Search apps or web...", color = Color.Gray) },
            modifier = Modifier.fillMaxWidth(),
            singleLine = true,
            shape = RoundedCornerShape(24.dp),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = Color.Magenta,
                unfocusedBorderColor = Color.DarkGray,
                focusedTextColor = Color.White,
                unfocusedTextColor = Color.White
            )
        )

        Spacer(modifier = Modifier.height(16.dp))

        LazyColumn(
            verticalArrangement = Arrangement.spacedBy(8.dp),
            modifier = Modifier.fillMaxSize()
        ) {
            items(state.results) { result ->
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(12.dp))
                        .background(Color.White.copy(alpha = 0.08f))
                        .clickable { onResultClick(result) }
                        .padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    when (result) {
                        is SearchResult.AppMatch -> {
                            Text(text = "📱 ${result.app.label}", color = Color.White, fontSize = 16.sp)
                        }
                        is SearchResult.WebQuery -> {
                            Text(text = "🌐 Search web for '${result.query}'", color = Color.LightGray, fontSize = 16.sp)
                        }
                        is SearchResult.QuickAction -> {
                            Text(text = "⚡ ${result.title}", color = Color.Yellow, fontSize = 16.sp)
                        }
                    }
                }
            }
        }
    }
}
KOTLIN

# 3. Connect Main Home Screen Shell
cat << 'KOTLIN' > ${HOME_DIR}/MainActivity.kt
package com.purple.launcher.launcher.presentation

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Surface
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.purple.launcher.apps.engine.AppDiscoveryEngine
import com.purple.launcher.apps.presentation.AppDrawerSurface
import com.purple.launcher.nowbar.NowBarEngine
import com.purple.launcher.nowbar.NowBarSurface
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

    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
        setContent {
            val nowBarState by nowBarEngine.nowBarState.collectAsState()
            val categories by appDiscoveryEngine.categorizedApps.collectAsState()
            val searchState by searchEngine.searchState.collectAsState()

            var showSearchOverlay by remember { mutableStateOf(false) }

            Surface(modifier = Modifier.fillMaxSize(), color = Color.Black) {
                Box(modifier = Modifier.fillMaxSize()) {
                    // Category App Drawer Content
                    AppDrawerSurface(
                        categories = categories,
                        onAppLaunch = { app -> launchPackage(app.packageName) },
                        modifier = Modifier.fillMaxSize()
                    )

                    // Anchored Now Bar at Bottom
                    NowBarSurface(
                        state = nowBarState,
                        onSearchClick = { showSearchOverlay = true },
                        onProfileClick = { /* Profile Selector Sheet */ },
                        onAppClick = { pkg -> launchPackage(pkg) },
                        modifier = Modifier
                            .align(Alignment.BottomCenter)
                            .padding(bottom = 24.dp, start = 16.dp, end = 16.dp)
                    )

                    // Search Modal Overlay
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

echo "Home UI complete!"
