package com.purple.launcher.apps.receiver

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.purple.launcher.apps.engine.AppDiscoveryEngine
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

@AndroidEntryPoint
class PackageChangeReceiver : BroadcastReceiver() {
    @Inject lateinit var appDiscoveryEngine: AppDiscoveryEngine

    override fun onReceive(context: Context?, intent: Intent?) {
        appDiscoveryEngine.refreshApps()
    }
}
