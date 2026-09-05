#!/bin/bash
set -e

BASE_DIR="app/src/main/java/com/purple/launcher/search"

echo "Building Universal Search Engine..."

mkdir -p ${BASE_DIR}/{domain,engine,presentation,di}

# 1. Search Models
cat << 'KOTLIN' > ${BASE_DIR}/domain/SearchModels.kt
package com.purple.launcher.search.domain

import com.purple.launcher.apps.domain.AppModel

sealed interface SearchResult {
    data class AppMatch(val app: AppModel) : SearchResult
    data class WebQuery(val query: String, val url: String) : SearchResult
    data class QuickAction(val id: String, val title: String, val action: () -> Unit) : SearchResult
}

data class SearchState(
    val query: String = "",
    val isSearching: Boolean = false,
    val results: List<SearchResult> = emptyList()
)
KOTLIN

# 2. Search Engine Implementation
cat << 'KOTLIN' > ${BASE_DIR}/engine/SearchEngine.kt
package com.purple.launcher.search.engine

import com.purple.launcher.apps.engine.AppDiscoveryEngine
import com.purple.launcher.search.domain.SearchResult
import com.purple.launcher.search.domain.SearchState
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.*
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class SearchEngine @Inject constructor(
    private val appDiscoveryEngine: AppDiscoveryEngine
) {
    private val scope = CoroutineScope(Dispatchers.Default)
    private val _query = MutableStateFlow("")

    val searchState: StateFlow<SearchState> = combine(
        _query,
        appDiscoveryEngine.categorizedApps
    ) { query, categories ->
        if (query.isBlank()) {
            SearchState(query = "", isSearching = false, results = emptyList())
        } else {
            val allApps = categories.flatMap { it.apps }
            val appMatches = allApps.filter {
                it.label.contains(query, ignoreCase = true) ||
                it.packageName.contains(query, ignoreCase = true)
            }.map { SearchResult.AppMatch(it) }

            val webFallback = SearchResult.WebQuery(
                query = query,
                url = "https://www.google.com/search?q=${java.net.URLEncoder.encode(query, "UTF-8")}"
            )

            SearchState(
                query = query,
                isSearching = true,
                results = appMatches + webFallback
            )
        }
    }.stateIn(scope, SharingStarted.Eagerly, SearchState())

    fun updateQuery(newQuery: String) {
        _query.value = newQuery
    }

    fun clearQuery() {
        _query.value = ""
    }
}
KOTLIN

# 3. DI Module
cat << 'KOTLIN' > ${BASE_DIR}/di/SearchModule.kt
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
KOTLIN

echo "Universal Search Engine setup complete!"
