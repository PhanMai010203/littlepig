# 📖 Finance App – Developer & AI Reference Index

Welcome to the **Finance App** code-base! This single page is your master entry-point for understanding the project's structure, major subsystems, and where to dive deeper.  Each section below gives a concise overview and links to a dedicated, full-length document.

> 📝 **Tip for AI tools** &rarr; Parse only this file for high-level context, then follow the links **on-demand** to fetch granular details.  This keeps token usage low while maintaining full knowledge coverage.

---

## 1. Architecture & File Layout

| 🔗 Link | Description |
|---------|-------------|
| [File Structure](FILE_STRUCTURE.md) | Clean-Architecture overview of the `lib/` source tree, core/feature/shared layers, and supporting tooling.  Start here to locate any Dart file or feature module. |

**Highlights**
- Root entry (`main.dart`), routing, theming, and DI setup.
- Layered breakdown (Presentation → Domain → Data).
- Directory summaries for database, services, sync, animation framework, etc.

When you are unsure *where* something lives, consult this map first.

---

## 2. Attachment Caching System

| 🔗 Link | Description |
|---------|-------------|
| [Attachment Caching System](features/ATTACHMENT_CACHING_SYSTEM.md) | Design & implementation details for intelligent 30-day local caching of camera images with Google Drive cloud storage. |

**Key Points**
- Schema changes (`isCapturedFromCamera`, `localCacheExpiry`).
- `CacheManagementService` & timer-driven cleanup.
- File access priority (Local → Drive → Error) and compression pipeline.

Refer here before working on attachments, storage, or cache eviction logic.

---

## 3. Database In-Memory Cache

| 🔗 Link | Description |
|---------|-------------|
| [Database Cache Usage Guide](features/DATABASE_CACHE_USAGE_GUIDE.md) | Phase 2 in-process cache for Drift/SQLite reads, offering 3-10× faster query responses with TTL-based invalidation. |

**Key Points**
- `DatabaseCacheService` + `CachedResult<T>` data model.
- `CacheableRepositoryMixin` for effortless repository integration.
- Invalidation helpers and performance benchmarks.

Essential reading for any feature that performs frequent database reads.

---

## 4. Currency Management System

| 🔗 Link | Description |
|---------|-------------|
| [Currency Usage Guide](features/CURRENCY_HOW_TO_USE.md) | Details the currency management system, including currency information, formatting, exchange rate conversion, and offline support. |

**Key Points**
- `CurrencyService` as the main entry point for all currency operations.
- Supports over 180 currencies with robust formatting and parsing.
- Real-time exchange rate conversion with support for custom rates.
- Offline-first design using cached rates and static fallbacks.

---

## 5. Budget Tracking System

| 🔗 Link | Description |
|---------|-------------|
| [Budget Usage Guide](features/BUDGET_HOW_TO_USE.md) | A guide to the budget module, covering creation, real-time updates, advanced filtering, and spending calculations. |

**Key Points**
- `BudgetRepository` for CRUD, `BudgetFilterService` for calculations, `BudgetUpdateService` for real-time updates.
- Advanced filters by wallets, categories, currencies, and exclusion of debt/credit transactions.
- Real-time streams automatically update budgets when transactions change.
- Includes helpers for CSV import/export and biometric protection.

---

## 6. Transaction Management System

| 🔗 Link | Description |
|---------|-------------|
| [Transaction System Hub](features/transactions/index.md) | A comprehensive guide to the transaction system, broken down into basics, attachments, analytics, and advanced features. |

**Key Points**
- Manages transactions with detailed notes for context.
- Fully integrated attachment system using Google Drive, with automatic image compression.
- Supports advanced types: subscriptions, recurring payments, loans (credit/debt), and different transaction states.
- Provides analytics methods for spending breakdowns by category or account.

---

## 7. UI Development Guide

| 🔗 Link | Description |
|---------|-------------|
| [UI Development Guide](features/ui/index.md) | A comprehensive guide to the UI framework, covering architecture, theming, reusable widgets, animations, navigation, and best practices. |

**Key Points**
- Detailed guides on core components like `PageTemplate` and `AppText`.
- Instructions for using the animation framework and dialog services.
- Best practices for state management, navigation, and testing.

---

## 8. How to Extend the Documentation

Have you added a significant feature?  Follow these steps:
1. Write or update a detailed spec under `docs/features/` or another appropriate folder.
2. Append a **one-sentence description** and link in a new section *here* (keep summaries < 4 lines).
3. Open a pull request.

> Consistent indexing keeps both humans and AI agents efficient 🚀

---

## 9. Getting Help & Contributing

- **Discussion**: Use project issues/PRs for questions.
- **Style**: Prefer concise Markdown, tables, and bullet lists.
- **AI Usage**: Large language models should ingest *only* this index initially.

---

*Last updated: <!-- YYYY-MM-DD -->* 