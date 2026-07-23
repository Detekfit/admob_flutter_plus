package io.admobflutterplus.admob_flutter_plus.consent

import android.app.Activity
import android.content.Context
import com.google.android.ump.ConsentDebugSettings
import com.google.android.ump.ConsentInformation
import com.google.android.ump.ConsentRequestParameters
import com.google.android.ump.UserMessagingPlatform
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** Bridges the UMP (User Messaging Platform) consent SDK. */
class ConsentManager(messenger: BinaryMessenger, private val context: Context) :
    MethodChannel.MethodCallHandler {

    private val channel = MethodChannel(messenger, "admob_flutter_plus/consent")
    private val consentInformation: ConsentInformation =
        UserMessagingPlatform.getConsentInformation(context)

    var activity: Activity? = null

    init {
        channel.setMethodCallHandler(this)
    }

    fun detach() {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "requestConsentInfoUpdate" -> requestUpdate(call.arguments as? Map<*, *>, result)
            "getConsentStatus" -> result.success(statusName())
            "canRequestAds" -> result.success(consentInformation.canRequestAds())
            "isConsentFormAvailable" ->
                result.success(consentInformation.isConsentFormAvailable)
            "loadAndShowConsentFormIfRequired" -> loadAndShow(result)
            "showPrivacyOptionsForm" -> showPrivacyOptions(result)
            "resetConsent" -> {
                consentInformation.reset()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun requestUpdate(args: Map<*, *>?, result: MethodChannel.Result) {
        val activity = this.activity
        if (activity == null) {
            result.error("no_activity", "Consent requires a foreground Activity.", null)
            return
        }

        val paramsBuilder = ConsentRequestParameters.Builder()
        val underAge = args?.get("tagForUnderAgeOfConsent") as? Boolean ?: false
        paramsBuilder.setTagForUnderAgeOfConsent(underAge)

        val debugGeography = args?.get("debugGeography") as? String
        @Suppress("UNCHECKED_CAST")
        val testIds = args?.get("testDeviceHashedIds") as? List<String>
        if (debugGeography != null && debugGeography != "disabled") {
            val debug = ConsentDebugSettings.Builder(context)
                .setDebugGeography(
                    when (debugGeography) {
                        "eea" -> ConsentDebugSettings.DebugGeography.DEBUG_GEOGRAPHY_EEA
                        "regulatedUsState" ->
                            ConsentDebugSettings.DebugGeography.DEBUG_GEOGRAPHY_REGULATED_US_STATE
                        // "other", legacy "notEea", and any unknown non-disabled value.
                        else -> ConsentDebugSettings.DebugGeography.DEBUG_GEOGRAPHY_OTHER
                    },
                )
            testIds?.forEach { debug.addTestDeviceHashedId(it) }
            paramsBuilder.setConsentDebugSettings(debug.build())
        }

        consentInformation.requestConsentInfoUpdate(
            activity,
            paramsBuilder.build(),
            { result.success(null) },
            { error -> result.error(error.errorCode.toString(), error.message, null) },
        )
    }

    private fun loadAndShow(result: MethodChannel.Result) {
        val activity = this.activity
        if (activity == null) {
            result.error("no_activity", "Consent requires a foreground Activity.", null)
            return
        }
        UserMessagingPlatform.loadAndShowConsentFormIfRequired(activity) { formError ->
            if (formError != null) {
                result.error(formError.errorCode.toString(), formError.message, null)
            } else {
                result.success(null)
            }
        }
    }

    private fun showPrivacyOptions(result: MethodChannel.Result) {
        val activity = this.activity
        if (activity == null) {
            result.error("no_activity", "Consent requires a foreground Activity.", null)
            return
        }
        UserMessagingPlatform.showPrivacyOptionsForm(activity) { formError ->
            if (formError != null) {
                result.error(formError.errorCode.toString(), formError.message, null)
            } else {
                result.success(null)
            }
        }
    }

    private fun statusName(): String = when (consentInformation.consentStatus) {
        ConsentInformation.ConsentStatus.NOT_REQUIRED -> "notRequired"
        ConsentInformation.ConsentStatus.REQUIRED -> "required"
        ConsentInformation.ConsentStatus.OBTAINED -> "obtained"
        else -> "unknown"
    }
}
