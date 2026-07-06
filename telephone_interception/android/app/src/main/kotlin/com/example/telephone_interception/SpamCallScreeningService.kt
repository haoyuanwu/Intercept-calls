package com.example.telephone_interception

import android.telecom.Call
import android.telecom.CallScreeningService
import android.os.Build

class SpamCallScreeningService : CallScreeningService() {
    override fun onScreenCall(callDetails: Call.Details) {
        val store = ScreeningStore(applicationContext)
        val number = callDetails.handle?.schemeSpecificPart
        val recentCalls = store.recentCallCount(
            number,
            System.currentTimeMillis() - REPEATED_CALL_WINDOW_MILLIS,
        )
        var decision = CallDecisionEngine().evaluate(number, store.readPolicy(), recentCalls)

        if (decision.action == DecisionAction.SILENCE && Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            decision = decision.copy(
                action = DecisionAction.ALLOW,
                reason = "${decision.reason}（当前系统不支持静音）",
            )
        }

        val responseBuilder = CallResponse.Builder()
            .setDisallowCall(decision.action == DecisionAction.BLOCK)
            .setRejectCall(decision.action == DecisionAction.BLOCK)
            .setSkipCallLog(false)
            .setSkipNotification(decision.action == DecisionAction.BLOCK)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            responseBuilder.setSilenceCall(decision.action != DecisionAction.ALLOW)
        }
        val response = responseBuilder.build()

        respondToCall(callDetails, response)
        store.addLog(decision)
    }

    private companion object {
        const val REPEATED_CALL_WINDOW_MILLIS = 60 * 60 * 1000L
    }
}
