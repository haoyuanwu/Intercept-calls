package com.example.telephone_interception

import android.content.Intent
import com.example.telephone_interception.platform.ScreeningMethodHandler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private lateinit var screeningHandler: ScreeningMethodHandler

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        screeningHandler = ScreeningMethodHandler(this, ScreeningStore(applicationContext))
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            ScreeningMethodHandler.CHANNEL_NAME,
        ).setMethodCallHandler(screeningHandler)
    }

    @Deprecated("Deprecated in Android")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (::screeningHandler.isInitialized) {
            screeningHandler.onActivityResult(requestCode)
        }
    }
}
