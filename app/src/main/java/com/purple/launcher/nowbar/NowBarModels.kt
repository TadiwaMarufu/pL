package com.purple.launcher.nowbar

import com.purple.launcher.profiles.domain.ProfileId

sealed interface NowBarItem {
    val id: String
    object SearchTrigger : NowBarItem { override val id: String = "nowbar_search" }
    object ProfileSwitcherTrigger : NowBarItem { override val id: String = "nowbar_profile_switcher" }
    data class AppShortcut(override val id: String, val packageName: String, val label: String) : NowBarItem
}

data class NowBarState(
    val activeProfileId: ProfileId = ProfileId.FLUID,
    val items: List<NowBarItem> = listOf(
        NowBarItem.SearchTrigger,
        NowBarItem.AppShortcut("app_1", "com.android.chrome", "Browser"),
        NowBarItem.AppShortcut("app_2", "com.whatsapp", "Messages"),
        NowBarItem.AppShortcut("app_3", "com.spotify.music", "Music"),
        NowBarItem.ProfileSwitcherTrigger
    )
)
