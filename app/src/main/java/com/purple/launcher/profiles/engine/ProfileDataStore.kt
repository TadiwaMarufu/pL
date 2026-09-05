package com.purple.launcher.profiles.engine

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.purple.launcher.profiles.domain.ProfileId
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

private val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "purple_launcher_profiles")

@Singleton
class ProfileDataStore @Inject constructor(
    @ApplicationContext private val context: Context
) {
    private val activeProfileKey = stringPreferencesKey("active_profile_id")

    val activeProfileId: Flow<ProfileId> = context.dataStore.data.map { prefs ->
        val rawId = prefs[activeProfileKey] ?: ProfileId.FLUID.name
        runCatching { ProfileId.valueOf(rawId) }.getOrDefault(ProfileId.FLUID)
    }

    suspend fun setActiveProfileId(profileId: ProfileId) {
        context.dataStore.edit { prefs -> prefs[activeProfileKey] = profileId.name }
    }
}
