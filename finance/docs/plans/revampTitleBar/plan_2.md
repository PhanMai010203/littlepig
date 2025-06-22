# Plan: Revamp PageTemplate Title Bar - Phase 2 (Fixes)

This document outlines the plan to fix and refine the new collapsible header in `PageTemplate`, addressing feedback on animation smoothness and overscroll behavior.

## 1. Goal

The objective is to fix two specific issues:

1.  **Smooth Opacity:** The app bar's background should fade in smoothly and gradually based on the scroll offset, not "snap" into view.
2.  **Overscroll Behavior:** The title bar area must not stretch when the user overscrolls. Only the list content should show the stretch effect.

## 2. Package & Library Investigation (Context7)

I will use Context7 to retrieve the latest official Flutter documentation for the following widgets and properties to ensure a robust and correct implementation:

-   `SliverAppBar`: Specifically, I will investigate the `stretch` property and its interaction with `FlexibleSpaceBar`.
-   `FlexibleSpaceBar`: I will look into the `stretchModes` property to understand how to control visual effects during an overscroll.
-   `ScrollController`: I will re-verify the listener implementation for calculating opacity to ensure it's optimal for smooth animations.

## 3. Implementation Plan

The fixes will be implemented in the following order.

### Step 1: Fix Smooth Opacity Transition

1.  **File to Modify:** `lib/shared/widgets/page_template.dart`
2.  **Action:** I will adjust the `_updateAppBarOpacity` method. The current logic calculates the opacity based on the scroll offset, but its application seems to be causing an abrupt change. I will refine the calculation to ensure the opacity interpolates linearly from `0.0` (fully transparent) when the header is expanded to `1.0` (fully opaque) when it is fully collapsed. This will produce the smooth fade-in effect you described.

### Step 2: Prevent Title Bar Overscroll Stretching

1.  **File to Modify:** `lib/shared/widgets/page_template.dart`
2.  **Action:** I will modify the `SliverAppBar` instance. Based on Flutter's documentation, the most direct way to prevent the app bar itself from stretching is to set its `stretch` property to `false`. This will stop the header from expanding during an overscroll gesture, while still allowing the scrollable content in the `slivers` list to exhibit the native stretch effect.

### Step 3: Documentation Update

While the public API of `PageTemplate` has not changed, the visual behavior has been significantly improved. I will update the documentation to reflect this polish.

1.  **File to Modify:** `docs/features/ui/2_core_widgets.md`
2.  **Action:** I will add a new bullet point to the "Key Features" list for the `PageTemplate` widget. The new line will highlight the corrected overscroll behavior, for example: "Resists stretching on overscroll for a clean, platform-native feel." This keeps the documentation aligned with the component's capabilities.
3.  **Review:** I will perform a quick review of `docs/features/ui/index.md` and `docs/README.md` to ensure no other documentation is affected. 