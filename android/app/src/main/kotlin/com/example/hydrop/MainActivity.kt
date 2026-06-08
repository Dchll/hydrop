package com.dchll.hydrop

import android.content.Intent
import android.net.Uri
import android.net.wifi.WifiManager
import android.os.Build
import android.os.Environment
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private var discoveryMulticastLock: WifiManager.MulticastLock? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "hydrop/android_file_access",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAllFilesAccessGranted" -> {
                    result.success(isAllFilesAccessGranted())
                }

                "openAllFilesAccessSettings" -> {
                    result.success(openAllFilesAccessSettings())
                }

                "openFileWithChooser" -> {
                    val filePath = call.argument<String>("filePath")
                    val mimeType = call.argument<String>("mimeType")
                    result.success(openFileWithChooser(filePath, mimeType))
                }

                "acquireDiscoveryMulticastLock" -> {
                    result.success(acquireDiscoveryMulticastLock())
                }

                "releaseDiscoveryMulticastLock" -> {
                    result.success(releaseDiscoveryMulticastLock())
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun isAllFilesAccessGranted(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            return true
        }
        return Environment.isExternalStorageManager()
    }

    private fun openAllFilesAccessSettings(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            return false
        }
        val packageUri = Uri.parse("package:$packageName")
        val appSpecificIntent = Intent(
            Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION,
            packageUri,
        )
        appSpecificIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

        val fallbackIntent = Intent(Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION)
        fallbackIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

        return try {
            startActivity(appSpecificIntent)
            true
        } catch (_: Exception) {
            try {
                startActivity(fallbackIntent)
                true
            } catch (_: Exception) {
                false
            }
        }
    }

    private fun openFileWithChooser(filePath: String?, mimeType: String?): Boolean {
        if (filePath.isNullOrBlank()) {
            return false
        }
        val file = File(filePath)
        if (!file.exists()) {
            return false
        }

        val uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            FileProvider.getUriForFile(
                this,
                "$packageName.fileProvider.com.crazecoder.openfile",
                file,
            )
        } else {
            Uri.fromFile(file)
        }

        val viewIntent = Intent(Intent.ACTION_VIEW).apply {
            addCategory(Intent.CATEGORY_DEFAULT)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            setDataAndType(uri, mimeType ?: "*/*")
        }
        val chooserIntent = Intent.createChooser(viewIntent, null).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }

        return try {
            startActivity(chooserIntent)
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun acquireDiscoveryMulticastLock(): Boolean {
        val wifiManager =
            applicationContext.getSystemService(WIFI_SERVICE) as? WifiManager
                ?: return false
        val lock = discoveryMulticastLock ?: wifiManager.createMulticastLock(
            "hydrop_discovery_multicast_lock",
        ).apply {
            setReferenceCounted(true)
        }
        return try {
            if (!lock.isHeld) {
                lock.acquire()
            }
            discoveryMulticastLock = lock
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun releaseDiscoveryMulticastLock(): Boolean {
        val lock = discoveryMulticastLock ?: return true
        return try {
            if (lock.isHeld) {
                lock.release()
            }
            discoveryMulticastLock = null
            true
        } catch (_: Exception) {
            false
        }
    }
}
