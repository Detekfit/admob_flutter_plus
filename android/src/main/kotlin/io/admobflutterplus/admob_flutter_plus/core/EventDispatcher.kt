package io.admobflutterplus.admob_flutter_plus.core

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.MethodChannel

/**
 * Sends ad callbacks back to Dart over the shared [MethodChannel].
 *
 * Every callback carries an `adId` so the Dart [AdsChannel] can route it to the
 * correct ad instance. All invocations are posted to the main thread because
 * Flutter platform channel calls must originate there.
 */
class EventDispatcher(private val channel: MethodChannel) {
    private val handler = Handler(Looper.getMainLooper())

    fun send(method: String, adId: String, extra: Map<String, Any?> = emptyMap()) {
        val args = HashMap<String, Any?>()
        args["adId"] = adId
        args.putAll(extra)
        handler.post { channel.invokeMethod(method, args) }
    }

    /** Runs [block] on the main thread. */
    fun runOnMain(block: () -> Unit) {
        if (Looper.myLooper() == Looper.getMainLooper()) {
            block()
        } else {
            handler.post(block)
        }
    }
}
