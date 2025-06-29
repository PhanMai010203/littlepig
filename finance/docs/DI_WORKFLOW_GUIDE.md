# Dependency Injection Workflow Guide – Injectable + GetIt

> Status: **Stable** · Last Reviewed: 2025-06-22  
> Maintainer: **Core Architecture Team**

This guide explains **how dependency injection (DI) works in the Finance App**,
from daily developer tasks to advanced environment configuration.  
If you only need a refresher, see the *Cheat-sheet* section at the end.

---

## 1. Architectural Overview

```
main.dart        →  configureDependencies()  (boot)          
                   ↓
GetIt container  ←  injectable generated init()              
                   ↓ (constructor injection)
Feature/UI Bloc ↔  Repositories ↔  Data Sources / Services
```

* **GetIt** is the runtime service-locator.
* **Injectable** generates the `getIt.init()` extension that registers
  everything **at compile-time** based on annotations – **no manual
  `register*()` calls** allowed.

---

## 2. Environments

Environment | Use-case | How to Activate
---|---|---
`prod` (default) | Real services & database | `await configureDependencies();`
`dev`            | Experimental or staging services | `await configureDependencies('dev');`
`test`           | In-memory database & mocks | `await configureDependenciesWithReset('test');`

### Adding an Environment-Specific Implementation

```dart
@Environment(Environment.dev)
@LazySingleton(as: AnalyticsService)
class DebugAnalyticsService implements AnalyticsService {
  // ...
}
```

Or use the shorthand constant pattern:

```dart
const staging = Environment('staging');

@staging
@Injectable(as: PaymentsGateway)
class StubPaymentsGateway extends PaymentsGateway {}
```

---

## 3. Annotating New Types

| Goal | Annotation | Notes |
| --- | --- | --- |
| **Factory** (new instance every time) | `@injectable` | Default – lightweight objects, BLoCs. |
| **Lazy Singleton** (create on first use) | `@lazySingleton` | Repositories, Services. |
| **Eager Singleton** (create at init) | `@singleton` | Heavyweight services that must be ready before UI. |

### Example – Repository

```dart
abstract class BudgetRepository {
  Stream<List<Budget>> watchBudgets();
}

@lazySingleton
class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl(this._db);
  final AppDatabase _db;
  // ...
}
```

The constructor parameter `AppDatabase` will be injected automatically as long
as `AppDatabase` is also registered (it is, via `RegisterModule`).

### 3-b. CategoryBloc – Eager Singleton Example _(NEW)_

`CategoriesBloc` is the canonical example of an **eager singleton** in the app.  It must be fully initialised before any feature that depends on categories interacts with the DI container.

```dart
@singleton
class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  CategoriesBloc(this._categoryRepository) : super(const CategoriesState.initial()) {
    // eager load
    add(const CategoriesEvent.loadCategories());
  }
}
```

Why eager?

* **Immediate availability** – `TransactionsBloc` uses the in-memory categories map during its own constructor.
* **Cache warming** – categories are fetched once, shared across the app, and refreshed via CRUD events.
* **Performance** – eliminates ~500 ms wait time on first navigation to `TransactionsPage`.

### How to Provide It in UI

```dart
MultiBlocProvider(
  providers: [
    BlocProvider.value(value: getIt<CategoriesBloc>()), // first!
    // …other blocs
  ],
  child: MyApp(),
);
```

### Testing Tip
If your test uses `configureDependenciesWithReset('test')`, the bloc will be registered automatically.  To avoid network calls in unit tests, consider providing a mock `CategoryRepository` in the test environment.

---

## 4. Registering 3rd-Party Types – `RegisterModule`

Use a **module** when you need to provide:

* Third-party objects (e.g. `SharedPreferences` / `Dio` client).
* Async singletons (`@preResolve`).
* Different implementations per environment.

```dart
@module
abstract class RegisterModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @lazySingleton
  GoogleSignIn get googleSignIn => GoogleSignIn(scopes: [
        'https://www.googleapis.com/auth/drive.file',
      ]);

  @Environment(Environment.test)
  @lazySingleton
  DatabaseService get testDbService => DatabaseService.forTesting();
}
```

> **Tip:** Keep business-logic classes *out* of the module – they should carry
> their own annotations.

---

## 5. Code Generation Workflow

1. **Edit or add annotations** in the source code.
2. Run the build:

```bash
# One-off build (CI & pre-commit)
flutter packages pub run build_runner build --delete-conflicting-outputs

# Continuous watch (local dev)
flutter packages pub run build_runner watch --delete-conflicting-outputs
```

3. Commit the generated changes (they live next to the source as
   `*.g.dart` / `injection.config.dart`). A CI script will fail if these files
   are out-of-date **or** modified by hand.

---

## 6. Testing Helpers

### `configureDependenciesWithReset`

Use this **primary** helper when you need a _fresh_ container inside a test:

```dart
setUp(() async {
  await configureDependenciesWithReset('test');
});
```

Internally it calls `getIt.reset()` then `configureDependencies(env)`.

### `configureTestDependencies` (Deprecated)

A thin wrapper maintained for backwards-compatibility:

```dart
@Deprecated('Use configureDependenciesWithReset("test") instead')
Future<void> configureTestDependencies() async {
  await configureDependenciesWithReset('test');
}
```

Feel free to migrate tests gradually – both helpers call the same underlying
logic.

---

## 7. Troubleshooting & FAQ

| Problem | Cause / Fix |
| --- | --- |
| `Unregistered type SomeService` | Missing annotation – add `@injectable` or include in `RegisterModule`. |
| Duplicate registration error | You called `configureDependencies()` twice without `reset()`. Use `configureDependenciesWithReset`. |
| Stale `injection.config.dart` | Run `build_runner build`; if issues persist run `build_runner clean` first. |
| Async singleton not awaited | Use `@preResolve` so the generator awaits the future. |

---

## 8. Cheat-sheet

* Annotate → `build_runner` → `configureDependencies()`
* Prefer constructor injection – never call `getIt` in business logic.
* Use environments to swap implementations.
* For tests call **`configureDependenciesWithReset('test')`**.
* Generated files are **read-only**.

---

Happy injecting! 🔌 