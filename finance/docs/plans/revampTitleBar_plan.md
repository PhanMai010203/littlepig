# Plan: Revamp PageTemplate Title Bar

This document outlines the plan to transform the static `AppBar` in `PageTemplate` into a dynamic, collapsible header that responds to user scrolling, as detailed in the user request.

## 1. Goal

The objective is to refactor `lib/shared/widgets/page_template.dart` to support a modern, scroll-aware app bar.

- **Initial State:** Large title, transparent background.
- **Scrolling State:** Title shrinks, background fades in (theme-aware).
- **Final State:** Small title, opaque background, pinned to the top.

## 2. Package & Library Investigation (Context7)

Based on initial analysis, this feature can likely be implemented using Flutter's built-in widgets, primarily `CustomScrollView`, `SliverAppBar`, and `ScrollController`. No third-party packages are anticipated to be necessary.

I will use Context7 to retrieve the latest official Flutter documentation for these widgets to ensure best practices are followed.

## 3. Implementation Phases

The project will be broken down into the following phases to manage complexity.

### Phase 1: Core `PageTemplate` Refactor & Proof of Concept

This phase focuses on rebuilding the `PageTemplate` foundation and proving its viability on a single screen.

1.  **Modify `PageTemplate`:**
    *   Convert `PageTemplate` from a `StatelessWidget` to a `StatefulWidget` to manage a `ScrollController`.
    *   Replace the `Scaffold`'s `appBar` and `body` with a `CustomScrollView`.
2.  **Introduce `SliverAppBar`:**
    *   Add a `SliverAppBar` inside the `CustomScrollView`.
    *   Configure it with an `expandedHeight` for the large title area and use `FlexibleSpaceBar` for the title itself.
    *   Set `pinned: true` so the bar remains visible.
3.  **Update Widget Contract:**
    *   The `body` property of `PageTemplate` will be changed. Instead of `Widget body`, it will become `List<Widget> slivers`. This is a necessary breaking change to accommodate the `CustomScrollView`.
4.  **Update `TransactionsPage`:**
    *   Refactor `lib/features/transactions/presentation/pages/transactions_page.dart` to use the new `PageTemplate`.
    *   Convert its `ListView.builder` into a `SliverList` to pass to the new `slivers` property. This will serve as the working example.

### Phase 2: Advanced Animations & Scroll-Aware Transitions

This phase implements the smooth visual transitions.

1.  **Add `ScrollController`:**
    *   Use the `ScrollController` initialized in Phase 1.
    *   Add a listener to the controller to track scroll offset.
2.  **Implement Opacity Transition:**
    *   In the listener, calculate the `SliverAppBar`'s background color opacity based on the scroll offset. The color will be derived from the current theme, making it "theme-aware."
    *   Use `setState` to rebuild the `SliverAppBar` with the new background color.
3.  **Refine Title Animation:**
    *   `FlexibleSpaceBar` handles the title shrinking automatically. This step will involve fine-tuning the animation and ensuring it looks correct with the opacity fade.

### Phase 3: Update All `PageTemplate` Usages

This phase ensures the rest of the application adopts the new `PageTemplate` without issues.

1.  **Global Search:** Perform a codebase-wide search for all usages of `PageTemplate`.
2.  **Refactor Pages:** For each usage:
    *   If the page body is a scrollable view (e.g., `ListView`, `GridView`), convert it to its `Sliver*` equivalent (`SliverList`, `SliverGrid`).
    *   If the page body is a non-scrolling widget, wrap it in a `SliverToBoxAdapter`.
    *   Pass the resulting sliver(s) to the `slivers` property of `PageTemplate`.

### Phase 4: Documentation Update

After the feature is fully implemented and tested, all relevant documentation will be updated.

1.  **Update Core Widget Guide:**
    *   Modify `docs/features/ui/2_core_widgets.md` to detail the new `PageTemplate` behavior, its new `slivers` property, and how to use it correctly.
2.  **Update UI Feature Index:**
    *   Review and update `docs/features/ui/index.md` to ensure the summary of the UI development guide is still accurate.
3.  **Update Master Index:**
    *   Review `docs/README.md` and update the UI section if any high-level changes are needed.

This phased approach ensures a controlled and systematic implementation, starting with a core refactor and progressively adding features and compatibility. 