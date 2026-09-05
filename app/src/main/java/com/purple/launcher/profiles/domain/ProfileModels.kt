package com.purple.launcher.profiles.domain

import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

enum class ProfileId { FLUID, PREMIUM, CALM, FOCUS, EXPRESSIVE }
enum class NowBarBehavior { DYNAMIC_PILL, RESTRAINED_LINE, TEXT_ONLY, ACTION_BAR, ASYMMETRIC }

data class ProfileMotionSpec(
    val durationMillis: Int,
    val springDamping: Float,
    val springStiffness: Float,
    val enableParallax: Boolean,
    val enableBlur: Boolean
)

data class ProfileIconStyle(
    val iconSize: Dp = 48.dp,
    val showLabels: Boolean = true,
    val forceMonochrome: Boolean = false,
    val cornerRadius: Dp = 12.dp
)

data class ProfileIdentity(
    val id: ProfileId,
    val name: String,
    val tagline: String,
    val description: String
)

interface ProfileDefinition {
    val identity: ProfileIdentity
    val nowBarBehavior: NowBarBehavior
    val iconStyle: ProfileIconStyle
    val motionSpec: ProfileMotionSpec
}
