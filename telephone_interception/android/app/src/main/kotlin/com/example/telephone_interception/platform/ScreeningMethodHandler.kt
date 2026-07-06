package com.example.telephone_interception.platform

import android.app.Activity
import android.app.role.RoleManager
import android.content.Intent
import android.os.Build
import android.provider.Settings
import com.example.telephone_interception.ScreeningStore
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class ScreeningMethodHandler(
    private val activity: Activity,
    private val store: ScreeningStore,
) : MethodChannel.MethodCallHandler {
    private var pendingRoleResult: MethodChannel.Result? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getStatus" -> result.success(readStatus())
            "requestRole" -> requestScreeningRole(result)
            "openSettings" -> {
                activity.startActivity(Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS))
                result.success(true)
            }
            "getSettings" -> result.success(store.getSettings())
            "saveSettings" -> saveSettings(call.arguments, result)
            "getLogs" -> result.success(store.getLogs())
            "clearLogs" -> {
                store.clearLogs()
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    fun onActivityResult(requestCode: Int): Boolean {
        if (requestCode != ROLE_REQUEST_CODE) return false
        pendingRoleResult?.success(isRoleHeld())
        pendingRoleResult = null
        return true
    }

    private fun saveSettings(arguments: Any?, result: MethodChannel.Result) {
        val values = arguments as? Map<*, *>
        if (values == null) {
            result.error("invalid_arguments", "设置参数不能为空", null)
            return
        }
        store.saveSettings(values)
        result.success(true)
    }

    private fun readStatus(): Map<String, Any> {
        val roleManager = roleManager()
        return mapOf(
            "supported" to (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N),
            "roleAvailable" to (
                Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q &&
                    roleManager?.isRoleAvailable(RoleManager.ROLE_CALL_SCREENING) == true
                ),
            "roleHeld" to isRoleHeld(),
            "sdk" to Build.VERSION.SDK_INT,
        )
    }

    private fun requestScreeningRole(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            result.error(
                "role_unavailable",
                "Android 10 以下需在系统默认应用设置中手动选择来电筛选应用",
                null,
            )
            return
        }
        val manager = roleManager()
        if (manager == null || !manager.isRoleAvailable(RoleManager.ROLE_CALL_SCREENING)) {
            result.error("role_unavailable", "此设备不支持来电筛选角色", null)
            return
        }
        if (manager.isRoleHeld(RoleManager.ROLE_CALL_SCREENING)) {
            result.success(true)
            return
        }
        pendingRoleResult?.error("cancelled", "新的授权请求已发起", null)
        pendingRoleResult = result
        activity.startActivityForResult(
            manager.createRequestRoleIntent(RoleManager.ROLE_CALL_SCREENING),
            ROLE_REQUEST_CODE,
        )
    }

    private fun roleManager(): RoleManager? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
        activity.getSystemService(RoleManager::class.java)
    } else {
        null
    }

    private fun isRoleHeld(): Boolean =
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q &&
            roleManager()?.isRoleHeld(RoleManager.ROLE_CALL_SCREENING) == true

    companion object {
        const val CHANNEL_NAME = "telephone_interception/call_screening"
        private const val ROLE_REQUEST_CODE = 7102
    }
}
