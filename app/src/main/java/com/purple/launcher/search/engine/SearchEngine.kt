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
