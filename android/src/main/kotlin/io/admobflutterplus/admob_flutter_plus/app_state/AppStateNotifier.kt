package io.admobflutterplus.admob_flutter_plus.app_state

import android.os.Handler
import android.os.Looper
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.ProcessLifecycleOwner
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Observes process-level foreground/background transitions via
 * [ProcessLifecycleOwner] and forwards them to Dart over an [EventChannel].
 *
 * Using the process lifecycle (rather than Flutter's `WidgetsBindingObserver`)
 * means showing another full-screen ad is not mistaken for the app being
 * backgrounded — essential for correct app open ad behavior.
 */
class AppStateNotifier(messenger: BinaryMessenger) :
    MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler,
    DefaultLifecycleObserver {

    private val methodChannel =
        MethodChannel(messenger, "admob_flutter_plus/app_state_method")
    private val eventChannel =
        EventChannel(messenger, "admob_flutter_plus/app_state_event")
    private val mainHandler = Handler(Looper.getMainLooper())

    private var eventSink: EventChannel.EventSink? = null
    private var observing = false

    init {
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
    }

    fun detach() {
        stopObserving()
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start" -> {
                startObserving()
                result.success(null)
            }
            "stop" -> {
                stopObserving()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    private fun startObserving() {
        if (observing) return
        observing = true
        mainHandler.post {
            ProcessLifecycleOwner.get().lifecycle.addObserver(this)
        }
    }

    private fun stopObserving() {
        if (!observing) return
        observing = false
        mainHandler.post {
            ProcessLifecycleOwner.get().lifecycle.removeObserver(this)
        }
    }

    override fun onStart(owner: LifecycleOwner) {
        eventSink?.success("foreground")
    }

    override fun onStop(owner: LifecycleOwner) {
        eventSink?.success("background")
    }
}
