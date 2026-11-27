# Bayland Toolkit

Shared code for Bayland Blue's apps, one folder per platform. Each module is opt-in, so an app
carries only what it uses.

| Folder | For | How an app uses it |
|---|---|---|
| `godot/` | The Godot games | Git submodule at `addons/bayland_toolkit`; enable the plugin `res://addons/bayland_toolkit/godot/plugin.cfg` and switch modules on in Project Settings (`bayland_toolkit/<module>/enabled`). |
| `flutter/` | The Flutter apps | A git dependency per package (below); no submodule. |

Anything that isn't Godot carries a `.gdignore`, so a game's editor and exports skip it.

## Modules

### review: the store's in-app rating sheet

Asks for a rating at good moments only, with the same rules on both platforms: after at least
5 good moments (the app's own idea of one: a 3-star win, a saved countdown), at least 3 days
after the first one, at most once every 120 days and 3 times in all. Apps can change the
numbers. The stores cap how often their sheet really shows, and never say whether the user
rated. The state is the app's to keep on the device (not synced).

**Godot** (`godot/review/`): `BaylandStoreReview` and the pure `BaylandReviewTiming`.

```gdscript
var review := BaylandStoreReview.new()
# at a good moment, when no ad is about to show:
SaveManager.settings["review"] = review.good_moment(SaveManager.settings.get("review", {}))
SaveManager.save_game()
```

- Android: `review/android_src/` is a Godot 4 (v2) plugin over Google Play's In-App Review
  API. `JAVA_HOME=~/.jdks/temurin-17 ./gradlew assemble` (in `android_src/`) rebuilds
  `review/bin/BaylandReview-{debug,release}.aar`. The export needs the Gradle build.
- iOS: not built yet; see `godot/review/ios/README.md` (needs a Mac).
- Elsewhere (editor, desktop) nothing shows and no ask is used up.
- To test on a phone: Google only shows the sheet for an app installed from Play (internal
  testing works), with an account that hasn't reviewed it yet.

**Flutter** (`flutter/bayland_review/`): `StoreReview`, `ReviewTiming`, `ReviewState`, over
the `in_app_review` package.

```yaml
dependencies:
  bayland_review:
    git:
      url: https://github.com/ggilman/bayland_toolkit.git
      path: flutter/bayland_review
```

```dart
final review = StoreReview();
state = await review.goodMoment(state);   // save state.toJson()
```

`cd flutter/bayland_review && flutter test` runs its tests.

## Updating an app

Godot: `git -C addons/bayland_toolkit pull`, then commit the new submodule pointer.
Flutter: `flutter pub upgrade bayland_review`.
