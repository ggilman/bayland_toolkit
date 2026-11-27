package com.baylandblue.toolkit.review

import com.google.android.play.core.review.ReviewManagerFactory
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.SignalInfo
import org.godotengine.godot.plugin.UsedByGodot

/**
 * Google Play's in-app review sheet (developer.android.com/guide/playcore/in-app-review).
 *
 * requestReview() asks Play for a review flow and launches it. Play decides whether the sheet
 * really appears (it has its own quota) and never says whether the player rated, so
 * review_finished(true) only means the flow ran; false means it couldn't start (no activity,
 * no Play Store, offline). Either way the game carries on: never wait on it.
 */
class BaylandReview(godot: Godot) : GodotPlugin(godot) {

    override fun getPluginName(): String = "BaylandReview"

    override fun getPluginSignals(): Set<SignalInfo> = setOf(
        SignalInfo("review_finished", Boolean::class.javaObjectType),
    )

    @UsedByGodot
    fun requestReview() {
        val act = activity
        if (act == null) {
            emitSignal("review_finished", false)
            return
        }
        act.runOnUiThread {
            val manager = ReviewManagerFactory.create(act)
            manager.requestReviewFlow().addOnCompleteListener { request ->
                if (!request.isSuccessful) {
                    emitSignal("review_finished", false)
                    return@addOnCompleteListener
                }
                manager.launchReviewFlow(act, request.result).addOnCompleteListener {
                    emitSignal("review_finished", true)
                }
            }
        }
    }
}
