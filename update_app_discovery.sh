#!/bin/bash
set -e

DOMAIN_DIR="app/src/main/java/com/purple/launcher/apps/domain"
ENGINE_DIR="app/src/main/java/com/purple/launcher/apps/engine"
PRES_DIR="app/src/main/java/com/purple/launcher/apps/presentation"

mkdir -p ${DOMAIN_DIR} ${ENGINE_DIR} ${PRES_DIR}

# 1. Ensure AppModel supports Drawable or Icon Bitmap
cat << 'KOTLIN' > ${DOMAIN_DIR}/AppModel.kt
package com.purple.launcher.apps.domain

import android.graphics.drawable.Drawable

data class AppModel(
    val id: String,
    val label: String,
    val packageName: String,
    val icon: Drawable? = null,
    val categoryName: String = "General"
)

data class CategoryGroup(
    val name: String,
    val apps: List<AppModel>
)
KOTLIN

# 2. Implement Real App Discovery Engine using Android PackageManager
cat << 'KOTLIN' > ${ENGINE_DIR}/AppDiscoveryEngine.kt
package com.purple.launcher.apps.engine

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import com.purple.launcher.apps.domain.AppModel
import com.purple.launcher.apps.domain.CategoryGroup
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.withContext
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class AppDiscoveryEngine @Inject constructor(
    @ApplicationContext private val context: Context
) {
    private val _categorizedApps = MutableStateFlow<List<CategoryGroup>>(emptyList())
    val categorizedApps: StateFlow<List<CategoryGroup>> = _categorizedApps.asStateFlow()

    suspend fun loadInstalledApps() = withContext(Dispatchers.IO) {
        val pm = context.packageManager
        val intent = Intent(Intent.ACTION_MAIN, null).apply {
            addCategory(Intent.CATEGORY_LAUNCHER)
        }

        val resolveInfos = pm.queryIntentActivities(intent, 0)
        val appList = resolveInfos.mapNotNull { resolveInfo ->
            val pkg = resolveInfo.activityInfo.packageName
            if (pkg == context.packageName) return@mapNotNull null // Don't list launcher itself

            val label = resolveInfo.loadLabel(pm).toString()
            val icon = resolveInfo.loadIcon(pm)

            AppModel(
                id = pkg,
                label = label,
                packageName = pkg,
                icon = icon,
                categoryName = "Apps"
            )
        }.sortedBy { it.label.lowercase() }

        _categorizedApps.value = listOf(
            CategoryGroup(name = "All Apps", apps = appList)
        )
    }
}
KOTLIN

# 3. Update AppDrawerSurface to render actual app icons safely
cat << 'KOTLIN' > ${PRES_DIR}/AppDrawerSurface.kt
package com.purple.launcher.apps.presentation

import androidx.compose.foundation.Image
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
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.graphics.drawable.toBitmap
import com.purple.launcher.apps.domain.CategoryGroup
import com.purple.launcher.apps.domain.AppModel

@Composable
fun AppDrawerSurface(
    categories: List<CategoryGroup>,
    onAppLaunch: (AppModel) -> Unit,
    modifier: Modifier = Modifier
) {
    val allApps = categories.flatMap { it.apps }

    LazyVerticalGrid(
        columns = GridCells.Fixed(4),
        modifier = modifier
            .fillMaxSize()
            .padding(horizontal = 16.dp, vertical = 24.dp),
        contentPadding = PaddingValues(bottom = 100.dp),
        horizontalArrangement = Arrangement.spacedBy(16.dp),
        verticalArrangement = Arrangement.spacedBy(20.dp)
    ) {
        items(items = allApps, key = { it.packageName }) { app ->
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier
                    .clickable { onAppLaunch(app) }
                    .padding(4.dp)
            ) {
                Box(
                    modifier = Modifier.size(52.dp),
                    contentAlignment = Alignment.Center
                ) {
                    if (app.icon != null) {
                        Image(
                            bitmap = app.icon.toBitmap().asImageBitmap(),
                            contentDescription = app.label,
                            modifier = Modifier.fillMaxSize()
                        )
                    } else {
                        Box(
                            modifier = Modifier
                                .fillMaxSize()
                                .background(Color.DarkGray),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = app.label.take(1),
                                color = Color.White,
                                fontSize = 18.sp
                            )
                        }
                    }
                }
                Spacer(modifier = Modifier.height(6.dp))
                Text(
                    text = app.label,
                    color = Color.White,
                    fontSize = 12.sp,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
        }
    }
}
KOTLIN

echo "App discovery engine updated with real Package Manager fetching!"
