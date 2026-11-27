# iOS side of the review module (to build on a Mac)

Not built yet. It's a Godot 4 iOS plugin named `BaylandReview` with one method,
`requestReview()`, and the signal `review_finished(ran: bool)`, the same as Android, so
`BaylandStoreReview` needs no change.

- Call `AppStore.requestReview(in: windowScene)` (iOS 16+, StoreKit) or
  `SKStoreReviewController.requestReview(in:)` on the main thread, then emit
  `review_finished(true)`; emit `false` when there's no window scene.
- Apple shows the sheet at most three times in 365 days. It always shows in debug builds
  (without submitting anything) and never in TestFlight builds.
- Build it like the other Bayland iOS plugins (see bayland_unity_ads/ios_src), put the
  `.gdip` and xcframework in this folder, and add it to the export in `../../plugin.gd`.
