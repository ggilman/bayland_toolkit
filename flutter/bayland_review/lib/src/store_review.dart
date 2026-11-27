import 'package:in_app_review/in_app_review.dart';

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
}
