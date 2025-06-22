# Plan: Global Currency Switching

This document outlines the plan to implement a global currency switching mechanism. When a user selects an account on the homepage, all monetary values across the app will update to reflect the selected account's currency, with amounts animating smoothly.

## 🎯 Goal

-   **Global State:** Establish a global state for the currently selected display currency.
-   **UI Synchronization:** All components displaying monetary values should listen to this state and update their currency and amount accordingly.
-   **Performant Animation:** Numerical amount changes will be animated with a "counter" (number rollup) effect, prioritizing performance.
-   **Seamless Integration:** The feature should integrate smoothly with the existing architecture, including the `CurrencyService` and BLoC patterns.
-   **Comprehensive Documentation:** The new system must be documented for future development.

---

## Phase 1: Global State Management for Selected Currency

The foundation of this feature is a centralized state manager that holds the currently selected account and broadcasts changes.

**Objective:**
-   Create a BLoC to manage the state of the selected account's currency.
-   Provide a mechanism for the UI to update this state.
-   Inject this BLoC at the top of the widget tree to make it available globally.

**Files to Modify/Create:**

1.  **`lib/core/services/global_currency_service.dart` (Create):** A service to abstract the logic. (Optional, can be handled in BLoC).
2.  **`lib/features/settings/presentation/bloc/global_currency_state.dart` (Create):**
    -   Define states: `GlobalCurrencyInitial`, `GlobalCurrencySelected`.
    -   The state will hold the selected `Account` object.
3.  **`lib/features/settings/presentation/bloc/global_currency_event.dart` (Create):**
    -   Define event: `SelectGlobalCurrency`.
4.  **`lib/features/settings/presentation/bloc/global_currency_bloc.dart` (Create):**
    -   Implement the BLoC to handle the `SelectGlobalCurrency` event and emit the new state.
    -   It will have an initial state, possibly loading the user's default account.
5.  **`lib/app/app.dart` (Modify):**
    -   Wrap the `MaterialApp` with a `BlocProvider` for the new `GlobalCurrencyBloc` to make it accessible throughout the app.
6.  **`lib/core/di/injection.dart` (Modify):**
    -   Register the `GlobalCurrencyBloc` as a singleton.

---

## Phase 2: Animated Counter Widget

A reusable, performant widget is needed to display the animated number transitions.

**Objective:**
-   Develop an `AnimatedCounter` widget that animates from an old numerical value to a new one.
-   The widget must be highly performant, using `AnimatedBuilder` to avoid unnecessary rebuilds.
-   It will be responsible for both animating the number and formatting it as a currency string using the `CurrencyService`.

**Files to Modify/Create:**

1.  **`lib/shared/widgets/animations/animated_counter.dart` (Create):**
    -   Will accept `amount`, `currencyCode`, and formatting options.
    -   Internally uses an `AnimationController` and a `Tween<double>`.
    -   It will call `CurrencyService.formatAmount` to display the animated value.
    -   This widget will be the primary UI component for displaying all monetary values that need to react to the currency switch.

---

## Phase 3: UI Integration

With the state management and animation widget in place, we will integrate them into the feature screens.

**Objective:**
-   Connect the `HomePage` account selection to the `GlobalCurrencyBloc`.
-   Refactor UI components that display money to use the `AnimatedCounter` and react to state changes from `GlobalCurrencyBloc`.

**Files to Modify/Create:**

1.  **`lib/features/home/widgets/account_card.dart` (or similar widget in `home_page.dart`) (Modify):**
    -   On tap, get the `GlobalCurrencyBloc` from the context and add a `SelectGlobalCurrency` event with the tapped account.
2.  **Identify and Refactor Target Widgets:**
    -   Perform a codebase search for usages of `CurrencyService.formatAmount` or `AccountCurrencyExtension.formatBalance`.
    -   Wrap relevant widgets with a `BlocBuilder<GlobalCurrencyBloc, GlobalCurrencyState>`.
    -   Inside the builder, use the `CurrencyService` to convert the widget's native amount to the new global currency.
    -   Replace static text displays with the new `AnimatedCounter` widget, feeding it the converted amount and new currency code.
3.  **Potential Target Files:**
    -   `lib/features/transactions/presentation/widgets/transaction_list_item.dart`
    -   `lib/features/budgets/presentation/widgets/budget_card.dart`
    -   `lib/features/home/presentation/pages/home_page.dart` (for summary sections)
    -   Any dashboard or financial summary widgets.

---

## Phase 4: Performance Tuning and Testing

Ensuring the animation is smooth across the app is critical.

**Objective:**
-   Profile the animation performance, especially on pages with many animated values.
-   Write tests to ensure the logic is correct.

**Files to Modify/Create:**

1.  **`test/shared/widgets/animations/animated_counter_test.dart` (Create):**
    -   Widget tests for the `AnimatedCounter` to verify it animates and formats correctly.
2.  **`test/features/settings/presentation/bloc/global_currency_bloc_test.dart` (Create):**
    -   Unit tests for the BLoC logic.
3.  **Performance Profiling:**
    -   Use the `AnimationPerformanceMonitor` widget (from `docs/features/ui/6_patterns_and_best_practices.md`) on heavy pages to check for jank.
    -   Use Flutter DevTools to profile widget rebuilds and CPU usage during the animation.

---

## Phase 5: Documentation Update

The final step is to document the new system for maintainability.

**Objective:**
-   Create a new guide for the global currency system.
-   Update existing UI and feature documentation to reference the new components and patterns.

**Files to Modify/Create:**

1.  **`docs/features/ui/8_global_currency_display.md` (Create):**
    -   A new, comprehensive guide explaining:
        -   The role of `GlobalCurrencyBloc`.
        -   How to use the `AnimatedCounter` widget.
        -   The end-to-end flow of currency switching.
        -   How to make new UI components compatible with this system.
2.  **`docs/features/ui/index.md` (Modify):**
    -   Add a link to the new `8_global_currency_display.md` guide.
3.  **`docs/features/ui/4_animation_framework.md` (Modify):**
    -   Add a section for the `AnimatedCounter` widget with a usage example.
4.  **`docs/features/accounts/index.md` (Modify):**
    -   Add a note explaining that selecting an account on the homepage now sets the global display currency for the app.
5.  **`docs/README.md` (Modify):**
    -   Update the main project index to include a reference to the new global currency feature documentation, maintaining the correct documentation hierarchy. 