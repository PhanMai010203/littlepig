# 🍭 Elastic, Queue-Based Global Snackbar – Implementation Plan

This document is the *actionable blueprint* for adding an elastic, queue-based global snackbar to the Finance App.  It follows the project's clean-architecture, theming, and animation conventions so any team member can implement the feature confidently.

---

## 0. High-Level Sequence

| Step | Goal |
|-----|------|
| **1** | Read the internal docs listed in §1 to refresh conventions & helpers. |
| **2** | Add external package deps ( §2 ) & run `flutter pub get`. |
| **3** | Scaffold the file structure shown in §3.1. |
| **4** | Implement the data model (§3.2). |
| **5** | Implement the `SnackbarService` API (§3.3). |
| **6** | Implement `GlobalSnackbarController` logic (§3.4 → §3.6). |
| **7** | Mount the overlay in `main.dart` (§3.8) & register the service. |
| **8** | Verify the checklist in §4, add widget/unit tests, and commit. |

*(If you are using **Taskmaster**: create a parent task "Global Snackbar" and expand it into the steps above.)*

---

## 1. Internal Docs to Read First

| Doc | Why it matters for this task |
|---|---|
| [UI_ANIMATION_FRAMEWORK.md](mdc:docs/UI_ANIMATION_FRAMEWORK.md) | Pre-built animation helpers (`FadeIn`, `SlideIn`, `TappableWidget`) & project-wide reduced-motion toggle. We'll plug **Elastic curves** into the same philosophy. |
| [UI_CORE_WIDGETS.md](mdc:docs/UI_CORE_WIDGETS.md) | Standards for `AppText`, colour helpers (`getColor`) and `PageTemplate` wrapper—keeps the snackbar visually consistent. |
| [UI_ARCHITECTURE_AND_THEMING.md](mdc:docs/UI_ARCHITECTURE_AND_THEMING.md) | Explains semantic colours / text styles so the snackbar adapts to light, dark and Material You palettes out-of-the-box. |
| [UI_PATTERNS_AND_BEST_PRACTICES.md](mdc:docs/UI_PATTERNS_AND_BEST_PRACTICES.md) | Shows preferred BLoC patterns and error/loading states—mirror the same conventions for the snackbar service. |
| [UI_DIALOGS_AND_POPUPS.md](mdc:docs/UI_DIALOGS_AND_POPUPS.md) | Demonstrates centralised `DialogService`; we will mimic this API with **`SnackbarService`**. |
| [UI_TESTING_AND_TROUBLESHOOTING.md](mdc:docs/UI_TESTING_AND_TROUBLESHOOTING.md) | Contains theme-compliance checklist & a widget-test template you can adapt for snackbar tests. |
| [UI_NAVIGATION.md](mdc:docs/UI_NAVIGATION.md) *(optional)* | Shows how global overlays coexist with `GoRouter` / page transitions—handy when deciding where to mount the overlay. |

> **Tip:** Skim each guide's *"Quick reference"* tables— they usually point to the exact classes/functions you will need.

---

## 2. External Packages / References

| Package | Purpose |
|---------|---------|
| [`sa3_liquid`](https://pub.dev/packages/sa3_liquid) *(optional)* | Provides the "goo / plasma" background effect (same look as Budget tiles). |
| [`pausable_timer`](https://pub.dev/packages/pausable_timer) | Pause/resume timer that delays dismissal while the user interacts. |
| [`collection`](https://pub.dev/packages/collection) | Gives a formal `Queue` API instead of rolling your own with `List`. |

`pubspec.yaml` excerpt:
```yaml
dependencies:
  sa3_liquid: ^1.0.1   # optional visual polish
  pausable_timer: ^0.1.0
  collection: ^1.17.0
```
Run: `flutter pub get`

---

## 3. Implementation Blueprint

All paths respect the clean-architecture layout described in [UI_ARCHITECTURE_AND_THEMING.md](mdc:docs/UI_ARCHITECTURE_AND_THEMING.md).

### 3.1. File Structure
```
lib/
└─ shared/
   └─ widgets/
      └─ global_snackbar/
         ├─ snackbar_message.dart          # Immutable data model
         ├─ snackbar_service.dart          # Global access API
         ├─ global_snackbar_controller.dart# Queue + animation logic
         └─ global_snackbar_widget.dart    # UI & gesture layer
```

### 3.2. Data Model – `snackbar_message.dart`
```dart
class SnackbarMessage {
  final String title;
  final String? description;
  final IconData? icon;
  final Duration duration;
  final VoidCallback? onTap;

  const SnackbarMessage({
    required this.title,
    this.description,
    this.icon,
    this.duration = const Duration(seconds: 4),
    this.onTap,
  });
}
```

### 3.3. Central Service – `snackbar_service.dart`
Mirrors the existing `DialogService` pattern.
```dart
class SnackbarService {
  static final _key = GlobalKey<GlobalSnackbarControllerState>();

  /// Should be called once from `main.dart` after the widget is inserted.
  static void register(GlobalKey<GlobalSnackbarControllerState> key) {
    _key.currentState ??= key.currentState;
  }

  static void show(
    SnackbarMessage msg, {
    bool skipQueue = false,
  }) {
    _key.currentState?.post(msg, skipQueue: skipQueue);
  }
}
```

### 3.4. Controller Logic – `global_snackbar_controller.dart`
Key responsibilities:
1. Maintain `Queue<SnackbarMessage>`.
2. Two `AnimationController`s: vertical (Y) elasticity & horizontal (X) subtle drag.
3. Handle *elastic curves* (`ElasticOutCurve(0.8)`).
4. Use `PausableTimer` to auto-dismiss but pause while the user is touching.
5. Expose `post()`, `_animateIn()`, and `_dismiss()` methods.

*(See reference code snippets in the hand-off package)*

### 3.5. UI / Gesture Layer – `global_snackbar_widget.dart`
* Implements `StatefulWidget` + `SingleTickerProviderStateMixin`.
* Uses `AnimatedBuilder` + `Transform.translate` to apply X & Y offsets.
* Wraps content in `TappableWidget` to respect global tap feedback settings.
* Reads semantic colours via `getColor(context, "primary")` etc.

Optional: Add a **PlasmaRenderer** background if animations are enabled (`!AppSettings.reduceAnimations`).

### 3.6. Gesture Handling
* On pointer **move**: update controllers, pause auto-dismiss timer.
* On pointer **up**: resume timer; snap back or dismiss if dragged >40 %.
* Fast fling upward (> 200 px/s) instantly triggers `_dismiss()`.

### 3.7. Theming & Accessibility
* Respect reduced-motion settings: if `AppSettings.reduceAnimations` is `true`, skip curves and set `_ctrlY.value = 0` / `1` instantly.
* Use semantic colours (`surface`, `onSurface`, `primary`) so the snackbar adapts to Material You.
* Apply safe-area padding (`MediaQuery.padding.top`).

### 3.8. Mounting the Overlay
Insert **once** in `main.dart` (or `app.dart` just above `MaterialApp.router`):
```dart
final snackbarKey = GlobalKey<GlobalSnackbarControllerState>();

runApp(
  AppLifecycleManager(
    child: Stack(
      children: [
        MyApp(),                       // existing MaterialApp.router
        GlobalSnackbar(controllerKey: snackbarKey),
      ],
    ),
  ),
);

SnackbarService.register(snackbarKey);
```

### 3.9. Usage Example
```dart
SnackbarService.show(
  const SnackbarMessage(
    title: "Saved!",
    description: "Your changes synced successfully",
    icon: Icons.check_circle,
    duration: Duration(seconds: 3),
  ),
);
```

---

## 4. Final Checklist & Testing Matrix

| Item | How to verify |
|------|---------------|
| Reduced-motion compliance | Toggle OS "Remove animations" → snackbar should appear/disappear *instantly* w/ no bounce. |
| Theme colours correct | Switch between light & dark themes → background & text remain readable and aesthetically consistent. |
| Safe-area aware | On notched devices, snackbar should start **below** status-bar padding. |
| Queue behaviour | Fire `show()` 5× quickly → notifications show sequentially with ~150 ms gap, none lost. |
| Gesture dismiss | Slow drag up (>40 %) or fast fling up (>200 px/s) dismisses snackbar. Horizontal drag gives subtle offset but does **not** dismiss. |
| Re-entrancy | While one snackbar is visible, calling `show()` enqueues instead of replacing. |
| Widget tests | Adapt example in [UI_TESTING_AND_TROUBLESHOOTING.md](mdc:docs/UI_TESTING_AND_TROUBLESHOOTING.md) → pump `GlobalSnackbar`, call `SnackbarService.show()`, `tester.pumpAndSettle()`, assert widget present then dismissed after duration. |
| Accessibility | Screen-reader focus remains on current screen; snackbar is `Semantics` labelled as *status update*. |
| Lint & format | Run `dart format .` & `dart analyze` – **0 issues**. |

---

### Next Enhancements (Post-MVP)
* Add shortcut helpers: `SnackbarService.showSuccess()` / `.showError()` with preset icons/colours.
* Auto-listen to BLoC error streams (e.g., `BudgetBloc`) to surface failures automatically.
* Vibrate on appear (`HapticFeedback.lightImpact`) when animations are enabled.
* Consider positioning variants (bottom snackbar, banner) using the same controller.

---

*Last updated: <!-- 2025-06-27 -->* 