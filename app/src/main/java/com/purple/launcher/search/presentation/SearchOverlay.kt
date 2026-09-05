package com.purple.launcher.search.presentation

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.purple.launcher.search.domain.SearchResult
import com.purple.launcher.search.domain.SearchState

@Composable
fun SearchOverlay(
    state: SearchState,
    onQueryChange: (String) -> Unit,
    onDismiss: () -> Unit,
    onResultClick: (SearchResult) -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .background(Color.Black.copy(alpha = 0.92f))
            .padding(16.dp)
            .padding(top = 40.dp)
    ) {
        OutlinedTextField(
            value = state.query,
            onValueChange = onQueryChange,
            placeholder = { Text("Search apps or web...", color = Color.Gray) },
            modifier = Modifier.fillMaxWidth(),
            singleLine = true,
            shape = RoundedCornerShape(24.dp),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = Color.Magenta,
                unfocusedBorderColor = Color.DarkGray,
                focusedTextColor = Color.White,
                unfocusedTextColor = Color.White
            )
        )

        Spacer(modifier = Modifier.height(16.dp))

        LazyColumn(
            verticalArrangement = Arrangement.spacedBy(8.dp),
            modifier = Modifier.fillMaxSize()
        ) {
            items(state.results) { result ->
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(12.dp))
                        .background(Color.White.copy(alpha = 0.08f))
                        .clickable { onResultClick(result) }
                        .padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    when (result) {
                        is SearchResult.AppMatch -> {
                            Text(text = "📱 ${result.app.label}", color = Color.White, fontSize = 16.sp)
                        }
                        is SearchResult.WebQuery -> {
                            Text(text = "🌐 Search web for '${result.query}'", color = Color.LightGray, fontSize = 16.sp)
                        }
                        is SearchResult.QuickAction -> {
                            Text(text = "⚡ ${result.title}", color = Color.Yellow, fontSize = 16.sp)
                        }
                    }
                }
            }
        }
    }
}
