class_name BaylandReviewTiming
extends RefCounted
## When to ask for a store rating (pure, so it can be tested). The same rules as the toolkit's
## Flutter package (flutter/bayland_review): only after the app has been in use for a while and
## has given the player several good moments, and rarely. The stores also cap how often their
## sheet really shows, so asking is never a promise that it appears.
##
## `state` is the app's to keep (saved on the device, not synced): first_seen, moments, asks and
## last_asked (Unix seconds / counts). Missing keys count as zero / never.

const DAY := 86400.0

## Defaults; an app can pass its own to should_ask.
const RULES := {
	"min_days_in_use": 3,   # since the first good moment was seen
	"min_moments": 5,       # good moments (an app's own idea: a 3-star win, a saved item)
	"min_days_between": 120,
	"max_asks": 3,          # ever
}

## Counts one good moment (and notes when the app was first seen). Returns the new state.
static func note_moment(state: Dictionary, now: float) -> Dictionary:
	var out := state.duplicate()
	if float(out.get("first_seen", 0.0)) <= 0.0:
		out["first_seen"] = now
	out["moments"] = int(out.get("moments", 0)) + 1
	return out

static func should_ask(state: Dictionary, now: float, rules: Dictionary = RULES) -> bool:
	var r := RULES.merged(rules, true)
	var first := float(state.get("first_seen", 0.0))
	if first <= 0.0 or now - first < float(r["min_days_in_use"]) * DAY:
		return false
	if int(state.get("moments", 0)) < int(r["min_moments"]):
		return false
	if int(state.get("asks", 0)) >= int(r["max_asks"]):
		return false
	var last := float(state.get("last_asked", 0.0))
	return last <= 0.0 or now - last >= float(r["min_days_between"]) * DAY

## The state after asking: one more ask, and the good moments start counting again.
static func record_ask(state: Dictionary, now: float) -> Dictionary:
	var out := state.duplicate()
	out["asks"] = int(out.get("asks", 0)) + 1
	out["last_asked"] = now
	out["moments"] = 0
	return out
