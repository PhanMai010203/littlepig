# 💡 Implementation Roadmap – Transactions, Budgets & Accounts

This roadmap groups the backend gaps identified for the upcoming UI/UX phase into **four incremental delivery phases**.  Each phase has its own detailed spec (see links below).

## 📌 Quick-Glance Checklist

Tick each box once the item is complete **and** its automated tests pass.

- [x] _Phase 1 – Account Colour Customisation_  ([spec](phase_1_account_color.md))
- [x] _Phase 2 – Manual-Add Budgets (Tx ↔ Budget link)_  ([spec](phase_2_manual_budget_link.md))
- [x] _Phase 3 – Partial Loan Collection / Settlement_  ([spec](phase_3_partial_loan_payments.md))
- [ ] _Phase 4 – Documentation Consolidation_  ([spec](phase_4_docs_cleanup.md))

### ✅ Acceptance Criteria (Phases 1–3)

- [x] Database migration runs cleanly on existing data
- [x] Unit + integration tests updated/added and **green** (`flutter test`)
- [x] Linter (`dart analyze`) shows **0 errors**
- [x] GitHub CI pipeline passes
- [x] Public documentation updated (`docs2/`)

---

## 🔄 *HEADS UP AI AGENT!!*

> Summarise the **current state** of Transactions, Budgets and Accounts and outline what remains for the next engineer before starting Phase <i>n</i>. 

Paste the generated summary at the top of each phase PR description.

---

## 📚 Phase Index

1. **Phase 1 – Account Colour Customisation**  
   Add `color` to `Account` table & entity, allow users to pick colours.
2. **Phase 2 – Manual-Add Budgets**  
   Establish explicit `transaction_budgets` link table; let "Manual-Add" budgets include only explicit links.
3. **Phase 3 – Partial Loan Payments**  
   Introduce `remaining_amount` semantics & sub-transaction records for partial collect/settle flows.
4. **Phase 4 – Docs Cleanup**  
   Merge `docs/` into `docs2/`, fix dead links, and document new features.

> Open the phase files for detailed design, step-by-step tasks, and code snippets. 