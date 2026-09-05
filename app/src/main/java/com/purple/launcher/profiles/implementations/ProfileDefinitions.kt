package com.purple.launcher.profiles.implementations

import androidx.compose.ui.unit.dp
import com.purple.launcher.profiles.domain.*

object FluidProfile : ProfileDefinition {
    override val identity = ProfileIdentity(ProfileId.FLUID, "Fluid", "Alive, soft, flowing.", "Contextual UI with organic motion.")
    override val nowBarBehavior = NowBarBehavior.DYNAMIC_PILL
    override val iconStyle = ProfileIconStyle(iconSize = 52.dp, showLabels = true, cornerRadius = 18.dp)
    override val motionSpec = ProfileMotionSpec(350, 0.75f, 300f, enableParallax = true, enableBlur = true)
}

object PremiumProfile : ProfileDefinition {
    override val identity = ProfileIdentity(ProfileId.PREMIUM, "Premium", "Refined, elegant, precise.", "High-quality surfaces and restrained motion.")
    override val nowBarBehavior = NowBarBehavior.RESTRAINED_LINE
    override val iconStyle = ProfileIconStyle(iconSize = 48.dp, showLabels = true, cornerRadius = 8.dp)
    override val motionSpec = ProfileMotionSpec(250, 1.0f, 500f, enableParallax = false, enableBlur = true)
}

object CalmProfile : ProfileDefinition {
    override val identity = ProfileIdentity(ProfileId.CALM, "Calm", "Quiet, minimal, peaceful.", "Low visual noise with subtle monochrome design.")
    override val nowBarBehavior = NowBarBehavior.TEXT_ONLY
    override val iconStyle = ProfileIconStyle(iconSize = 44.dp, showLabels = false, forceMonochrome = true, cornerRadius = 22.dp)
    override val motionSpec = ProfileMotionSpec(150, 1.0f, 800f, enableParallax = false, enableBlur = false)
}

object FocusProfile : ProfileDefinition {
    override val identity = ProfileIdentity(ProfileId.FOCUS, "Focus", "Productive, fast, functional.", "Prioritizes useful tasks and direct actions.")
    override val nowBarBehavior = NowBarBehavior.ACTION_BAR
    override val iconStyle = ProfileIconStyle(iconSize = 46.dp, showLabels = true, cornerRadius = 6.dp)
    override val motionSpec = ProfileMotionSpec(180, 0.9f, 600f, enableParallax = false, enableBlur = false)
}

object ExpressiveProfile : ProfileDefinition {
    override val identity = ProfileIdentity(ProfileId.EXPRESSIVE, "Expressive", "Artistic, creative, personal.", "Unconventional arrangements and dynamic visuals.")
    override val nowBarBehavior = NowBarBehavior.ASYMMETRIC
    override val iconStyle = ProfileIconStyle(iconSize = 56.dp, showLabels = true, cornerRadius = 28.dp)
    override val motionSpec = ProfileMotionSpec(400, 0.6f, 250f, enableParallax = true, enableBlur = false)
}
