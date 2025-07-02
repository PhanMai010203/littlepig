# Routing in Finance App

Our application uses the `go_router` package for declarative routing in Flutter. This approach allows us to handle deep linking and define clear navigation paths.

## Core Components

The routing implementation is primarily located in `lib/app/router/`.

-   **`app_router.dart`**: This is the heart of our navigation system. It configures the `GoRouter` instance with all the defined routes, including shell routes for persistent UI elements (like the bottom navigation bar) and individual routes for other pages. It also defines page transitions.

-   **`app_routes.dart`**: This file contains a class `AppRoutes` that holds all the route paths as static string constants. This prevents the use of "magic strings" for routes and provides a single source of truth for all navigation paths.

-   **`page_transitions.dart`**: This file defines custom page transitions used throughout the app, such as slide, fade, and scale transitions.

## Defining Routes

All routes are defined within the `GoRouter` configuration in `app_router.dart`.

### Shell Routes

For pages that share a common UI shell (like the main pages with the bottom navigation bar), we use a `ShellRoute`. The `MainShell` widget is used as the builder for this route.

### Standard Routes

Standard routes are defined as `GoRoute` objects. Each `GoRoute` has a `path`, a `name`, and a `pageBuilder`.

### Demo Page Routes

The application includes a comprehensive framework demo section. The routes for these pages are defined in `app_router.dart` as well.

-   `/demo`: The main framework demo page.
-   `/demo/slide-transition`: Demonstrates slide transitions.
-   `/demo/fade-transition`: Demonstrates fade transitions.
-   `/demo/scale-transition`: Demonstrates scale transitions.
-   `/demo/slide-fade-transition`: Demonstrates combined slide and fade transitions.

## Adding a New Route

To add a new route:

1.  Add a new route path constant to `lib/app/router/app_routes.dart`.
    ```dart
    static const String myNewPage = '/my-new-page';
    ```

2.  Add a new `GoRoute` to the routes list in `lib/app/router/app_router.dart`.
    ```dart
    GoRoute(
      path: AppRoutes.myNewPage,
      name: AppRoutes.myNewPage,
      pageBuilder: (context, state) => AppPageTransitions.platformTransitionPage(
        child: const MyNewPage(),
        name: state.name,
        key: state.pageKey,
      ),
    ),
    ```

3. Make sure to import the new page widget.

## Choosing the Right Transition

**Use Case Guidelines:**

- **`platformTransitionPage`** - Default choice, adapts to platform conventions
- **`noTransitionPage`** - For shell routes and performance-critical pages
- **`modalSlideTransitionPage`** - Fullscreen dialogs, settings pages, creation flows
- **`slideTransitionPage`** - Standard navigation between main app sections
- **`subtleSlideTransitionPage`** - Gentle transitions for related content
- **`horizontalSlideTransitionPage`** - Tab-like navigation, category switching
- **`slideFadeTransitionPage`** - Modal-like presentations that aren't fullscreen
- **`fadeTransitionPage`** - Web-optimized transitions
- **`scaleTransitionPage`** - Special emphasis, "zoom in" effects

**Performance Considerations:**

- Use `noTransitionPage` for pages that need instant loading
- Avoid complex transitions on low-end devices (handled automatically by animation settings)
- The animation system respects user preferences for reduced motion 