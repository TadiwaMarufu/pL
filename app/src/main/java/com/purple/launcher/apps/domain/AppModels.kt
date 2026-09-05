package com.purple.launcher.apps.domain

enum class AppCategory { COMMUNICATION, SOCIAL, MEDIA, WORK, GAMES, TOOLS, UNCATEGORIZED }

data class AppModel(
    val packageName: String,
    val className: String,
    val label: String,
    val category: AppCategory = AppCategory.UNCATEGORIZED
)

data class CategoryGroup(
    val category: AppCategory,
    val displayName: String,
    val apps: List<AppModel>
)
