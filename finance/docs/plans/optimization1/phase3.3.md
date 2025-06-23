
## Phase 3.3: Code Splitting (Deferred Loading)

This section details the plan to implement deferred loading for select features. The goal is to improve app startup time and reduce initial memory consumption by loading feature code only when it is needed.

### 3.3.1. Background & Rationale

This plan is based on the analysis of the app's architecture:

-   **Insight (Code Splitting):** The project's feature-first architecture using `go_router` is perfectly suited for deferred loading, but the current implementation loads all features at startup.
-   **Recommendation (Code Splitting):** Implement deferred loading using the `deferred as` keyword for features that are not critical for the initial user experience (e.g., Settings, Analytics). This will directly improve app startup time and reduce the initial memory footprint.

### 3.3.2. Change Severity & Impact Analysis

-   **Severity:** **High**.
-   **Impact:** This change directly and positively impacts a key performance metric: app startup time. The changes are primarily localized to the routing configuration.
-   **Complexity:** **Medium**. While the `deferred as` syntax is simple, implementing it correctly in `go_router` requires careful state management. A loading screen or indicator must be shown while the deferred library is loaded asynchronously, which adds complexity to the navigation logic. Choosing which features to defer also requires careful consideration of the user experience.

### 3.3.3. Affected Files

1.  `lib/app/router/app_router.dart`: This is the central file where routing logic will be modified.
2.  **Feature files**: The `import` statements for the pages of deferred features will be modified within `app_router.dart`.

### 3.3.4. Refactoring Procedure

The process involves identifying suitable features to defer and then modifying the router to handle the asynchronous loading of that feature's code.

```mermaid
graph TD
    A[Start: Identify Target Features for Deferral] --> B{Modify Imports in `app_router.dart`};
    B --> C[Wrap Route Builders in a Loader];
    C --> D[Implement `loadLibrary()` call];
    D --> E[Show Loading Indicator];
    E --> F{Thoroughly Test Navigation};
    F --> G[Rollout to other non-critical features];
    G --> H[End: Complete];

    style A fill:#28a745,color:#fff,stroke:#333
    style H fill:#28a745,color:#fff,stroke:#333
    style F fill:#ffc107,color:#000,stroke:#333
```

#### Step-by-Step Guide

1.  **Identify Target Features**:
    *   Analyze user flows and identify features that are not required immediately on app startup. Good candidates are often Settings, Analytics, or other secondary sections.
2.  **Modify Imports in Router**:
    *   In `lib/app/router/app_router.dart`, find the import statement for the main page of the feature you want to defer (e.g., `import 'package:finance/features/settings/presentation/pages/settings_page.dart';`).
    *   Change it to a deferred import: `import 'package:finance/features/settings/presentation/pages/settings_page.dart' deferred as settings_page;`.
3.  **Implement a Loading Wrapper**:
    *   The `GoRoute` builder for the deferred route can no longer instantiate the page directly.
    *   Wrap the page instantiation in a `FutureBuilder` or a custom stateful widget that calls `settings_page.loadLibrary()`.
    *   The `FutureBuilder`'s `builder` will show a `CircularProgressIndicator` while the connection state is `waiting`, and will build the actual `settings_page.SettingsPage()` once the future completes successfully.
4.  **Testing**:
    *   Launch the app and navigate to a non-deferred screen. Verify startup is faster (using profiling tools).
    *   Navigate to the deferred feature for the first time. Verify that a loading indicator is briefly shown, followed by the feature's page.
    *   Navigate away and back to the deferred feature. Verify that it now loads instantly, as the library is already in memory.
5.  **Rollout**:
    *   Once the pattern is proven and tested on one feature, repeat the process for other identified non-critical features.

### 3.3.5. Documentation Updates (`docs/README.md` & `NAVIGATION_ROUTING.md`)

This optimization introduces a powerful new performance pattern. The documentation must be updated to make developers aware of it and guide them on its correct implementation.

**1. Add a "Performance Recipe" to Main README:**

*   **File:** `docs/README.md`
*   **Location:** Section `06 · Common Tasks & Development Recipes 🍳`.
*   **Action:** Add a new row to the cookbook table for the task of optimizing startup time with deferred loading. This makes the pattern highly discoverable.
*   **Content to Add:**

| I need to... | Key Steps & Where to Look |
| --- | --- |
| ... | ... |
| **...improve app startup time?** | 1. **Identify:** Choose non-critical features to lazy-load.<br/>2. **Implement:** Use `deferred as` to load the feature's code on-demand in the router.<br/>3. **Guide:** Follow the detailed instructions in the [Navigation & Routing](NAVIGATION_ROUTING.md) guide under "Deferred Loading". |
| ... | ... |

**2. Add "Deferred Loading" Section to the Navigation Guide:**

*   **File:** `docs/NAVIGATION_ROUTING.md`
*   **Action:** Add a new, detailed section to this guide explaining what deferred loading is, why it's important, and how to implement it with `go_router`.
*   **Content to Add:**

    ```markdown
    ---
    
    ## Performance Optimization: Deferred Loading
    
    **Problem:** By default, all code for all application features is compiled and loaded into memory when the user starts the app. For large applications, this can significantly slow down the initial startup time.
    
    **Solution:** We use **deferred loading** (also known as lazy loading) to split our code into separate chunks. This allows us to load the code for certain features only when the user navigates to them for the first time. This technique is ideal for features that are not on the main screen, such as Settings or detailed analytics pages.
    
    ### How to Implement Deferred Loading with GoRouter
    
    We leverage Dart's `deferred as` syntax within our `app_router.dart` file.
    
    **Step 1: Change the Import to be Deferred**
    
    Identify the import for the page you want to lazy-load and change it from a regular import to a deferred one.
    
    -   **Before:**
        ```dart
        import 'package:finance/features/settings/presentation/pages/settings_page.dart';
        ```
    
    -   **After:**
        ```dart
        import 'package:finance/features/settings/presentation/pages/settings_page.dart' deferred as settings_page;
        ```
    
    **Step 2: Wrap the Route in a Loader Widget**
    
    Because the `settings` library now needs to be loaded asynchronously, you cannot directly instantiate the page. You must wrap it in a builder that can handle the loading process. A `FutureBuilder` is a good choice.
    
    -   **Before:**
        ```dart
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        )
        ```
    
    -   **After:**
        ```dart
        GoRoute(
          path: '/settings',
          builder: (context, state) {
            return FutureBuilder<void>(
              future: settings_page.loadLibrary(), // This triggers the load
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // When loaded, build the actual page
                  return settings_page.SettingsPage();
                } else {
                  // While loading, show a spinner
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            );
          },
        )
        ```
    
    This pattern ensures a smooth user experience by showing a loading indicator while the required code is downloaded and loaded into memory. Subsequent visits to the route will be instant, as the library will already be loaded.
    ```

---
