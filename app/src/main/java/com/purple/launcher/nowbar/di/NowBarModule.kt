package com.purple.launcher.nowbar.di

import com.purple.launcher.nowbar.NowBarEngine
import com.purple.launcher.profiles.engine.ProfileEngine
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object NowBarModule {
    @Provides
    @Singleton
    fun provideNowBarEngine(profileEngine: ProfileEngine) = NowBarEngine(profileEngine)
}
