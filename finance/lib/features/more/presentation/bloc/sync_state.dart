import 'package:equatable/equatable.dart';
import '../../../../core/sync/sync_service.dart';

abstract class SyncBlocState extends Equatable {
  const SyncBlocState();

  @override
  List<Object?> get props => [];
}

class SyncInitialState extends SyncBlocState {
  const SyncInitialState();
}

class SyncLoadingState extends SyncBlocState {
  const SyncLoadingState();
}

class SyncLoadedState extends SyncBlocState {
  final SyncStatus status;
  final bool isSignedIn;
  final String? userEmail;
  final DateTime? lastSyncTime;
  final List<SyncConflict> conflicts;
  final SyncResult? lastResult;
  final double? progress;
  final String? currentOperation;
  final int uploadedCount;
  final int downloadedCount;
  final bool isInitialized;

  const SyncLoadedState({
    required this.status,
    required this.isSignedIn,
    this.userEmail,
    this.lastSyncTime,
    this.conflicts = const [],
    this.lastResult,
    this.progress,
    this.currentOperation,
    this.uploadedCount = 0,
    this.downloadedCount = 0,
    this.isInitialized = false,
  });

  SyncLoadedState copyWith({
    SyncStatus? status,
    bool? isSignedIn,
    String? userEmail,
    DateTime? lastSyncTime,
    List<SyncConflict>? conflicts,
    SyncResult? lastResult,
    double? progress,
    String? currentOperation,
    int? uploadedCount,
    int? downloadedCount,
    bool? isInitialized,
  }) {
    return SyncLoadedState(
      status: status ?? this.status,
      isSignedIn: isSignedIn ?? this.isSignedIn,
      userEmail: userEmail ?? this.userEmail,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      conflicts: conflicts ?? this.conflicts,
      lastResult: lastResult ?? this.lastResult,
      progress: progress ?? this.progress,
      currentOperation: currentOperation ?? this.currentOperation,
      uploadedCount: uploadedCount ?? this.uploadedCount,
      downloadedCount: downloadedCount ?? this.downloadedCount,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  @override
  List<Object?> get props => [
        status,
        isSignedIn,
        userEmail,
        lastSyncTime,
        conflicts,
        lastResult,
        progress,
        currentOperation,
        uploadedCount,
        downloadedCount,
        isInitialized,
      ];
}

class SyncErrorState extends SyncBlocState {
  final String message;
  final String? details;

  const SyncErrorState({
    required this.message,
    this.details,
  });

  @override
  List<Object?> get props => [message, details];
}

class SyncAuthenticationState extends SyncBlocState {
  final bool isSigningIn;

  const SyncAuthenticationState({
    required this.isSigningIn,
  });

  @override
  List<Object?> get props => [isSigningIn];
}