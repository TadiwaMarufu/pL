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
