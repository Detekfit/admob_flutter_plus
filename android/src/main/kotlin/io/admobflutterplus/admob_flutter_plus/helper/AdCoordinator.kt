package io.admobflutterplus.admob_flutter_plus.helper

import java.util.concurrent.atomic.AtomicBoolean

/**
 * Ensures at most one full-screen ad is presented at a time.
 *
 * Interstitial, rewarded, rewarded interstitial, and app open managers acquire
 * the coordinator before showing and release it when the ad is dismissed or
 * fails to show. This prevents overlapping full-screen presentations.
 */
object AdCoordinator {
    private val showing = AtomicBoolean(false)

    /** Attempts to acquire the full-screen slot. Returns `true` on success. */
    fun tryAcquire(): Boolean = showing.compareAndSet(false, true)

    /** Releases the full-screen slot. */
    fun release() {
        showing.set(false)
    }

    /** Whether a full-screen ad is currently presented. */
    val isShowing: Boolean
        get() = showing.get()
}
