# Post-Phase-4 Test-Failure Remediation Plan

> Scope: **Fix the 129 remaining test failures after Phase-4**  
> Status: **DRAFT – ready for task creation**  
> Author: o3-AI  
> Date: {{DATE}}

---

## 🔭 Overview
Phase-4 hardened the DI layer, but widget & animation tests are still red.  
The failures cluster into three technical areas that can be worked **in parallel**:

1. **Layout overflow** in `AccountCard` → 4-pixel bottom overflow.  
2. **Pending timers / flakey animations** in `AdaptiveBottomNavigation` tests (flutter_animate).  
3. **Missing localization keys** spam & occasional assertions in widget tests.

The table below maps each cluster to the failing test files and the concrete implementation areas.  Each cluster becomes its own _Phase_ so multiple contributors can work without blocking.

| Phase | Goal | Primary Code Targets | Primary Test Files (run first) |
|-------|------|----------------------|--------------------------------|
| **A** | Eliminate bottom overflow & size assertions in `AccountCard` | `lib/features/home/widgets/account_card.dart` | `test/features/home/home_page_test.dart` |
| **B** | Stabilise animation-driven tests by resolving pending timers & animation completion logic | `lib/features/navigation/presentation/widgets/adaptive_bottom_navigation*.dart`<br/> test helpers | `test/features/navigation/presentation/widgets/adaptive_bottom_navigation_test.dart` |
| **C** | Provide mock localization or add missing keys so warnings don't mask real failures | `test/helpers/localization_test_wrapper.dart` *(new)*<br/> update JSON keys if really missing | All widget tests using EasyLocalization (start with Phase-A/B files) |
| **D** | CI & quality wrap-up: run **entire** suite & re-enable `tools/check_generated_files.sh` in pipeline | n/a | `flutter test` (root) |

---

## 📌 Phase-A – **AccountCard Overflow Fix**

**Symptoms**
* `AccountCard` column overflows **4 px** on the bottom; assertion in multiple `home_page_test` cases.

**Implementation Notes**
1. Change `Column` to `mainAxisSize: MainAxisSize.min` **or** add `Expanded`/`Flexible` to push text.  
2. Tighten container height or let height auto-size.  
3. Wrap with `clipBehavior: Clip.hardEdge` as defensive fallback.

**Validation Workflow**
```bash
# Fast feedback while iterating
flutter test test/features/home/home_page_test.dart
```
All 40 cases inside this file must pass.

---

## 📌 Phase-B – **Animation Timer & Pending-Timer Fix**

**Symptoms**
* "Timer is still pending even after the widget tree was disposed"  
* Failing cases in AdaptiveBottomNavigation test groups.

**Approach**
1. Provide a **test helper** `await tester.pumpAndSettle(const Duration(seconds: 1));` after each tap / animation trigger.  
2. Expose a `kDisableAnimations` flag inside the widget; in tests set it to true.  
3. If needed, wrap `Animate` widgets in `TickerMode(enabled: !kDisableAnimations)`.

**Validation Workflow**
```bash
flutter test test/features/navigation/presentation/widgets/adaptive_bottom_navigation_test.dart
```
When green, re-run Phase-A & whole suite (Phase-D).

---

## 📌 Phase-C – **Localization Key & Warning Cleanup**

**Symptoms**
* `EasyLocalization` warnings for keys `[Home]`, `[Transactions]` … clutter logs and sometimes break golden diffs.

**Tasks**
1. Add a lightweight test-only localization delegate (`FakeLocalizationDelegate`) inside `test/helpers/` that returns the key itself.  
2. Wrap widget tests that rely on localization with the delegate via `pumpLocalizationWrapper(...)`.  
3. Audit `assets/translations/*.json` – add missing keys if they **should** exist in production.

**Validation**
Run both Phase-A & Phase-B focused suites after implementation to confirm warnings disappear and no new failures arise.

---

## 📌 Phase-D – **Full-Suite & CI Hardening**

* After A–C are merged, execute:
  ```bash
  flutter test  # expect 100 % green
  ./tools/check_generated_files.sh
  ```
* Re-enable or add CI step that fails if any test red or generated file diverges.
* Update documentation / badges.

---

## 👷🏻‍♀️ Task Checklist

| ID | Phase | Task | Est. Effort |
|----|-------|------|-------------|
| **A-1** | A | Refactor `AccountCard` layout (no overflow) | 1 h |
| **A-2** | A | Adjust golden/widget sizes if required | 0.5 h |
| **B-1** | B | Add `pumpAndSettle` calls / helper in nav tests | 0.5 h |
| **B-2** | B | Introduce `kDisableAnimations` flag & wire | 1 h |
| **B-3** | B | Ensure bounce/fade tests assert reliably | 0.5 h |
| **C-1** | C | Implement `FakeLocalizationDelegate` | 0.5 h |
| **C-2** | C | Wrap affected tests with localization helper | 1 h |
| **C-3** | C | Patch JSON translation files if needed | 0.5 h |
| **D-1** | D | Run full suite & update docs/badges | 0.5 h |

> **Total ETA:** ~6 developer-hours (parallel capable).

---

### How to Work in Parallel
* Branch per phase: `fix/phaseA-account-card`, `fix/phaseB-nav-animations`, etc.  
* Each branch targets only its scope; run **its** test file(s) locally before pushing.  
* After merge, immediately re-run full suite in CI.

---

## ✅ Definition of Done
1. `flutter test` (all files) passes locally & in CI.  
2. No console overflow or pending-timer assertions.  
3. `tools/check_generated_files.sh` passes.  
4. Documentation updated to mark Phase-4 as **fully completed**. 