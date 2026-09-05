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
