package com.example.telephone_interception

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class CallDecisionEngineTest {
    private val engine = CallDecisionEngine()

    @Test
    fun `blocks number starting with configured prefix`() {
        val decision = engine.evaluate("+86 170-1234-5678", policy(prefixes = setOf("170")))

        assertTrue(decision.blocked)
        assertEquals("prefix", decision.category)
        assertEquals("命中用户号段 170", decision.reason)
    }

    @Test
    fun `whitelist takes priority over blocked prefix`() {
        val decision = engine.evaluate(
            "17012345678",
            policy(prefixes = setOf("170"), whitelist = setOf("17012345678")),
        )

        assertFalse(decision.blocked)
        assertEquals("whitelist", decision.category)
    }

    @Test
    fun `different numbers sharing last seven digits do not match whitelist`() {
        val decision = engine.evaluate(
            "13900138000",
            policy(whitelist = setOf("13800138000")),
        )

        assertEquals(DecisionAction.ALLOW, decision.action)
        assertEquals("normal", decision.category)
        assertEquals("未命中规则，默认放行", decision.reason)
    }

    @Test
    fun `different numbers sharing last seven digits do not match blacklist`() {
        val decision = engine.evaluate(
            "13900138000",
            policy(blacklist = setOf("13800138000")),
        )

        assertFalse(decision.blocked)
        assertEquals("normal", decision.category)
    }

    @Test
    fun `country code variants still match exact user numbers`() {
        val decision = engine.evaluate(
            "+86 138-0013-8000",
            policy(blacklist = setOf("8613800138000")),
        )

        assertTrue(decision.blocked)
        assertEquals("blacklist", decision.category)
    }

    @Test
    fun `does not block a number outside configured prefixes`() {
        val decision = engine.evaluate("16612345678", policy(prefixes = setOf("170")))

        assertFalse(decision.blocked)
        assertEquals("normal", decision.category)
    }

    @Test
    fun `protects official bank number before built in prefix rules`() {
        val decision = engine.evaluate("95588", policy())

        assertEquals(DecisionAction.ALLOW, decision.action)
        assertEquals("whitelist", decision.category)
    }

    @Test
    fun `protects any five digit 955 bank short number`() {
        val decision = engine.evaluate("95501", policy())

        assertEquals(DecisionAction.ALLOW, decision.action)
    }

    @Test
    fun `blacklist takes priority over protected bank number`() {
        val decision = engine.evaluate("95588", policy(blacklist = setOf("95588")))

        assertEquals(DecisionAction.BLOCK, decision.action)
        assertEquals("blacklist", decision.category)
        assertEquals("用户黑名单拦截", decision.reason)
    }

    @Test
    fun `blocks long 95 marketing number`() {
        val decision = engine.evaluate("9521234567", policy())

        assertEquals(DecisionAction.BLOCK, decision.action)
        assertEquals("marketing", decision.category)
    }

    @Test
    fun `silences enterprise hotline`() {
        val decision = engine.evaluate("4001234567", policy())

        assertEquals(DecisionAction.SILENCE, decision.action)
        assertEquals("graylist", decision.category)
    }

    @Test
    fun `allows third graylist call during repeated call window`() {
        val decision = engine.evaluate("4001234567", policy(), recentCallCount = 2)

        assertEquals(DecisionAction.ALLOW, decision.action)
        assertEquals("1 小时内重复来电，紧急保护放行", decision.reason)
    }

    @Test
    fun `blocks international number`() {
        val decision = engine.evaluate("+1 202 555 0100", policy())

        assertEquals(DecisionAction.BLOCK, decision.action)
        assertEquals("fraud", decision.category)
    }

    @Test
    fun `disabling built in rules leaves unknown number allowed`() {
        val decision = engine.evaluate("17112345678", policy(builtInRules = false))

        assertEquals(DecisionAction.ALLOW, decision.action)
    }

    private fun policy(
        prefixes: Set<String> = emptySet(),
        blacklist: Set<String> = emptySet(),
        whitelist: Set<String> = emptySet(),
        builtInRules: Boolean = true,
    ) = ScreeningPolicy(
        enabled = true,
        blockFraud = true,
        blockMarketing = true,
        blockPrivate = false,
        blockBank = false,
        blockCarrier = false,
        builtInRulesEnabled = builtInRules,
        repeatedCallProtection = true,
        blacklist = blacklist,
        whitelist = whitelist,
        blockedPrefixes = prefixes,
        labels = emptyMap(),
    )
}
