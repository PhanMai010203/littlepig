## 🛠️ GetIt DI Unification Plan

> Status: **DRAFT – v0.1**  
> Author: TaskMaster AI  
> Date: 2025-06-24

---

### 1. Problem Statement
Two parallel dependency-injection entry-points currently co-exist:

1. `lib/core/di/injection.dart → configureDependencies()` – **manual** registrations.
2. `lib/core/di/injection.config.dart → getIt.init()` – **code-generated** via _Injectable_.

This split leads to:
- Missing registrations (e.g. `DatabaseService`) when only the generated init is called – common in unit/widget tests.
- Stale, hand-edited generated file (manual edits committed to VCS).
- Potential duplicate-registration crashes once the generated file is updated.

### 2. Goal
Adopt **one authoritative DI setup** powered by _Injectable_: `getIt.init()` should wire **everything** needed for production _and_ tests. Manual wiring must be eliminated.

### 3. Guiding Principles
1. _Configuration-by-declaration_: move registrations into `@module` classes or annotate implementations/interfaces directly.
2. **No manual edits** inside generated files – run `build_runner` instead.
3. **Environment flags** (`test`, `dev`, `prod`) decide alternate implementations (e.g. in-memory DB for tests).
4. **No service-locator calls in global scope**; prefer constructor injection.

---

### 4. Work-Breakdown Structure
| # | Task | Owner | Complexity | Notes |
|---|------|-------|------------|-------|
| **Phase 1 – Audit & Annotation** |||||
| 1.1 | Catalogue every manual registration in `core/di/injection.dart` (≈ 60) and map to an *annotation or @module* target | ★★☆ | use spreadsheet | |
| 1.2 | Add `@LazySingleton` / `@Singleton` or `@Injectable(as: …)` to concrete impls:<br/>• `TransactionRepositoryImpl`<br/>• `AttachmentRepositoryImpl`<br/>• `CategoryRepositoryImpl`<br/>• `AccountRepositoryImpl`<br/>• `BudgetRepositoryImpl`<br/>• `CurrencyRepositoryImpl`<br/>• `BudgetCsvService`<br/>• `BudgetAuthService`<br/>• `BudgetFilterServiceImpl`<br/>• `BudgetUpdateServiceImpl`<br/>• `FilePickerService`<br/>• `CRDTConflictResolver`<br/>• `IncrementalSyncService` / `GoogleDriveSyncService`<br/>• `SchemaCleanupMigration` | ★★★ | annotate or create `feature_*.dart` modules | |
| 1.3 | Extend `core/di/register_module.dart` with:<br/>• `BudgetCsvService`, `BudgetAuthService`, `BudgetFilterService`, `BudgetUpdateService` factory/providers<br/>• `http.Client` moved here too | ★★☆ | keep async @preResolve where needed | |
| 1.4 | Run `dart run build_runner build` and iterate until `injection.config.dart` contains **all** above symbols | ★☆☆ | |
| **Phase 2 – Integration** |||||
| 2.1 | Replace bodies of `configureDependencies()` / `configureTestDependencies()` with a thin wrapper that only calls `getIt.init()` (plus environment flag) – *no manual registrations* | ★★☆ | keep backward-compat signature | |
| 2.2 | Update call-sites:<br/>• `main.dart`<br/>• `demo/*.dart`<br/>• `test/helpers/**` to call the new wrapper (or directly `getIt.init()`) | ★★☆ | |
| 2.3 | Regenerate tests helper `test/helpers/test_di.dart` so it passes `environment: 'test'` | ★☆☆ | |
| **Phase 3 – Clean-up & Quality Gates** |||||
| 3.1 | Delete manual registration blocks from `core/di/injection.dart`; keep only reset helpers | ★★☆ | after app boots green | |
| 3.2 | Add guard unit-test `di_sanity_test.dart` – fails when e.g. `!getIt.isRegistered<DatabaseService>()` | ★☆☆ | |
| 3.3 | Add pre-commit script / CI step that greps for edits in `*.config.dart` and fails if diff not empty | ★☆☆ | |
| 3.4 | Grep for `getIt<` at top-level scope & refactor to constructor injection (none found today except demo files, but keep gate) | ★★★ | |
| **Phase 4 – Documentation** |||||
| 4.1 | Expand *Dependency Injection* section in `docs/README.md` with new single-entry workflow | ★☆☆ | |
| 4.2 | Mark legacy helpers (`configureDependencies`) as deprecated in docstrings | ★☆☆ | |

---

### 5. Affected Files (initial scan)
- `lib/core/di/injection.dart` – will be simplified/deleted.
- `lib/core/di/injection.config.dart` – regenerate (DO NOT EDIT).
- `lib/core/di/register_module.dart` – expand significantly.
- Any feature/services needing `@injectable`/`@lazySingleton` annotations.
- `lib/main.dart`, `test/**`, `demo/**` – bootstrap changes.

(_Search commands used_: `grep -R "getIt<" lib | grep -v "Injection"` etc.)

---

#### 🔗 Complete File-Touch List (100 %)

_Core & DI_
- `lib/core/di/injection.dart`
- `lib/core/di/register_module.dart`
- `lib/core/di/injection.config.dart` (generated)

_Feature Repository Implementations_
- `lib/features/transactions/data/repositories/transaction_repository_impl.dart`
- `lib/features/transactions/data/repositories/attachment_repository_impl.dart`
- `lib/features/categories/data/repositories/category_repository_impl.dart`
- `lib/features/accounts/data/repositories/account_repository_impl.dart`
- `lib/features/budgets/data/repositories/budget_repository_impl.dart`
- `lib/features/currencies/data/repositories/currency_repository_impl.dart`

_Budget Services_
- `lib/features/budgets/data/services/budget_csv_service.dart`
- `lib/features/budgets/data/services/budget_auth_service.dart`
- `lib/features/budgets/data/services/budget_filter_service_impl.dart`
- `lib/features/budgets/data/services/budget_update_service_impl.dart`

_Core Services & Sync_
- `lib/core/services/file_picker_service.dart`
- `lib/core/services/database_service.dart` (if not kept via module)
- `lib/core/sync/incremental_sync_service.dart`
- `lib/core/sync/google_drive_sync_service.dart`
- `lib/core/sync/enhanced_incremental_sync_service.dart`
- `lib/core/sync/crdt_conflict_resolver.dart`
- `lib/core/database/migrations/schema_cleanup_migration.dart`

_App Entrypoints & Helpers_
- `lib/main.dart`
- `lib/demo/currency_demo.dart`
- `test/helpers/**` (create or update `test_di.dart`)
- Any test using `configureTestDependencies()`

_Build & Quality_
- `.github/workflows/ci.yml` (or equivalent) – add diff check step
- `test/di_sanity_test.dart` (new)

If additional implementations are discovered during Phase 1 grep (`/data/repositories/.*_impl.dart`), treat them identically.

---

### 6. Timeline
1. **Day 0** – Write & review plan (this doc).
2. **Day 1** – Module migration + build-runner regeneration.
3. **Day 2** – Fix compile errors, update entry-points/tests.
4. **Day 3** – Refactor globals, add guard tests & CI rule.
5. **Day 4** – Peer review & merge.

---

### 7. Risks & Mitigations
| Risk | Mitigation |
|------|------------|
| Duplicate registrations post-migration | Run app & tests with `—delete-conflicting-outputs`, use `getIt.reset()` in hot-reload.
| Hidden global getIt calls causing early access | Grep scan + CI check.
| Team manually editing generated files again | CI lint + README guideline.

---

### 8. Acceptance Criteria
- `flutter test` passes without needing `configureDependencies()`.
- No hand-edited lines in `injection.config.dart` (git diff clean after regen).
- Running `getIt.init()` alone provides `DatabaseService`, repositories, and blocs.
- Plan merged & documented.

---

_End of document_ 