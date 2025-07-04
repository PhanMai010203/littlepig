import 'package:equatable/equatable.dart';
import '../../../../core/sync/sync_service.dart';

abstract class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object?> get props => [];
}

class SyncInitializeEvent extends SyncEvent {
  const SyncInitializeEvent();
}

class SyncSignInEvent extends SyncEvent {
  const SyncSignInEvent();
}

class SyncSignOutEvent extends SyncEvent {
  const SyncSignOutEvent();
}

class SyncManualTriggerEvent extends SyncEvent {
  final SyncTriggerType type;

  const SyncManualTriggerEvent({required this.type});

  @override
  List<Object?> get props => [type];
}

class SyncCancelEvent extends SyncEvent {
  const SyncCancelEvent();
}

class SyncResolveConflictEvent extends SyncEvent {
  final SyncConflict conflict;
  final ConflictResolution resolution;

  const SyncResolveConflictEvent({
    required this.conflict,
    required this.resolution,
  });

  @override
  List<Object?> get props => [conflict, resolution];
}

class SyncResolveAllConflictsEvent extends SyncEvent {
  final ConflictResolution defaultResolution;

  const SyncResolveAllConflictsEvent({
    required this.defaultResolution,
  });

  @override
  List<Object?> get props => [defaultResolution];
}

class SyncStatusChangedEvent extends SyncEvent {
  final SyncStatus status;

  const SyncStatusChangedEvent(this.status);

  @override
  List<Object?> get props => [status];
}

class SyncResultReceivedEvent extends SyncEvent {
  final SyncResult result;

  const SyncResultReceivedEvent(this.result);

  @override
  List<Object?> get props => [result];
}

class SyncRefreshEvent extends SyncEvent {
  const SyncRefreshEvent();
}

enum SyncTriggerType {
  full,
  uploadOnly,
  downloadOnly,
}

enum ConflictResolution {
  useLocal,
  useRemote,
  merge,
}