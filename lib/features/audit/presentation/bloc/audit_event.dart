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

class LoadEntityAuditLogs extends AuditEvent {
  final String entityType;
  final String entityId;

  const LoadEntityAuditLogs({required this.entityType, required this.entityId});

  @override
  List<Object?> get props => [entityType, entityId];
}

class LogAuditAction extends AuditEvent {
  final String action;
  final String entityType;
  final String? entityId;
  final String? entityName;
  final String description;
  final Map<String, dynamic>? oldValue;
  final Map<String, dynamic>? newValue;
  final String? shopId;

  const LogAuditAction({
    required this.action,
    required this.entityType,
    this.entityId,
    this.entityName,
    required this.description,
    this.oldValue,
    this.newValue,
    this.shopId,
  });

  @override
  List<Object?> get props => [action, entityType, entityId, entityName, description];
}

class ResetAuditLogs extends AuditEvent {}
