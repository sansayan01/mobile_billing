import 'package:equatable/equatable.dart';

abstract class AuditEvent extends Equatable {
  const AuditEvent();

  @override
  List<Object?> get props => [];
}

class LoadAuditLogs extends AuditEvent {
  final String? entityType;
  final String? action;
  final String? performedBy;
  final DateTime? from;
  final DateTime? to;
  final String? searchQuery;

  const LoadAuditLogs({
    this.entityType,
    this.action,
    this.performedBy,
    this.from,
    this.to,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [entityType, action, performedBy, from, to, searchQuery];
}

class LoadMoreAuditLogs extends AuditEvent {
  const LoadMoreAuditLogs();
}

class ResetAuditLogs extends AuditEvent {}
