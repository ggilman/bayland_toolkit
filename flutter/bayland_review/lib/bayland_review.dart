/// The store's in-app rating sheet, asked for at good moments only.
///
/// ```dart
/// final review = StoreReview();
/// // at a good moment (e.g. right after the user saves something):
/// settings.review = await review.goodMoment(settings.review);
/// save(settings.review.toJson());
///
/// // or let the package keep the state in SharedPreferences:
/// await review.noteGoodMoment();
/// ```
library;

export 'src/review_timing.dart';
export 'src/store_review.dart';
