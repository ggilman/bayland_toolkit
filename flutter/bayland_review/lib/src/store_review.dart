import 'dart:convert';

import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'review_timing.dart';

/// Asks the store for its rating sheet (Google Play / App Store, through in_app_review) when
/// [ReviewTiming] says the moment is right. Never throws and never waits on the user.
class StoreReview {
  StoreReview({this.rules = const ReviewRules(), InAppReview? store, this.log})
      : _store = store ?? InAppReview.instance;

  final ReviewRules rules;
  final InAppReview _store;

  /// Optional logging hook (e.g. a `Logger('review').info`).
  final void Function(String message)? log;

  /// Counts a good moment and asks for a rating when the timing rules allow. Returns the state
  /// to save (it changes on every call). When the store isn't available (an emulator without
  /// Play, a desktop build), nothing is asked and no ask is used up.
  Future<ReviewState> goodMoment(ReviewState state, {DateTime? now}) async {
    final at = (now ?? DateTime.now()).toUtc();
    var out = ReviewTiming.noteMoment(state, at);
    if (!ReviewTiming.shouldAsk(out, at, rules)) return out;
    try {
      if (!await _store.isAvailable()) return out;
      out = ReviewTiming.recordAsk(out, at);
      log?.call('review requested');
      await _store.requestReview();
    } on Object catch (e) {
      log?.call('review request failed: ${e.runtimeType}');
    }
    return out;
  }

  /// Where [noteGoodMoment] keeps the state: SharedPreferences, on this device only.
  static const prefsKey = 'bayland_review';

  /// [goodMoment], with the state kept in SharedPreferences under [prefsKey]: for apps that
  /// don't store it themselves. Never throws.
  Future<void> noteGoodMoment({SharedPreferencesAsync? prefs, DateTime? now}) async {
    try {
      final p = prefs ?? SharedPreferencesAsync();
      final raw = await p.getString(prefsKey);
      final json = raw == null ? null : jsonDecode(raw);
      final state = ReviewState.fromJson(json is Map<String, Object?> ? json : null);
      final out = await goodMoment(state, now: now);
      await p.setString(prefsKey, jsonEncode(out.toJson()));
    } on Object catch (e) {
      log?.call('review state failed: ${e.runtimeType}');
    }
  }
}
