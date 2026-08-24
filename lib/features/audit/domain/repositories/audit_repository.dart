import 'package:billing_app/core/error/failure.dart';
import 'package:fpdart/fpdart.dart';
import 'package:billing_app/features/audit/domain/entities/audit_log.dart';

abstract class AuditRepository {
  /// Log an audit event
  Future<Either<Failure, AuditLog>> logAction({
    required String action,
    required String entityType,
    String? entityId,
    String? entityName,
    required String description,
    Map<String, dynamic>? oldValue,
    Map<String, dynamic>? newValue,
    String? staffName,
    String? shopId,
    Map<String, dynamic>? metadata,
  });

  /// Get audit logs with filters
  Future<Either<Failure, List<AuditLog>>> getAuditLogs({
    String? entityType,
    String? action,
    String? performedBy,
    DateTime? from,
    DateTime? to,
    String? searchQuery,
    String? shopId,
    int? limit,
    int? offset,
  });

  /// Get audit logs for a specific entity
  Future<Either<Failure, List<AuditLog>>> getEntityAuditLogs({
    required String entityType,
    required String entityId,
    String? shopId,
  });
}
