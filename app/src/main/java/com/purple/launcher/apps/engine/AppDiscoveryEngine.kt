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
