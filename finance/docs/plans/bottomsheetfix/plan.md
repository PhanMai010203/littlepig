# Plan: Bottom Sheet Performance & Animation Refactor

**Objective:** To refactor the `BottomSheetService` to eliminate keyboard-related animation jank, simplify the implementation by removing over-engineered components, and align it with modern Flutter best practices for a smooth, maintainable, and performant user experience.

**Owner:** AI Assistant
**Status:** Not Started
**Date:** $(date +%Y-%m-%d)

---

## Phase 1: Aggressive Simplification & Cleanup

**Goal:** Reduce complexity by removing all unnecessary code, performance-tracking cruft, and unused utility classes related to the bottom sheet. This provides a clean slate for the real-time animation fix.

### 1.1: Delete Unused Utility Files

**Action:** Delete the following files. Their functionality is either not needed or will be replaced by a simpler, more direct approach.

-   `lib/shared/utils/snap_size_cache.dart`
-   `lib/shared/utils/performance_optimization.dart` (ensure no other component depends on it, otherwise remove only bottom-sheet related code)
-   `lib/shared/utils/no_overscroll_behavior.dart` (The `.withNoOverscroll` extension is an unnecessary micro-optimization that adds a layer of complexity. Native behavior is sufficient.)

### 1.2: Strip `BottomSheetService` Implementation

**File to Modify:** `lib/shared/widgets/dialogs/bottom_sheet_service.dart`

**Actions:**
-   Remove all imports for the files deleted in step 1.1.
-   Delete the `_getOptimizedSnapSizes` method. The logic for snap sizes will be simplified and directly handled within `showCustomBottomSheet`.
-   Delete the `_handleSnapNotification` and `_triggerSnapFeedback` methods. Custom snap physics and haptic feedback are over-optimizations that add complexity and are not essential for the core functionality.
-   Remove all calls to `PerformanceOptimizations`, `SnapSizeCache`, `CachedMediaQueryData`, and `.withNoOverscroll()`.

> **⚠️ Warning:** This is a significant code removal. After this phase, the app will likely have compilation errors. This is expected and will be resolved in the subsequent phases. The primary goal here is to declutter.

### 📚 **Phase 1 Documentation**

-   **Reference:**
    -   [File Structure Guide](../../FILE_STRUCTURE.md) - To understand the location of the files being modified/deleted.
    -   [UI Animation Framework](../../UI_ANIMATION_FRAMEWORK.md) - To understand the project's philosophy on performance and animations.

-   **To Update After This Phase:**
    -   `docs/FILE_STRUCTURE.md`: Remove entries for the deleted files.

---

## Phase 2: Implement Real-Time Keyboard Tracking

**Goal:** Introduce a new, simple widget that synchronizes the bottom sheet's movement perfectly with the keyboard's animation, eliminating all jank.

### 2.1: Create `_KeyboardAwareBottomSheet` Widget

**File to Modify:** `lib/shared/widgets/dialogs/bottom_sheet_service.dart`

**Action:** Add the following private widget inside the `bottom_sheet_service.dart` file. This widget is the core of the fix.

```dart
/// A private widget that rebuilds in sync with keyboard animations,
/// moving the sheet content up and down smoothly.
class _KeyboardAwareBottomSheet extends StatelessWidget {
  const _KeyboardAwareBottomSheet({
    required this.child,
    required this.resizeForKeyboard,
  });

  final Widget child;
  final bool resizeForKeyboard;

  @override
  Widget build(BuildContext context) {
    if (!resizeForKeyboard) {
      return child;
    }

    // This is the magic. `MediaQuery.viewInsetsOf(context)` provides a real-time,
    // animated value of the keyboard's height. By using it directly in the
    // build method, this widget rebuilds every frame of the keyboard animation.
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;

    // We use a Stack to place the sheet content on top of a colored spacer.
    // As the keyboard animates up, the spacer grows and the sheet content
    // is pushed up by the padding. This creates a seamless, connected animation.
    return Stack(
      children: [
        // This spacer fills the space behind the keyboard, preventing any
        // visual gaps during the animation.
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: keyboardHeight,
            // Use the sheet's background color for a seamless look.
            color: Theme.of(context).bottomSheetTheme.backgroundColor ??
                   Theme.of(context).colorScheme.surface,
          ),
        ),
        // The actual sheet content is padded from the bottom by the
        // exact height of the keyboard, causing it to slide up perfectly.
        Padding(
          padding: EdgeInsets.only(bottom: keyboardHeight),
          child: child,
        ),
      ],
    );
  }
}
```

### 📚 **Phase 2 Documentation**

-   **Reference:**
    -   [UI Text Input & Focus Management](../../UI_TEXT_INPUT_FOCUS_MANAGEMENT.md) - For context on how keyboard interactions are handled elsewhere.
    -   [UI Dialogs and Popups](../../UI_DIALOGS_AND_POPUPS.md) - For general principles on popups within the app.

-   **To Update After This Phase:**
    -   (None) - This is an internal implementation detail. The patterns will be documented in the next phase.

---

## Phase 3: Integration, Refinement & Testing

**Goal:** Integrate the new keyboard-aware widget into the bottom sheet builders, remove the old reactive logic, and ensure the entire `BottomSheetService` is stable and backwards-compatible.

### 3.1: Refactor Bottom Sheet Builders

**File to Modify:** `lib/shared/widgets/dialogs/bottom_sheet_service.dart`

**Actions:**
-   In `_showDraggableBottomSheet`:
    -   Remove the `AnimatedPadding` and the old `resizeForKeyboard` logic.
    -   Wrap the `Material` widget (the sheet container) with the new `_KeyboardAwareBottomSheet`.
    -   The `builder` function of `DraggableScrollableSheet` should return `_KeyboardAwareBottomSheet(child: sheetContainer, resizeForKeyboard: resizeForKeyboard)`.

-   In `_showStandardBottomSheet`:
    -   Remove the old `Padding` wrapper that used `MediaQuery.of(context).viewInsets`.
    -   Wrap the `content` widget with `_KeyboardAwareBottomSheet`.

-   In `showCustomBottomSheet`:
    -   Simplify the snap size logic. The `popupWithKeyboard` flag can be used to select a more aggressive initial snap size (e.g., `[0.9, 1.0]`) to prevent the sheet from appearing too small before the keyboard animates it up.
    -   Remove the old `_wrapWithKeyboardAvoidance` method and its call site.

### 3.2: Regression Testing

**Action:** Thoroughly test all types of bottom sheets.

-   **Scenarios to test:**
    -   Simple content sheet (no text fields).
    -   Sheet with `TextField` or `TextFormField`. Tap to show keyboard, dismiss keyboard.
    -   Draggable sheet with snap points.
    -   Standard (non-draggable) sheet.
    -   Confirmation dialogs.
-   **Platforms:** Test on both a recent iOS simulator and a recent Android emulator to ensure consistent behavior.

> **⚠️ Precaution:** The key is to ensure that the public API of `BottomSheetService` and the `BottomSheetServiceExtension` on `BuildContext` have not been altered. All existing call sites should function without modification.

### 📚 **Phase 3 Documentation**

-   **Reference:**
    -   [UI Testing and Troubleshooting](../../UI_TESTING_AND_TROUBLESHOOTING.md)

-   **To Update After This Phase:**
    -   `docs/UI_PATTERNS_AND_BEST_PRACTICES.md`: Add a new section documenting the correct, simplified way to build keyboard-aware bottom sheets.
    -   `docs/UI_DIALOGS_AND_POPUPS.md`: Update to reflect the improved performance and behavior.
    -   `lib/shared/widgets/dialogs/bottom_sheet_service.dart`: Add clear comments explaining the new, simplified architecture and why the `_KeyboardAwareBottomSheet` approach is used. 