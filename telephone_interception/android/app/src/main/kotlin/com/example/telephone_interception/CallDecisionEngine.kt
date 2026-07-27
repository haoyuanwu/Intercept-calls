package com.example.telephone_interception

enum class DecisionAction(val wireName: String) {
    ALLOW("allow"),
    SILENCE("silence"),
    BLOCK("block"),
}

data class ScreeningPolicy(
    val enabled: Boolean,
    val blockFraud: Boolean,
    val blockMarketing: Boolean,
    val blockPrivate: Boolean,
    val blockBank: Boolean,
    val blockCarrier: Boolean,
    val builtInRulesEnabled: Boolean,
    val repeatedCallProtection: Boolean,
    val blacklist: Set<String>,
    val whitelist: Set<String>,
    val blockedPrefixes: Set<String>,
    val labels: Map<String, String>,
)

data class Decision(
    val number: String,
    val category: String,
    val action: DecisionAction,
    val reason: String,
) {
    val blocked: Boolean get() = action == DecisionAction.BLOCK
}

class CallDecisionEngine {
    fun evaluate(
        rawNumber: String?,
        policy: ScreeningPolicy,
        recentCallCount: Int = 0,
    ): Decision {
        val number = normalize(rawNumber)
        if (!policy.enabled) return decision(number, NORMAL, DecisionAction.ALLOW, "防护已暂停")
        if (number.isEmpty()) {
            return decision(
                "未知号码",
                PRIVATE,
                if (policy.blockPrivate) DecisionAction.BLOCK else DecisionAction.ALLOW,
                if (policy.blockPrivate) "已拦截隐藏号码" else "隐藏号码已放行",
            )
        }

        if (policy.blacklist.any { numbersMatch(it, number) }) {
            return decision(number, BLACKLIST, DecisionAction.BLOCK, "用户黑名单拦截")
        }
        if (policy.whitelist.any { numbersMatch(it, number) }) {
            return decision(number, WHITELIST, DecisionAction.ALLOW, "用户白名单放行")
        }
        if (policy.builtInRulesEnabled && isProtectedBankNumber(number)) {
            return decision(number, WHITELIST, DecisionAction.ALLOW, "银行官方号码保护放行")
        }

        val matchedPrefix = longestMatchingPrefix(number, policy.blockedPrefixes)
        if (matchedPrefix != null) {
            return decision(number, PREFIX, DecisionAction.BLOCK, "命中用户号段 $matchedPrefix")
        }

        val labelled = policy.labels.entries.firstOrNull { numbersMatch(it.key, number) }?.value
        if (labelled != null) return labelledDecision(number, labelled, policy)

        if (policy.builtInRulesEnabled) {
            builtInDecision(number, policy, recentCallCount)?.let { return it }
        }
        return decision(number, NORMAL, DecisionAction.ALLOW, "未命中规则，默认放行")
    }

    private fun builtInDecision(
        number: String,
        policy: ScreeningPolicy,
        recentCallCount: Int,
    ): Decision? {
        if (number.startsWith("+") || number.startsWith("00")) {
            return decision(number, FRAUD, DecisionAction.BLOCK, "境外来电规则")
        }
        val virtualPrefix = longestMatchingPrefix(number, BuiltInCallRules.p0VirtualPrefixes)
        if (virtualPrefix != null) {
            return decision(number, FRAUD, DecisionAction.BLOCK, "虚拟运营商高风险号段 $virtualPrefix")
        }
        if (number.length >= 8 && BuiltInCallRules.p95Prefixes.any(number::startsWith)) {
            return decision(number, MARKETING, DecisionAction.BLOCK, "95 长位营销号码")
        }

        val isGray = number in BuiltInCallRules.p1ExactNumbers ||
            BuiltInCallRules.p1Prefixes.any(number::startsWith) ||
            BuiltInCallRules.p95Prefixes.any(number::startsWith)
        if (!isGray) return null

        if (policy.repeatedCallProtection && recentCallCount >= 2) {
            return decision(number, GRAYLIST, DecisionAction.ALLOW, "1 小时内重复来电，紧急保护放行")
        }
        return decision(number, GRAYLIST, DecisionAction.SILENCE, "可疑客服或营销号码静音")
    }

    private fun labelledDecision(
        number: String,
        category: String,
        policy: ScreeningPolicy,
    ): Decision {
        val shouldBlock = when (category) {
            FRAUD -> policy.blockFraud
            MARKETING -> policy.blockMarketing
            BANK -> policy.blockBank
            CARRIER -> policy.blockCarrier
            else -> false
        }
        val action = if (shouldBlock) DecisionAction.BLOCK else DecisionAction.ALLOW
        return decision(number, category, action, "用户标记的${categoryName(category)}号码")
    }

    private fun longestMatchingPrefix(number: String, prefixes: Set<String>): String? = prefixes
        .map(::normalize)
        .filter { it.isNotEmpty() && number.startsWith(it) }
        .maxByOrNull { it.length }

    private fun numbersMatch(left: String, right: String): Boolean {
        val a = normalize(left)
        val b = normalize(right)
        return a.isNotEmpty() && b.isNotEmpty() && a == b
    }

    private fun isProtectedBankNumber(number: String): Boolean =
        number in BuiltInCallRules.bankWhitelist ||
            (number.length == 5 && number.startsWith("955"))

    private fun decision(
        number: String,
        category: String,
        action: DecisionAction,
        reason: String,
    ) = Decision(number, category, action, reason)

    private fun categoryName(category: String): String = when (category) {
        FRAUD -> "疑似诈骗"
        MARKETING -> "营销"
        BANK -> "银行"
        CARRIER -> "运营商"
        else -> "普通"
    }

    companion object {
        private const val NORMAL = "normal"
        private const val PRIVATE = "private"
        private const val WHITELIST = "whitelist"
        private const val BLACKLIST = "blacklist"
        private const val PREFIX = "prefix"
        private const val GRAYLIST = "graylist"
        private const val FRAUD = "fraud"
        private const val MARKETING = "marketing"
        private const val BANK = "bank"
        private const val CARRIER = "carrier"

        fun normalize(value: String?): String {
            val cleaned = value
                ?.trim()
                ?.replace(Regex("[^0-9+]"), "")
                ?: return ""
            if (cleaned == "+") return ""

            return when {
                cleaned.startsWith("+86") -> cleaned.drop(3)
                cleaned.startsWith("0086") -> cleaned.drop(4)
                cleaned.startsWith("86") && cleaned.length == 13 -> cleaned.drop(2)
                else -> cleaned
            }
        }
    }
}
