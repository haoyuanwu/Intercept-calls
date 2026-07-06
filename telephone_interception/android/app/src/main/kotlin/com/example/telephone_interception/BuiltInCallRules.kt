package com.example.telephone_interception

/**
 * Versioned local rule data. Update this object independently from decision ordering.
 * Source snapshot: 清净来电-号段拦截规则.md, v1.0, 2026-07-06.
 */
object BuiltInCallRules {
    val p0VirtualPrefixes = setOf("170", "171", "162", "165", "167")
    val p95Prefixes = (2..9).map { "95$it" }.toSet()
    val p1Prefixes = setOf("400", "1010")
    val p1ExactNumbers = setOf("10001", "10085", "10016")

    val bankWhitelist = setOf(
        "95588", "95533", "95599", "10105599", "10109559", "10109599", "10109699",
        "4000295599", "4001295599", "4001995599", "4006995599", "95566", "95559",
        "95555", "4008205555", "95558", "4008895558", "95528", "95595", "95568",
        "95580", "4008895580", "95561", "95511", "95577", "95508", "95526",
    )
}
