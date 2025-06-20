# Phase 4 – Documentation Consolidation & Cleanup

> **Priority**: LOW-MEDIUM | **Effort**: 0.5 – 1 day | **Owner**: _docs / tech-writer_

## 1  Motivation

Two parallel trees (`docs/` and `docs2/`) create confusion and broken links.  We standardise on **`docs2/`** as the single source of truth.

## 2  Task List

1. **File Audit**  
   * List all `.md` in both folders; mark duplicates & unique files.
2. **Move or Merge**  
   * For duplicated topics keep the newest in `docs2/` and delete the old.  
   * For unique legacy docs, move to appropriate spot inside `docs2/` (keeping git history with `git mv`).
3. **Link Fixes**  
   * Search for broken links (`ripgrep "\]\(docs/"`).  
   * Update paths or create redirect stubs.
4. **Delete `docs/FILE_STRUCTURE.md` Reference**  
   * Replace with working `docs2/FILE_STRUCTURE.md` (or generate new).
5. **Update `docs2/index.md`**  
   * Remove obsolete sections.  
   * Add links to newly added Phase docs.
6. **CI Lint**  
   * Run markdown-link-check GitHub action to ensure no broken refs.

## 3  Acceptance Criteria

- [ ] `docs/` contains only migration notices or is removed entirely.
- [ ] `docs2/` passes markdown-link-check.
- [ ] All new features from Phases 1-3 are documented.
- [ ] Roadmap checkbox ticked. 