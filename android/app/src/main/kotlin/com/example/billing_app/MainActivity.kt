package com.example.billing_app

import android.content.Intent
import android.net.Uri
import android.os.Environment
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.billing_app/whatsapp_share"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "shareFile" -> {
                    val phone = call.argument<String>("phone")
                    val filePath = call.argument<List<String>>("filePath")

                    if (phone == null || filePath == null || filePath.isEmpty()) {
                        result.error("INVALID_ARGS", "Phone and filePath required", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val srcFile = File(filePath[0])
                        // Copy to internal cache dir so FileProvider can access it
                        val destFile = File(cacheDir, "receipt_${System.currentTimeMillis()}.png")
                        srcFile.copyTo(destFile, overwrite = true)

                        val uri = FileProvider.getUriForFile(this, "$packageName.provider", destFile)

                        val intent = Intent(Intent.ACTION_SEND)
                        intent.type = "image/png"
                        intent.putExtra(Intent.EXTRA_STREAM, uri)
                        intent.putExtra("jid", "$phone@s.whatsapp.net")
                        intent.setPackage("com.whatsapp")
                        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)

                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SHARE_FAILED", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
