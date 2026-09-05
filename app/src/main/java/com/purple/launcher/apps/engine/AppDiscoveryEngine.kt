package com.purple.launcher.apps.engine

import android.content.Context
import android.content.Intent
import com.purple.launcher.apps.domain.AppCategory
import com.purple.launcher.apps.domain.AppModel
import com.purple.launcher.apps.domain.CategoryGroup
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class AppDiscoveryEngine @Inject constructor(
    @ApplicationContext private val context: Context
) {
    private val scope = CoroutineScope(Dispatchers.Default)
    private val _installedApps = MutableStateFlow<List<AppModel>>(emptyList())

    val categorizedApps: StateFlow<List<CategoryGroup>> = _installedApps.map { apps ->
        AppCategory.entries.mapNotNull { cat ->
            val matches = apps.filter { it.category == cat }
            if (matches.isNotEmpty()) {
                CategoryGroup(cat, cat.name.lowercase().replaceFirstChar { it.uppercase() }, matches)
            } else null
        }
    }.stateIn(scope, SharingStarted.Eagerly, emptyList())

    init { refreshApps() }

    fun refreshApps() {
        scope.launch {
            val pm = context.packageManager
            val intent = Intent(Intent.ACTION_MAIN, null).apply { addCategory(Intent.CATEGORY_LAUNCHER) }
            val infos = pm.queryIntentActivities(intent, 0)
            
            _installedApps.value = infos.map { info ->
                AppModel(
                    packageName = info.activityInfo.packageName,
                    className = info.activityInfo.name,
                    label = info.loadLabel(pm).toString(),
                    category = resolveCategory(info.activityInfo.packageName)
                )
            }.sortedBy { it.label.lowercase() }
        }
    }

    private fun resolveCategory(pkg: String): AppCategory = when {
        pkg.contains("whatsapp") || pkg.contains("messaging") -> AppCategory.COMMUNICATION
        pkg.contains("facebook") || pkg.contains("instagram") -> AppCategory.SOCIAL
        pkg.contains("spotify") || pkg.contains("youtube") -> AppCategory.MEDIA
        pkg.contains("doc") || pkg.contains("mail") -> AppCategory.WORK
        pkg.contains("game") -> AppCategory.GAMES
        else -> AppCategory.TOOLS
    }
}
