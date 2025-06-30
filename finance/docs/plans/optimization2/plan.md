# TransactionsPage Performance Optimization Plan

## Overview
Eliminate 100% of lag when navigating to TransactionsPage by addressing:
- BLoC initialization bottlenecks (95% confidence)
- Database query inefficiencies (90% confidence) 
- UI state management overhead (85% confidence)
- Memory allocation issues (75% confidence)

## Phase 1: BLoC Initialization Optimization
**Target**: Reduce initialization time from ~500ms to <100ms

### Files to Modify:
- `lib/features/transactions/presentation/bloc/transactions_bloc.dart`
- `lib/features/categories/presentation/bloc/categories_bloc.dart` (create)
- `lib/app/app.dart` 
- `lib/core/di/injection.dart`

### Implementation Details:

#### 1.1 Create CategoryBloc Singleton
- **File**: `lib/features/categories/presentation/bloc/categories_bloc.dart`
- **Purpose**: Load categories once at app startup, maintain in memory
- **Key Points**:
  - Use `@singleton` annotation for DI
  - Load categories in constructor with immediate state emission
  - Implement cache-first strategy with 30min TTL
  - Handle category CRUD operations with cache invalidation

#### 1.2 Modify TransactionsBloc
- **File**: `lib/features/transactions/presentation/bloc/transactions_bloc.dart`
- **Changes**:
  - Remove `_categoryRepository` dependency
  - Inject `CategoryBloc` instead
  - Modify `_onLoadTransactionsWithCategories()`:
    - Use `categoryBloc.state.categories` instead of loading
    - Remove redundant `add(FetchNextTransactionPage())` call
    - Emit `TransactionsPaginated` with pre-loaded categories

#### 1.3 Update App Providers
- **File**: `lib/app/app.dart`
- **Changes**:
  - Add `CategoryBloc` to MultiBlocProvider
  - Ensure CategoryBloc is initialized before TransactionsBloc

### Warnings & Precautions:
- ⚠️ Ensure CategoryBloc is initialized before any category-dependent operations
- ⚠️ Test category CRUD operations don't break cache consistency
- ⚠️ Monitor memory usage with large category datasets

### Reference Documentation:
- `docs/DI_WORKFLOW_GUIDE.md` - Singleton registration patterns
- `docs/UI_PATTERNS_AND_BEST_PRACTICES.md` - BLoC state management

---

## Phase 2: Database Query Optimization  
**Target**: Reduce query time by 60% through server-side filtering

### Files to Modify:
- `lib/features/transactions/domain/repositories/transaction_repository.dart`
- `lib/features/transactions/data/repositories/transaction_repository_impl.dart`
- `lib/features/transactions/presentation/bloc/transactions_bloc.dart`

### Implementation Details:

#### 2.1 Enhanced Repository Interface
- **File**: `lib/features/transactions/domain/repositories/transaction_repository.dart`
- **Add Method**:
```dart
Future<List<Transaction>> getTransactionsByMonth({
  required int year,
  required int month,
  required int page,
  required int limit,
});
```

#### 2.2 Optimized Repository Implementation
- **File**: `lib/features/transactions/data/repositories/transaction_repository_impl.dart`
- **Implementation**:
  - Add month/year filtering at SQL level using `WHERE` clauses
  - Implement with `cacheRead()` using month-specific cache keys
  - Cache TTL: 3 minutes for month-specific data
  - Use `DateTime` range queries for precise month boundaries

#### 2.3 Update BLoC Logic
- **File**: `lib/features/transactions/presentation/bloc/transactions_bloc.dart`
- **Changes**:
  - Replace `getTransactions()` with `getTransactionsByMonth()`
  - Remove client-side month filtering in `_onFetchNextTransactionPage()`
  - Simplify `_consecutiveEmptyFetches` logic (server returns exact matches)

### Warnings & Precautions:
- ⚠️ Test month boundary edge cases (leap years, different timezones)
- ⚠️ Ensure cache invalidation works with month-specific keys
- ⚠️ Validate SQL query performance with large datasets

### Reference Documentation:
- `docs/DATABASE_CACHING_GUIDE.md` - Cache implementation patterns
- `docs/TRANSACTIONS_BASICS.md` - Repository usage patterns

---

## Phase 3: UI State Management Improvements
**Target**: Eliminate unnecessary rebuilds, improve perceived performance

### Files to Modify:
- `lib/features/transactions/presentation/pages/transactions_page.dart`
- `lib/features/transactions/presentation/widgets/transaction_loading_skeleton.dart` (create)
- `lib/features/transactions/presentation/bloc/transactions_state.dart`

### Implementation Details:

#### 3.1 Skeleton Loading UI
- **File**: `lib/features/transactions/presentation/widgets/transaction_loading_skeleton.dart`
- **Purpose**: Replace CircularProgressIndicator with structured skeleton
- **Components**:
  - Shimmer effect for transaction list items
  - Placeholder month selector
  - Animated skeleton cards matching transaction list layout

#### 3.2 Selective State Rebuilds
- **File**: `lib/features/transactions/presentation/pages/transactions_page.dart`
- **Changes**:
  - Replace `BlocConsumer` with `BlocSelector` for specific UI sections
  - Separate month selector rebuild logic from transaction list
  - Use `BlocListener` only for error states and snackbar notifications

#### 3.3 State Consolidation  
- **File**: `lib/features/transactions/presentation/bloc/transactions_state.dart`
- **Add State**:
```dart
class TransactionsLoadingWithSkeleton extends TransactionsState {
  final Map<int, Category> categories;
  final DateTime selectedMonth;
}
```

### Warnings & Precautions:
- ⚠️ Ensure skeleton UI matches final layout dimensions
- ⚠️ Test all state transition paths thoroughly
- ⚠️ Validate BlocSelector performance vs BlocBuilder

### Reference Documentation:
- `docs/UI_PATTERNS_AND_BEST_PRACTICES.md` - State management patterns
- `docs/UI_ANIMATION_FRAMEWORK.md` - Skeleton animation implementation

---

## Phase 4: Memory & Object Optimization
**Target**: Reduce memory allocations by 30%

### Files to Modify:
- `lib/features/transactions/presentation/bloc/transactions_bloc.dart`
- `lib/features/transactions/presentation/widgets/transaction_list.dart`

### Implementation Details:

#### 4.1 Optimized Grouping Algorithm
- **File**: `lib/features/transactions/presentation/bloc/transactions_bloc.dart`
- **Method**: `_groupTransactions()`
- **Optimizations**:
  - Use single-pass grouping instead of multiple iterations
  - Reuse existing `DateHeaderItem` objects where possible
  - Implement efficient date comparison using milliseconds
  - Reduce intermediate List/Map creations

#### 4.2 Pagination State Reuse
- **File**: `lib/features/transactions/presentation/bloc/transactions_bloc.dart`
- **Changes**:
  - Implement `PagingState.appendPage()` helper to avoid full state copying
  - Use object pooling for frequent `TransactionListItem` creations
  - Cache date header calculations

#### 4.3 Widget Optimization
- **File**: `lib/features/transactions/presentation/widgets/transaction_list.dart`
- **Changes**:
  - Add `RepaintBoundary` around transaction groups (already partially implemented)
  - Implement `AutomaticKeepAliveClientMixin` for visible items
  - Use `ValueKey` for stable widget identities

### Warnings & Precautions:
- ⚠️ Profile memory usage before/after changes
- ⚠️ Test object pooling doesn't cause state inconsistencies  
- ⚠️ Ensure date calculations handle timezone edge cases

### Reference Documentation:
- `docs/UI_PATTERNS_AND_BEST_PRACTICES.md` - Performance optimization patterns
- `docs/FILE_STRUCTURE.md` - Widget architecture guidelines

---

## Phase 5: Cache Strategy Enhancement
**Target**: Eliminate cold cache performance issues

### Files to Modify:
- `lib/core/services/cache_warming_service.dart` (create)
- `lib/main.dart`
- `lib/features/transactions/data/repositories/transaction_repository_impl.dart`

### Implementation Details:

#### 5.1 Cache Warming Service
- **File**: `lib/core/services/cache_warming_service.dart`
- **Purpose**: Proactively warm critical caches during app startup
- **Implementation**:
  - Load current month transactions in background
  - Pre-load categories with long TTL
  - Warm account and budget summary data
  - Use `@preResolve` for startup integration

#### 5.2 Startup Integration
- **File**: `lib/main.dart`
- **Changes**:
  - Initialize cache warming after DI configuration
  - Run cache warming in parallel with app startup
  - Handle warming failures gracefully

#### 5.3 Cache TTL Standardization
- **File**: `lib/features/transactions/data/repositories/transaction_repository_impl.dart`
- **Changes**:
  - Standardize cache TTLs: Categories (30min), Transactions (5min), Summaries (3min)
  - Implement cache priority levels
  - Add cache statistics for monitoring

### Warnings & Precautions:
- ⚠️ Don't block app startup for cache warming
- ⚠️ Handle cache warming failures gracefully
- ⚠️ Monitor cache memory usage impact

### Reference Documentation:
- `docs/DATABASE_CACHING_GUIDE.md` - Cache implementation and best practices
- `docs/DI_WORKFLOW_GUIDE.md` - Service initialization patterns

---

## Expected Performance Outcomes

### Measurable Improvements:
- **Navigation lag**: 500-1000ms → <200ms (80% improvement)
- **Database query time**: 60% reduction through server-side filtering  
- **Widget rebuilds**: 70% reduction through selective state management
- **Memory allocations**: 30% reduction through object optimization
- **Cache hit rate**: 90%+ for frequently accessed data

### User Experience Improvements:
- ✅ Instant skeleton UI feedback during loading
- ✅ Smooth month selector transitions
- ✅ Consistent performance across navigation patterns
- ✅ Reduced battery usage through optimized queries

---

## Documentation Updates Required

### After Phase 1:
- Update `docs/UI_PATTERNS_AND_BEST_PRACTICES.md` with CategoryBloc singleton pattern
- Add CategoryBloc section to `docs/DI_WORKFLOW_GUIDE.md`

### After Phase 2:  
- Update `docs/TRANSACTIONS_BASICS.md` with new repository methods
- Document month-specific caching in `docs/DATABASE_CACHING_GUIDE.md`

### After Phase 3:
- Add skeleton loading patterns to `docs/UI_PATTERNS_AND_BEST_PRACTICES.md`
- Update BlocSelector examples in `docs/UI_PATTERNS_AND_BEST_PRACTICES.md`

### After Phase 4:
- Document memory optimization techniques in `docs/UI_PATTERNS_AND_BEST_PRACTICES.md`
- Add performance monitoring guidelines

### After Phase 5:
- Create `docs/CACHE_WARMING_GUIDE.md` with warming strategies
- Update `docs/README.md` with performance optimization section

---

## Testing Strategy

### Performance Tests:
- Add benchmarks to `test/performance/`
- Profile memory usage before/after each phase
- Measure navigation timing with different data sizes

### Integration Tests:
- Test all state transitions thoroughly
- Validate cache consistency across operations
- Test error handling and recovery scenarios

### Rollback Plan:
- Maintain feature flags for each phase
- Keep original BLoC logic as fallback
- Document rollback procedures for each phase