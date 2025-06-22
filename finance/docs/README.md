# 📖 Finance App – Developer Reference Hub

Welcome to the **Finance App** documentation. This single page is your _one-stop jump-off point_: every other guide lives only one click away. Search with **Ctrl/Cmd-F** or scan the tables below.

---

## 01 · File & Project Structure 📂
| 🔗 Link | Description |
|---|---|
| [File Structure Guide](architecture/FILE_STRUCTURE.md) | Clean-Architecture map of the `lib/` source tree, build tooling & generated code locations. |

---

## 02 · Core Infrastructure 🔧
| 🔗 Link | Description |
|---|---|
| [Database Caching](DATABASE_CACHING_GUIDE.md) | High-speed in-memory cache layer for Drift/SQLite queries. |
| [Data Sync Engine](DATA_SYNC_GUIDE.md) | CRDT-inspired event-sourcing engine for multi-device sync & conflict resolution. |
| [Currency Management](CURRENCY_MANAGEMENT_SYSTEM.md) | Currency data, formatting, conversion APIs & offline support. |

---

## 03 · Domain Features 💼
| 🔗 Link | Description |
|---|---|
| [Transactions – Basics](TRANSACTIONS_BASICS.md) | CRUD operations, models & core helpers. |
| [Transactions – Attachments](ATTACHMENTS_SYSTEM.md) | Local-first files with compression & Google Drive backup. |
| [Transactions – Analytics](TRANSACTIONS_ANALYTICS.md) | Analytics, search & filtering. |
| [Transactions – Advanced](TRANSACTIONS_ADVANCED_FEATURES.md) | Subscriptions, recurring payments, loan tracking. |
| [Transactions – States & Actions](TRANSACTIONS_STATES_AND_ACTIONS.md) | Lifecycle states (`pending`, `scheduled`, etc.) & context-aware actions. |
| [Transactions – Integration](TRANSACTIONS_INTEGRATION.md) | Validation, error handling & best-practice integration. |
| [Budget Tracking](BUDGET_TRACKING_SYSTEM.md) | Create, filter & monitor budgets with real-time streams. |
| [Account Management](ACCOUNTS_GUIDE.md) | Create accounts, set balances & currency handling. |

---

## 04 · UI & Navigation 🎨
| 🔗 Link | Description |
|---|---|
| [UI Architecture & Theming](UI_ARCHITECTURE_AND_THEMING.md) | Theme setup, adaptive layout & project-wide UI philosophy. |
| [UI Core Widgets](UI_CORE_WIDGETS.md) | Reusable widgets for text, buttons, pages & lists. |
| [UI Animation Framework](UI_ANIMATION_FRAMEWORK.md) | Rich animations with performance controls & examples. |
| [UI Navigation](UI_NAVIGATION.md) | Page transitions, navigation helpers & deep-link hooks. |
| [UI Dialogs & Pop-ups](UI_DIALOGS_AND_POPUPS.md) | Dialog, bottom-sheet & modal frameworks. |
| [UI Patterns & Best Practices](UI_PATTERNS_AND_BEST_PRACTICES.md) | State-management, accessibility & responsive design tips. |
| [UI Testing & Troubleshooting](UI_TESTING_AND_TROUBLESHOOTING.md) | Widget tests, golden images & common issue fixes. |
| [Navigation Overview](NAVIGATION_OVERVIEW.md) | Conceptual overview of navigation architecture. |
| [Navigation Routing](NAVIGATION_ROUTING.md) | Route table, deep-link formats & guard patterns. |

---

## 05 · When you need this … 💡
Need to… | Look here 👉
--- | ---
Add Google-Drive attachments | ATTACHMENTS_SYSTEM.md
Debug a cache miss | DATABASE_CACHING_GUIDE.md (Troubleshooting section)
Resolve a sync conflict | DATA_SYNC_GUIDE.md (# Conflict Resolution)
Format currency values | CURRENCY_MANAGEMENT_SYSTEM.md (# Formatting API)
Watch live budget updates | BUDGET_TRACKING_SYSTEM.md (# Real-Time Streams)
Create a deep-link route | NAVIGATION_ROUTING.md
Implement a slide-fade animation | UI_ANIMATION_FRAMEWORK.md (Examples)
Build a custom dialog | UI_DIALOGS_AND_POPUPS.md
Listen to transaction state changes | TRANSACTIONS_STATES_AND_ACTIONS.md
Schedule a recurring subscription | TRANSACTIONS_ADVANCED_FEATURES.md
Locate any generated Drift code | architecture/FILE_STRUCTURE.md (Tables section)
Run widget tests quickly | UI_TESTING_AND_TROUBLESHOOTING.md

---

## 06 · Contributing & Style 🤝
1. **Docs first** – update the relevant guide, then this README if a new link is needed.  Follow the order: leaf doc → README.
2. **Lint** – run `dart format .` & `dart analyze` before every PR.
3. **Branch naming** – `docs/<topic>` or `feature/<ticket>`.
4. **PR description** – list affected guides & link checks.

---

*Last updated: <!-- 2025-06-22 -->* 