package com.purple.launcher.search.di

import com.purple.launcher.apps.engine.AppDiscoveryEngine
import com.purple.launcher.search.engine.SearchEngine
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object SearchModule {
    @Provides
    @Singleton
    fun provideSearchEngine(appDiscoveryEngine: AppDiscoveryEngine): SearchEngine {
        return SearchEngine(appDiscoveryEngine)
    }
}
