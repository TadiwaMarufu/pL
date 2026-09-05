package com.purple.launcher.nowbar

import com.purple.launcher.profiles.engine.ProfileEngine
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.*
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class NowBarEngine @Inject constructor(
    private val profileEngine: ProfileEngine
) {
    private val scope = CoroutineScope(Dispatchers.Default)

    val nowBarState: StateFlow<NowBarState> = profileEngine.activeProfile.map { profile ->
        NowBarState(
            activeProfileId = profile.identity.id,
            items = listOf(
                NowBarItem.SearchTrigger,
                NowBarItem.AppShortcut("app_1", "com.android.chrome", "Browser"),
                NowBarItem.AppShortcut("app_2", "com.whatsapp", "Messages"),
                NowBarItem.AppShortcut("app_3", "com.spotify.music", "Music"),
                NowBarItem.ProfileSwitcherTrigger
            )
        )
    }.stateIn(scope, SharingStarted.Eagerly, NowBarState())
}
