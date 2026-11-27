import 'package:bayland_review/bayland_review.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final t0 = DateTime.utc(2026, 11, 1);

  ReviewState moments(int n, DateTime at) {
    var s = const ReviewState();
    for (var i = 0; i < n; i++) {
      s = ReviewTiming.noteMoment(s, at);
    }
    return s;
  }

  test('waits for enough good moments and days in use', () {
    final s = moments(5, t0);
    expect(ReviewTiming.shouldAsk(s, t0), isFalse, reason: 'first day');
    expect(ReviewTiming.shouldAsk(s, t0.add(const Duration(days: 3))), isTrue);
    expect(ReviewTiming.shouldAsk(moments(4, t0), t0.add(const Duration(days: 30))), isFalse,
        reason: 'only 4 moments');
  });

  test('rarely: a gap between asks, and a cap', () {
    final day3 = t0.add(const Duration(days: 3));
    var s = ReviewTiming.recordAsk(moments(5, t0), day3);
    expect(s.moments, 0);
    for (var i = 0; i < 5; i++) {
      s = ReviewTiming.noteMoment(s, day3);
    }
    expect(ReviewTiming.shouldAsk(s, day3.add(const Duration(days: 119))), isFalse);
    expect(ReviewTiming.shouldAsk(s, day3.add(const Duration(days: 120))), isTrue);
    final capped = s.copyWith(asks: 3);
    expect(ReviewTiming.shouldAsk(capped, day3.add(const Duration(days: 400))), isFalse);
  });

  test('state survives a save', () {
    final s = ReviewTiming.recordAsk(moments(2, t0), t0);
    final back = ReviewState.fromJson(s.toJson());
    expect(back.asks, 1);
    expect(back.firstSeen, t0);
    expect(back.lastAsked, t0);
    expect(ReviewState.fromJson(null).moments, 0);
  });
}
