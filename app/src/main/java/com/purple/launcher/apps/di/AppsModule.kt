package com.purple.launcher.apps.di

import android.content.Context
import com.purple.launcher.apps.engine.AppDiscoveryEngine
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object AppsModule {
    @Provides
    @Singleton
    fun provideAppDiscoveryEngine(@ApplicationContext context: Context) = AppDiscoveryEngine(context)
}
