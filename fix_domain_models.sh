#!/bin/bash
set -e

APPS_PRES_DIR="app/src/main/java/com/purple/launcher/apps/presentation"
MAIN_PRES_DIR="app/src/main/java/com/purple/launcher/launcher/presentation"

# 1. Update AppDrawerSurface to use CategoryGroup instead of AppCategory
cat << 'KOTLIN' > ${APPS_PRES_DIR}/AppDrawerSurface.kt
package com.purple.launcher.apps.presentation

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.purple.launcher.apps.domain.CategoryGroup
import com.purple.launcher.apps.domain.AppModel

@Composable
fun AppDrawerSurface(
    categories: List<CategoryGroup>,
    onAppLaunch: (AppModel) -> Unit,
    modifier: Modifier = Modifier
) {
    val allApps: List<AppModel> = categories.flatMap { group -> group.apps }

    LazyVerticalGrid(
        columns = GridCells.Fixed(4),
        modifier = modifier
            .fillMaxSize()
            .padding(16.dp),
        contentPadding = PaddingValues(bottom = 96.dp),
        horizontalArrangement = Arrangement.spacedBy(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        items(items = allApps) { app: AppModel ->
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier
                    .clickable { onAppLaunch(app) }
                    .padding(8.dp)
            ) {
                Box(
                    modifier = Modifier
                        .size(48.dp)
                        .background(Color.Gray.copy(alpha = 0.3f)),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = app.label.take(1),
                        color = Color.White,
                        fontSize = 20.sp
                    )
                }
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = app.label,
                    color = Color.White,
                    fontSize = 12.sp,
                    maxLines = 1
                )
            }
        }
    }
}
KOTLIN

# 2. Sync MainActivity to supply List<CategoryGroup>
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
            val categories: List<CategoryGroup> by appDiscoveryEngine.categorizedApps.collectAsState()
            val searchState by searchEngine.searchState.collectAsState()

            var showSearchOverlay by remember { mutableStateOf(false) }

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
                        onProfileClick = { },
                        onAppClick = { pkg: String -> launchPackage(pkg) },
                        modifier = Modifier
                            .align(Alignment.BottomCenter)
                            .padding(bottom = 24.dp, start = 16.dp, end = 16.dp)
                    )

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

echo "CategoryGroup and explicit type parameters applied!"
