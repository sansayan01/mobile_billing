import 'package:equatable/equatable.dart';
import 'package:billing_app/features/audit/domain/entities/audit_log.dart';

enum AuditStatus { initial, loading, loaded, error }

class AuditState extends Equatable {
  final AuditStatus status;
  final List<AuditLog> logs;
  final List<AuditLog> entityLogs;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final String? lastFilterAction;
  final String? lastFilterEntity;
  final String? lastFilterStaff;
  final DateTime? lastFilterFrom;
  final DateTime? lastFilterTo;
  final String? lastFilterSearch;

  const AuditState({
    this.status = AuditStatus.initial,
    this.logs = const [],
    this.entityLogs = const [],
    this.error,
    this.currentPage = 0,
    this.hasMore = true,
    this.lastFilterAction,
    this.lastFilterEntity,
    this.lastFilterStaff,
    this.lastFilterFrom,
    this.lastFilterTo,
    this.lastFilterSearch,
  });

  AuditState copyWith({
    AuditStatus? status,
    List<AuditLog>? logs,
    List<AuditLog>? entityLogs,
    String? error,
    bool clearError = false,
    int? currentPage,
    bool? hasMore,
    String? lastFilterAction,
    String? lastFilterEntity,
    String? lastFilterStaff,
    DateTime? lastFilterFrom,
    DateTime? lastFilterTo,
    String? lastFilterSearch,
  }) {
    return AuditState(
      status: status ?? this.status,
      logs: logs ?? this.logs,
      entityLogs: entityLogs ?? this.entityLogs,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      lastFilterAction: lastFilterAction ?? this.lastFilterAction,
      lastFilterEntity: lastFilterEntity ?? this.lastFilterEntity,
      lastFilterStaff: lastFilterStaff ?? this.lastFilterStaff,
      lastFilterFrom: lastFilterFrom ?? this.lastFilterFrom,
      lastFilterTo: lastFilterTo ?? this.lastFilterTo,
      lastFilterSearch: lastFilterSearch ?? this.lastFilterSearch,
    );
  }

  @override
  List<Object?> get props => [
        status, logs, entityLogs, error, currentPage, hasMore,
        lastFilterAction, lastFilterEntity, lastFilterStaff,
        lastFilterFrom, lastFilterTo, lastFilterSearch,
      ];
}
