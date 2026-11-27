/// When to ask for a store rating. The same rules as the toolkit's Godot module
/// (godot/review/review_timing.gd): only after the app has been in use for a while and has
/// given the user several good moments, and rarely. The stores also cap how often their sheet
/// really shows, so asking is never a promise that it appears.
class ReviewRules {
  const ReviewRules({
    this.minDaysInUse = 3,
    this.minMoments = 5,
    this.minDaysBetween = 120,
    this.maxAsks = 3,
  });

  /// Since the first good moment was seen.
  final int minDaysInUse;

  /// Good moments since the last ask (the app's own idea: a saved item, a 3-star win).
  final int minMoments;
  final int minDaysBetween;

  /// Ever.
  final int maxAsks;
}

/// What the app keeps on the device (not synced) between launches.
class ReviewState {
  const ReviewState({this.firstSeen, this.moments = 0, this.asks = 0, this.lastAsked});

  final DateTime? firstSeen;
  final int moments;
  final int asks;
  final DateTime? lastAsked;

  ReviewState copyWith({DateTime? firstSeen, int? moments, int? asks, DateTime? lastAsked}) =>
      ReviewState(
        firstSeen: firstSeen ?? this.firstSeen,
        moments: moments ?? this.moments,
        asks: asks ?? this.asks,
        lastAsked: lastAsked ?? this.lastAsked,
      );

  Map<String, Object?> toJson() => {
        'first_seen': firstSeen?.toUtc().toIso8601String(),
        'moments': moments,
        'asks': asks,
        'last_asked': lastAsked?.toUtc().toIso8601String(),
      };

  factory ReviewState.fromJson(Map<String, Object?>? json) {
    if (json == null) return const ReviewState();
    DateTime? time(Object? v) => v is String ? DateTime.tryParse(v) : null;
    int count(Object? v) => v is num ? v.toInt() : 0;
    return ReviewState(
      firstSeen: time(json['first_seen']),
      moments: count(json['moments']),
      asks: count(json['asks']),
      lastAsked: time(json['last_asked']),
    );
  }
}

class ReviewTiming {
  const ReviewTiming._();

  /// Counts one good moment (and notes when the app was first seen).
  static ReviewState noteMoment(ReviewState s, DateTime now) =>
      s.copyWith(firstSeen: s.firstSeen ?? now, moments: s.moments + 1);

  static bool shouldAsk(ReviewState s, DateTime now, [ReviewRules r = const ReviewRules()]) {
    final first = s.firstSeen;
    if (first == null || now.difference(first) < Duration(days: r.minDaysInUse)) return false;
    if (s.moments < r.minMoments) return false;
    if (s.asks >= r.maxAsks) return false;
    final last = s.lastAsked;
    return last == null || now.difference(last) >= Duration(days: r.minDaysBetween);
  }

  /// The state after asking: one more ask, and the good moments start counting again.
  static ReviewState recordAsk(ReviewState s, DateTime now) =>
      s.copyWith(asks: s.asks + 1, lastAsked: now, moments: 0);
}
