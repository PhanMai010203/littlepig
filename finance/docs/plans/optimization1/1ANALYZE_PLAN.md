# Comprehensive Performance Optimization Plan

## 1. Introduction

This document provides a detailed, phased plan to analyze and enhance the performance of the Finance App. The goal is to address existing bottlenecks, improve responsiveness, and establish best practices for maintaining a high-performance application.

This plan is tailored to the project's specific architecture, including `go_router` for navigation, `drift` for the database, `flutter_bloc` for state management, and the custom UI framework. Each phase is designed to be reviewed and implemented sequentially by the development team.

---

## Phase 1: Critical Fixes & Navigation Overhaul

**Goal:** Address the most noticeable sources of lag—page navigation and initial data loading—for immediate user experience improvement.

### 1.1. **Analyze & Optimize Bottom Navigation Rendering**
-   **Problem:** The current `AdaptiveBottomNavigation` widget uses multiple `AnimationController` instances and a complex `AnimatedBuilder` for the sliding indicator. This combination is resource-intensive, causing jank when switching tabs.
-   **Proposed Action:**
    1.  Replace the multi-controller system with a single, more efficient animation approach. Consider using a `TweenAnimationBuilder` or a single `AnimationController` that drives all visual changes.
    2.  Simplify the indicator animation. Instead of a complex curve, use a simpler `AnimatedPositioned` or `AnimatedContainer` which are less computationally expensive.
    3.  Investigate replacing the custom bounce animation on tap with a simpler, more performant feedback mechanism, or leverage the `flutter_animate` package for a pre-optimized effect.
-   **File(s) to Inspect:** `lib/features/navigation/presentation/widgets/adaptive_bottom_navigation.dart`.

### 1.2. **Implement Pagination and Lazy Loading in Transactions Page**
-   **Problem:** The `TransactionsPage` loads all transactions from the database at once. This does not scale and causes significant UI blocking and memory pressure as the number of transactions grows.
-   **Proposed Action:**
    1.  Modify `TransactionRepository` to support paginated data fetching (e.g., `getAllTransactions(page: int, limit: int)`).
    2.  Refactor `_TransactionsPageState` to fetch data in chunks.
    3.  Use a package like `infinite_scroll_pagination` to manage the UI, automatically handling scroll listeners, loading indicators, and error states. This will replace the existing `SliverList` with a `PagedSliverList`.
-   **File(s) to Inspect:** `lib/features/transactions/presentation/pages/transactions_page.dart`, `lib/features/transactions/domain/repositories/transaction_repository.dart`.

### 1.3. **Optimize Initial Data Loading and Caching**
-   **Problem:** The `DatabaseCacheService` is a simple time-to-live (TTL) cache. It does not cache individual queries or complex data sets efficiently, leading to redundant database reads for analytics and transaction lists.
-   **Proposed Action:**
    1.  Enhance `DatabaseCacheService` to store results of specific, expensive queries, not just generic data. The cache key should be based on the query parameters (e.g., `'transactions_account_1_date_2023-10'`).
    2.  Apply the `CacheableRepositoryMixin` to the `TransactionRepository` and `BudgetRepository`.
    3.  Implement cache invalidation logic. When a transaction is created or updated, invalidate relevant cached queries (e.g., all transaction lists and relevant budget calculations).
-   **File(s) to Inspect:** `lib/core/services/database_cache_service.dart`, `lib/core/repositories/cacheable_repository_mixin.dart`, and all data repositories.

---

## Phase 2: Advanced Rendering & Animation Performance

**Goal:** Overhaul the app's animation system and optimize complex list rendering to ensure smooth visuals and efficient GPU usage.

### 2.1. **Replace Custom Animation Framework with `flutter_animate`**
-   **Problem:** The project uses a custom animation framework (`FadeIn`, `ScaleIn`, etc.). While functional, it may not be as performant or feature-rich as mature community packages. Maintaining a custom framework adds overhead.
-   **Proposed Action:**
    1.  Add the `flutter_animate` package to the project.
    2.  Systematically replace all custom animation widgets (`lib/shared/widgets/animations/`) with their `flutter_animate` equivalents. The `.animate()` extension provides a clean and declarative API.
    3.  Refactor `PageTemplate` to remove the default `FadeIn` wrapper, applying animations more deliberately where needed.
-   **Benefit:** `flutter_animate` is highly optimized, reduces boilerplate, and provides more complex animation capabilities with better performance.

### 2.2. **Optimize `PageTemplate` Scroll Performance**
-   **Problem:** The `PageTemplate`'s `SliverAppBar` uses an `AnimatedBuilder` tied to a `ScrollController`, which can cause rebuilds of the entire app bar on every scroll frame.
-   **Proposed Action:**
    1.  Wrap the parts of the `SliverAppBar` that actually change (e.g., the background color `Container`) inside the `AnimatedBuilder`, not the entire app bar.
    2.  Wrap the `title` `Text` widget in a `RepaintBoundary` to prevent it from being repainted unnecessarily during the background color fade.
-   **File(s) to Inspect:** `lib/shared/widgets/page_template.dart`.

---

## Phase 3: Asset & Bundle Size Optimization

**Goal:** Reduce the application's install size and initial load time by optimizing assets and code delivery.

### 3.1. **Image and Attachment Optimization**
-   **Problem:** The `ATTACHMENTS_SYSTEM` guide describes file compression, but it's unclear if images are resized or optimized for display, or if this happens on the main thread.
-   **Proposed Action:**
    1.  Ensure all image processing (compression, resizing) happens in a separate isolate to avoid blocking the UI thread. Use `compute()` for this.
    2.  When displaying images, use a package like `cached_network_image` (if applicable) or implement a custom disk-based cache for local images to avoid re-reading and decoding.
    3.  Use appropriate image formats. Convert images to WebP where possible, as it offers better compression.
    4.  Implement thumbnail generation. For list views, display smaller, lower-resolution thumbnails instead of full-sized images.
-   **File(s) to Inspect:** `ATTACHMENTS_SYSTEM.md`, any code related to handling file attachments.

### 3.2. **Font Subsetting and Asset Analysis**
-   **Problem:** The app includes a large number of custom fonts. If the full font files are included, they can significantly increase the bundle size.
-   **Proposed Action:**
    1.  Use a tool to analyze the app's bundle size and identify the largest assets.
    2.  For fonts, consider font-subsetting to include only the glyphs actually used in the application.
    3.  Review all assets in the `assets/` directory and remove any that are unused.

### 3.3. **Implement Code Splitting (Deferred Loading)**
-   **Problem:** The entire application code is likely loaded on startup, increasing initial load time and memory usage.
-   **Proposed Action:**
    1.  Identify features that are not required for the initial startup sequence (e.g., Settings, Analytics, specific transaction details).
    2.  Use `deferred as` syntax to implement deferred loading for these features. This will split the compiled code into multiple parts that are loaded on-demand.
    3.  Refactor the `GoRouter` configuration to work with these deferred libraries.

---

## Phase 4: Long-Term Health & Monitoring

**Goal:** Establish tools and practices to proactively monitor performance and prevent regressions.

### 4.1. **Enhance Performance Monitoring Service**
-   **Problem:** The app has a placeholder `AnimationPerformanceService` but it is not integrated throughout the app.
-   **Proposed Action:**
    1.  Flesh out `AnimationPerformanceService` to track frame rates, especially during navigation transitions and heavy animations.
    2.  Integrate a performance monitoring service (like Firebase Performance Monitoring or Sentry) to capture real-world performance data from users' devices.
    3.  Create automated performance tests that run in CI/CD to catch regressions before they reach production. These tests should measure page load times and frame rates for critical user flows.
-   **File(s) to Inspect:** `lib/core/services/animation_performance_service.dart`.

### 4.2. **Review BLoC and State Management Patterns**
-   **Problem:** While `flutter_bloc` is efficient, complex screens can trigger unnecessary widget rebuilds if not implemented carefully.
-   **Proposed Action:**
    1.  Review key BLoCs and their corresponding UI. Ensure `BlocBuilder` is scoped to the smallest possible widget that needs to rebuild.
    2.  Use `buildWhen` conditions in `BlocBuilder` and `BlocListener` to prevent rebuilds/actions for irrelevant state changes.
    3.  For derived state that is expensive to calculate, compute it within the BLoC and include it in the state object, rather than re-computing it in the `build` method. 