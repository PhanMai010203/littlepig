import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/sync/sync_service.dart';
import '../../../../core/di/injection.dart';
import 'sync_event.dart';
import 'sync_state.dart';

@injectable
class SyncBloc extends Bloc<SyncEvent, SyncBlocState> {
  final SyncService _syncService;
  StreamSubscription<SyncStatus>? _syncStatusSubscription;

  SyncBloc(this._syncService)
      : super(const SyncInitialState()) {
    on<SyncInitializeEvent>(_onInitialize);
    on<SyncSignInEvent>(_onSignIn);
    on<SyncSignOutEvent>(_onSignOut);
    on<SyncManualTriggerEvent>(_onManualTrigger);
    on<SyncCancelEvent>(_onCancel);
    on<SyncResolveConflictEvent>(_onResolveConflict);
    on<SyncResolveAllConflictsEvent>(_onResolveAllConflicts);
    on<SyncStatusChangedEvent>(_onStatusChanged);
    on<SyncResultReceivedEvent>(_onResultReceived);
    on<SyncRefreshEvent>(_onRefresh);

    // Start listening to sync status changes
    _syncStatusSubscription = _syncService.syncStatusStream.listen(
      (status) => add(SyncStatusChangedEvent(status)),
    );

    // Initialize on creation
    add(const SyncInitializeEvent());
  }

  @override
  Future<void> close() {
    _syncStatusSubscription?.cancel();
    return super.close();
  }

  Future<void> _onInitialize(
    SyncInitializeEvent event,
    Emitter<SyncBlocState> emit,
  ) async {
    emit(const SyncLoadingState());

    try {
      final isInitialized = await _syncService.initialize();
      final isSignedIn = await _syncService.isSignedIn();
      final userEmail = isSignedIn ? await _syncService.getCurrentUserEmail() : null;
      final lastSyncTime = await _syncService.getLastSyncTime();

      emit(SyncLoadedState(
        status: SyncStatus.idle,
        isSignedIn: isSignedIn,
        userEmail: userEmail,
        lastSyncTime: lastSyncTime,
        isInitialized: isInitialized,
      ));
    } catch (e) {
      emit(SyncErrorState(
        message: 'sync.initialization_failed'.tr(),
        details: e.toString(),
      ));
    }
  }

  Future<void> _onSignIn(
    SyncSignInEvent event,
    Emitter<SyncBlocState> emit,
  ) async {
    emit(const SyncAuthenticationState(isSigningIn: true));

    try {
      final success = await _syncService.signIn();
      if (success) {
        final userEmail = await _syncService.getCurrentUserEmail();
        final lastSyncTime = await _syncService.getLastSyncTime();
        
        emit(SyncLoadedState(
          status: SyncStatus.idle,
          isSignedIn: true,
          userEmail: userEmail,
          lastSyncTime: lastSyncTime,
          isInitialized: true,
        ));

        // Trigger initial sync after sign in
        add(const SyncManualTriggerEvent(type: SyncTriggerType.full));
      } else {
        emit(const SyncErrorState(
          message: 'Sign in was cancelled or failed',
        ));
      }
    } catch (e) {
      emit(SyncErrorState(
        message: 'sync.sign_in_failed'.tr(),
        details: e.toString(),
      ));
    }
  }

  Future<void> _onSignOut(
    SyncSignOutEvent event,
    Emitter<SyncBlocState> emit,
  ) async {
    try {
      await _syncService.signOut();
      
      emit(const SyncLoadedState(
        status: SyncStatus.idle,
        isSignedIn: false,
        isInitialized: true,
      ));
    } catch (e) {
      emit(SyncErrorState(
        message: 'sync.sign_out_failed'.tr(),
        details: e.toString(),
      ));
    }
  }

  Future<void> _onManualTrigger(
    SyncManualTriggerEvent event,
    Emitter<SyncBlocState> emit,
  ) async {
    if (state is! SyncLoadedState) return;
    final currentState = state as SyncLoadedState;

    if (!currentState.isSignedIn) {
      emit(const SyncErrorState(
        message: 'Please sign in to Google Drive first',
      ));
      return;
    }

    try {
      SyncResult result;

      switch (event.type) {
        case SyncTriggerType.full:
          result = await _syncService.performFullSync();
          break;
        case SyncTriggerType.uploadOnly:
          result = await _syncService.syncToCloud();
          break;
        case SyncTriggerType.downloadOnly:
          result = await _syncService.syncFromCloud();
          break;
      }

      // Update last sync time
      final lastSyncTime = await _syncService.getLastSyncTime();
      
      emit(currentState.copyWith(
        lastResult: result,
        lastSyncTime: lastSyncTime,
        uploadedCount: result.uploadedCount,
        downloadedCount: result.downloadedCount,
      ));

      add(SyncResultReceivedEvent(result));
    } catch (e) {
      emit(SyncErrorState(
        message: 'sync.operation_failed'.tr(),
        details: e.toString(),
      ));
    }
  }

  Future<void> _onCancel(
    SyncCancelEvent event,
    Emitter<SyncBlocState> emit,
  ) async {
    // Implementation depends on sync service cancellation support
    // For now, just emit idle state
    if (state is SyncLoadedState) {
      final currentState = state as SyncLoadedState;
      emit(currentState.copyWith(status: SyncStatus.idle));
    }
  }

  Future<void> _onResolveConflict(
    SyncResolveConflictEvent event,
    Emitter<SyncBlocState> emit,
  ) async {
    if (state is! SyncLoadedState) return;
    final currentState = state as SyncLoadedState;

    try {
      // TODO: Implement conflict resolution with sync service
      // For now, just remove the conflict from the list
      final updatedConflicts = List<SyncConflict>.from(currentState.conflicts)
        ..removeWhere((c) => c.syncId == event.conflict.syncId);

      emit(currentState.copyWith(conflicts: updatedConflicts));
    } catch (e) {
      emit(SyncErrorState(
        message: 'sync.conflict_resolution_failed'.tr(),
        details: e.toString(),
      ));
    }
  }

  Future<void> _onResolveAllConflicts(
    SyncResolveAllConflictsEvent event,
    Emitter<SyncBlocState> emit,
  ) async {
    if (state is! SyncLoadedState) return;
    final currentState = state as SyncLoadedState;

    try {
      // TODO: Implement bulk conflict resolution
      // For now, just clear all conflicts
      emit(currentState.copyWith(conflicts: []));
    } catch (e) {
      emit(SyncErrorState(
        message: 'sync.bulk_resolution_failed'.tr(),
        details: e.toString(),
      ));
    }
  }

  void _onStatusChanged(
    SyncStatusChangedEvent event,
    Emitter<SyncBlocState> emit,
  ) {
    if (state is SyncLoadedState) {
      final currentState = state as SyncLoadedState;
      
      // Update progress based on status
      double? progress;
      String? operation;
      
      switch (event.status) {
        case SyncStatus.uploading:
          progress = null; // Indeterminate progress
          operation = 'sync.uploading_changes'.tr();
          break;
        case SyncStatus.downloading:
          progress = null;
          operation = 'sync.downloading_changes'.tr();
          break;
        case SyncStatus.merging:
          progress = null;
          operation = 'sync.merging_changes'.tr();
          break;
        case SyncStatus.completed:
          progress = 1.0;
          operation = 'sync.sync_completed'.tr();
          break;
        case SyncStatus.error:
          progress = null;
          operation = 'sync.sync_error_occurred'.tr();
          break;
        default:
          progress = null;
          operation = null;
      }

      emit(currentState.copyWith(
        status: event.status,
        progress: progress,
        currentOperation: operation,
      ));
    }
  }

  void _onResultReceived(
    SyncResultReceivedEvent event,
    Emitter<SyncBlocState> emit,
  ) {
    if (state is SyncLoadedState) {
      final currentState = state as SyncLoadedState;
      emit(currentState.copyWith(
        lastResult: event.result,
        uploadedCount: event.result.uploadedCount,
        downloadedCount: event.result.downloadedCount,
      ));
    }
  }

  Future<void> _onRefresh(
    SyncRefreshEvent event,
    Emitter<SyncBlocState> emit,
  ) async {
    add(const SyncInitializeEvent());
  }
}