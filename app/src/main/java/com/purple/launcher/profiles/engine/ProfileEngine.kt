package com.purple.launcher.profiles.engine

import com.purple.launcher.profiles.domain.ProfileDefinition
import com.purple.launcher.profiles.domain.ProfileId
import com.purple.launcher.profiles.implementations.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.*
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class ProfileEngine @Inject constructor(
    private val dataStore: ProfileDataStore
) {
    private val scope = CoroutineScope(Dispatchers.Default)

    val activeProfile: StateFlow<ProfileDefinition> = dataStore.activeProfileId
        .map { resolveProfile(it) }
        .stateIn(scope, SharingStarted.Eagerly, FluidProfile)

    suspend fun switchProfile(profileId: ProfileId) {
        dataStore.setActiveProfileId(profileId)
    }

    fun resolveProfile(id: ProfileId): ProfileDefinition = when (id) {
        ProfileId.FLUID -> FluidProfile
        ProfileId.PREMIUM -> PremiumProfile
        ProfileId.CALM -> CalmProfile
        ProfileId.FOCUS -> FocusProfile
        ProfileId.EXPRESSIVE -> ExpressiveProfile
    }
}
