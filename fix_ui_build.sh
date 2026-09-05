#!/bin/bash
set -e

NOWBAR_DIR="app/src/main/java/com/purple/launcher/nowbar"

# Update NowBarUi to use Text icons to avoid missing extended Material vector icon dependency issues
cat << 'KOTLIN' > ${NOWBAR_DIR}/NowBarUi.kt
package com.purple.launcher.nowbar

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
fun NowBarSurface(
    state: NowBarState,
    onSearchClick: () -> Unit,
    onProfileClick: () -> Unit,
    onAppClick: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .height(64.dp)
            .clip(CircleShape)
            .background(Color.DarkGray.copy(alpha = 0.9f))
            .padding(horizontal = 16.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        // Search Trigger Icon
        Box(
            modifier = Modifier
                .size(44.dp)
                .clip(CircleShape)
                .background(Color.White.copy(alpha = 0.15f))
                .clickable { onSearchClick() },
            contentAlignment = Alignment.Center
        ) {
            Text(text = "🔍", fontSize = 18.sp)
        }

        // App Shortcuts
        Row(
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            state.items.filterIsInstance<NowBarItem.AppShortcut>().forEach { item ->
                Box(
                    modifier = Modifier
                        .size(40.dp)
                        .clip(CircleShape)
                        .background(Color.Magenta.copy(alpha = 0.3f))
                        .clickable { onAppClick(item.packageName) },
                    contentAlignment = Alignment.Center
                ) {
                    Text(text = item.label.take(1), color = Color.White, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                }
            }
        }

        // Profile Switcher Trigger Icon
        Box(
            modifier = Modifier
                .size(44.dp)
                .clip(CircleShape)
                .background(Color.White.copy(alpha = 0.15f))
                .clickable { onProfileClick() },
            contentAlignment = Alignment.Center
        ) {
            Text(text = "🎨", fontSize = 18.sp)
        }
    }
}
KOTLIN

echo "Fix applied successfully!"
