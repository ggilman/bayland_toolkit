class_name BaylandStoreReview
extends RefCounted
## The store's in-app rating sheet, asked for at good moments only (BaylandReviewTiming).
##
##     var review := BaylandStoreReview.new()
##     # at a good moment (e.g. a 3-star win, when no ad is about to show):
##     SaveManager.review = review.good_moment(SaveManager.review)
##     SaveManager.save_game()
##
## Android: the toolkit's BaylandReview plugin (switch on bayland_toolkit/review/enabled).
## iOS: a BaylandReview plugin with the same method, built on a Mac (review/ios/README.md).
## Elsewhere (the editor, desktop) nothing is shown and nothing is recorded, so testing on the
## PC never uses up an ask.

## After a request ran: true if the store's flow ran (it may still have shown nothing).
signal finished(ran: bool)

const SINGLETON := "BaylandReview"

var rules: Dictionary = BaylandReviewTiming.RULES
var _plugin: Object

func _init(custom_rules: Dictionary = {}) -> void:
	rules = BaylandReviewTiming.RULES.merged(custom_rules, true)
	if OS.get_name() in ["Android", "iOS"] and Engine.has_singleton(SINGLETON):
		_plugin = Engine.get_singleton(SINGLETON)
		if _plugin.has_signal("review_finished"):
			_plugin.connect("review_finished", func(ran: bool) -> void: finished.emit(ran))

## Whether the store's sheet can be asked for on this device.
func available() -> bool:
	return _plugin != null

## Counts a good moment and asks for a rating when the timing rules allow. Returns the state to
## save (it changes on every call). `now` is for tests.
func good_moment(state: Dictionary, now: float = Time.get_unix_time_from_system()) -> Dictionary:
	var out := BaylandReviewTiming.note_moment(state, now)
	if available() and BaylandReviewTiming.should_ask(out, now, rules):
		out = BaylandReviewTiming.record_ask(out, now)
		_plugin.call("requestReview")
	return out
