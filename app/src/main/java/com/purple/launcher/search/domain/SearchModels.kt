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
