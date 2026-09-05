#!/bin/bash
set -e

RECEIVER_DIR="app/src/main/java/com/purple/launcher/apps/receiver"

mkdir -p ${RECEIVER_DIR}

cat << 'KOTLIN' > ${RECEIVER_DIR}/PackageChangeReceiver.kt
package com.purple.launcher.apps.receiver

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.purple.launcher.apps.engine.AppDiscoveryEngine
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import javax.inject.Inject

@AndroidEntryPoint
class PackageChangeReceiver : BroadcastReceiver() {

    @Inject lateinit var appDiscoveryEngine: AppDiscoveryEngine

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_PACKAGE_ADDED,
            Intent.ACTION_PACKAGE_REMOVED,
            Intent.ACTION_PACKAGE_CHANGED -> {
                val pendingResult = goAsync()
                CoroutineScope(Dispatchers.IO).launch {
                    try {
                        appDiscoveryEngine.refreshApps()
                    } finally {
                        pendingResult.finish()
                    }
                }
            }
        }
    }
}
KOTLIN

echo "PackageChangeReceiver updated with async coroutine scope!"
