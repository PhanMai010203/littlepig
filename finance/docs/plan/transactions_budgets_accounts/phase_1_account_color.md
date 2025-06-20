# Phase 1 – Account Colour Customisation

> **Priority**: HIGH | **Est. Effort**: 0.5 – 1 day | **Owner**: _backend_

## 1  Objectives

1. Add a `color` field to **Accounts** so users can personalise wallets (Bank, Cash, etc.).
2. Expose CRUD APIs for setting & updating the colour.
3. Propagate the new field through database, domain, data, presentation layers and Google-Drive sync.
4. Ship database migration + unit & integration tests.

## 2  Design Decisions

| Layer | Change |
|-------|--------|
| Drift Table | Add `color` **INT** column (`ARGB`) to `AccountsTable` with default `0xFF9E9E9E` (grey). |
| Entity | Add `Color color` to `Account` model (non-nullable). |
| Repository | • `createAccount`/`updateAccount` accept colour<br>• Add helper `getAccountsSortedByColor()` (optional). |
| Services | No change – colour is pure data. |
| Sync | Include `color` in event payloads + Drive serialisation. |

## 3  Step-by-Step Implementation

1. **Database Migration**  
   • Increment schema version (e.g. `5 → 6`).  
   • `m.addColumn(accountsTable, accountsTable.color);`  
   • In `AccountsTable` definition add `IntColumn get color => integer().withDefault(const Constant(0xFF9E9E9E))();`
2. **Domain Entity** (`Account`)  
   • Add `Color color` + update `copyWith`, `props`.  
   • Adjust all constructors in tests.
3. **Data Mapping**  
   • Update mappers in `account_repository_impl.dart` – convert `int` ↔ `Color`.
4. **DI / Service Locator** – no change.
5. **Sync Layer**  
   • Update `google_drive_sync_service.dart` (account serialisation) – include `color` field.  
   • Write migration code for remote records without a colour (default grey).
6. **UI placeholder**  
   • In `AccountCard`, tint background with `account.color` (optional early visual test).
7. **Testing**  
   • Unit: mapper round-trip preserves colour.  
   • Integration: create account → read account → expect same colour.  
   • Migration test: existing DB upgraded – new column has default value.

## 4  Risks & Mitigations

* **Old data without colour** – use default.  
* **Colour conversions** – always store ARGB int; convert using `Color(value)`.

## 5  Done Definition

- [ ] Schema version bumped & migration passes on `flutter test`.
- [ ] All layers compile; no analysis errors.
- [ ] >90% test coverage on new code.
- [ ] PR merged & roadmap checkbox ticked. 