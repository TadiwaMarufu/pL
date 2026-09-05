package com.purple.launcher.profiles.di

import android.content.Context
import com.purple.launcher.profiles.engine.ProfileDataStore
import com.purple.launcher.profiles.engine.ProfileEngine
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object ProfileModule {
    @Provides
    @Singleton
    fun provideProfileDataStore(@ApplicationContext context: Context) = ProfileDataStore(context)

    @Provides
    @Singleton
    fun provideProfileEngine(dataStore: ProfileDataStore) = ProfileEngine(dataStore)
}
