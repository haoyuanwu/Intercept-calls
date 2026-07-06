package com.example.telephone_interception

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

class ScreeningStore(context: Context) {
    private val preferences = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)

    fun getSettings(): Map<String, Any> = readPolicy().let { policy ->
        mapOf(
            "enabled" to policy.enabled,
            "blockFraud" to policy.blockFraud,
            "blockMarketing" to policy.blockMarketing,
            "blockPrivate" to policy.blockPrivate,
            "blockBank" to policy.blockBank,
            "blockCarrier" to policy.blockCarrier,
            "builtInRulesEnabled" to policy.builtInRulesEnabled,
            "repeatedCallProtection" to policy.repeatedCallProtection,
            "blacklist" to policy.blacklist.toList().sorted(),
            "whitelist" to policy.whitelist.toList().sorted(),
            "blockedPrefixes" to policy.blockedPrefixes.toList().sorted(),
            "labels" to policy.labels,
        )
    }

    fun readPolicy(): ScreeningPolicy = ScreeningPolicy(
        enabled = preferences.getBoolean(KEY_ENABLED, true),
        blockFraud = preferences.getBoolean(KEY_BLOCK_FRAUD, true),
        blockMarketing = preferences.getBoolean(KEY_BLOCK_MARKETING, true),
        blockPrivate = preferences.getBoolean(KEY_BLOCK_PRIVATE, false),
        blockBank = preferences.getBoolean(KEY_BLOCK_BANK, false),
        blockCarrier = preferences.getBoolean(KEY_BLOCK_CARRIER, false),
        builtInRulesEnabled = preferences.getBoolean(KEY_BUILT_IN_RULES, true),
        repeatedCallProtection = preferences.getBoolean(KEY_REPEATED_CALL_PROTECTION, true),
        blacklist = getStringSet(KEY_BLACKLIST),
        whitelist = getStringSet(KEY_WHITELIST),
        blockedPrefixes = getStringSet(KEY_BLOCKED_PREFIXES),
        labels = readLabels(),
    )

    fun saveSettings(values: Map<*, *>) {
        val editor = preferences.edit()
        putBooleanIfPresent(editor, values, KEY_ENABLED)
        putBooleanIfPresent(editor, values, KEY_BLOCK_FRAUD)
        putBooleanIfPresent(editor, values, KEY_BLOCK_MARKETING)
        putBooleanIfPresent(editor, values, KEY_BLOCK_PRIVATE)
        putBooleanIfPresent(editor, values, KEY_BLOCK_BANK)
        putBooleanIfPresent(editor, values, KEY_BLOCK_CARRIER)
        putBooleanIfPresent(editor, values, KEY_BUILT_IN_RULES)
        putBooleanIfPresent(editor, values, KEY_REPEATED_CALL_PROTECTION)
        listFrom(values[KEY_BLACKLIST])?.let { editor.putStringSet(KEY_BLACKLIST, it.toSet()) }
        listFrom(values[KEY_WHITELIST])?.let { editor.putStringSet(KEY_WHITELIST, it.toSet()) }
        listFrom(values[KEY_BLOCKED_PREFIXES])?.let {
            editor.putStringSet(KEY_BLOCKED_PREFIXES, it.toSet())
        }
        mapFrom(values[KEY_LABELS])?.let { editor.putString(KEY_LABELS, JSONObject(it).toString()) }
        editor.apply()
    }

    @Synchronized
    fun addLog(decision: Decision) {
        val logs = readLogArray()
        val item = JSONObject()
            .put("number", decision.number)
            .put("category", decision.category)
            .put("blocked", decision.blocked)
            .put("action", decision.action.wireName)
            .put("reason", decision.reason)
            .put("timestamp", System.currentTimeMillis())
        val next = JSONArray().put(item)
        for (index in 0 until minOf(logs.length(), MAX_LOGS - 1)) {
            next.put(logs.optJSONObject(index))
        }
        preferences.edit().putString(KEY_LOGS, next.toString()).apply()
    }

    fun getLogs(): List<Map<String, Any>> {
        val logs = readLogArray()
        return (0 until logs.length()).mapNotNull { index ->
            logs.optJSONObject(index)?.let {
                mapOf(
                    "number" to it.optString("number", "未知号码"),
                    "category" to it.optString("category", "normal"),
                    "blocked" to it.optBoolean("blocked", false),
                    "action" to it.optString(
                        "action",
                        if (it.optBoolean("blocked", false)) "block" else "allow",
                    ),
                    "reason" to it.optString("reason", ""),
                    "timestamp" to it.optLong("timestamp", 0L),
                )
            }
        }
    }

    fun clearLogs() = preferences.edit().remove(KEY_LOGS).apply()

    fun recentCallCount(rawNumber: String?, sinceMillis: Long): Int {
        val number = CallDecisionEngine.normalize(rawNumber)
        if (number.isEmpty()) return 0
        val logs = readLogArray()
        return (0 until logs.length()).count { index ->
            val item = logs.optJSONObject(index) ?: return@count false
            item.optLong("timestamp", 0L) >= sinceMillis &&
                CallDecisionEngine.normalize(item.optString("number")) == number
        }
    }

    private fun readLogArray(): JSONArray = try {
        JSONArray(preferences.getString(KEY_LOGS, "[]"))
    } catch (_: Exception) {
        JSONArray()
    }

    private fun readLabels(): Map<String, String> = try {
        val objectValue = JSONObject(preferences.getString(KEY_LABELS, "{}") ?: "{}")
        objectValue.keys().asSequence().associateWith { objectValue.optString(it, "normal") }
    } catch (_: Exception) {
        emptyMap()
    }

    private fun getStringSet(key: String): Set<String> =
        preferences.getStringSet(key, emptySet())?.toSet() ?: emptySet()

    private fun putBooleanIfPresent(
        editor: android.content.SharedPreferences.Editor,
        values: Map<*, *>,
        key: String,
    ) {
        (values[key] as? Boolean)?.let { editor.putBoolean(key, it) }
    }

    private fun listFrom(value: Any?): List<String>? = (value as? List<*>)
        ?.mapNotNull { it?.toString()?.trim() }
        ?.filter { it.isNotEmpty() }

    private fun mapFrom(value: Any?): Map<String, String>? = (value as? Map<*, *>)
        ?.entries
        ?.associate { it.key.toString() to it.value.toString() }

    companion object {
        private const val PREFERENCES = "screening_preferences"
        private const val KEY_ENABLED = "enabled"
        private const val KEY_BLOCK_FRAUD = "blockFraud"
        private const val KEY_BLOCK_MARKETING = "blockMarketing"
        private const val KEY_BLOCK_PRIVATE = "blockPrivate"
        private const val KEY_BLOCK_BANK = "blockBank"
        private const val KEY_BLOCK_CARRIER = "blockCarrier"
        private const val KEY_BUILT_IN_RULES = "builtInRulesEnabled"
        private const val KEY_REPEATED_CALL_PROTECTION = "repeatedCallProtection"
        private const val KEY_BLACKLIST = "blacklist"
        private const val KEY_WHITELIST = "whitelist"
        private const val KEY_BLOCKED_PREFIXES = "blockedPrefixes"
        private const val KEY_LABELS = "labels"
        private const val KEY_LOGS = "logs"
        private const val MAX_LOGS = 200
    }
}
