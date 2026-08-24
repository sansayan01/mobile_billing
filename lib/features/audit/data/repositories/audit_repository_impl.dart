import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/core/supabase/supabase_client.dart';
import 'package:billing_app/features/audit/domain/entities/audit_log.dart';
import 'package:billing_app/features/audit/domain/repositories/audit_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuditRepositoryImpl implements AuditRepository {
  SupabaseClient get _supabase => SupabaseConfig.client;

  AuditLog _fromJson(Map<String, dynamic> json) => AuditLog(
        id: json['id'] as String,
        action: json['action'] as String,
        entityType: json['entity_type'] as String,
        entityId: json['entity_id'] as String?,
        entityName: json['entity_name'] as String?,
        description: json['description'] as String,
        oldValue: json['old_value'] as Map<String, dynamic>?,
        newValue: json['new_value'] as Map<String, dynamic>?,
        performedBy: json['performed_by'] as String?,
        staffName: json['staff_name'] as String?,
        shopId: json['shop_id'] as String?,
        metadata: json['metadata'] as Map<String, dynamic>?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  @override
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
  }) async {
    try {
      // Get current user id
      final userId = _supabase.auth.currentUser?.id;

      final data = <String, dynamic>{
        'action': action,
        'entity_type': entityType,
        'description': description,
        if (userId != null) 'performed_by': userId,
      };
      if (entityId != null) data['entity_id'] = entityId;
      if (entityName != null) data['entity_name'] = entityName;
      if (oldValue != null) data['old_value'] = oldValue;
      if (newValue != null) data['new_value'] = newValue;
      if (staffName != null) data['staff_name'] = staffName;
      if (shopId != null) data['shop_id'] = shopId;
      if (metadata != null) data['metadata'] = metadata;

      final response = await _supabase.from('audit_logs').insert(data).select().single();
      return Right(_fromJson(response));
    } catch (e) {
      return Left(ServerFailure('Failed to log audit: $e'));
    }
  }

  @override
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
  }) async {
    try {
      // IMPORTANT: Apply filters BEFORE .order()
      var query = _supabase.from('audit_logs').select();

      if (shopId != null) query = query.eq('shop_id', shopId);
      if (entityType != null) query = query.eq('entity_type', entityType);
      if (action != null) query = query.eq('action', action);
      if (performedBy != null) query = query.eq('performed_by', performedBy);
      if (from != null) query = query.gte('created_at', from.toIso8601String());
      if (to != null) query = query.lte('created_at', to.toIso8601String());
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'description.ilike.%$searchQuery%,entity_name.ilike.%$searchQuery%,staff_name.ilike.%$searchQuery%',
        );
      }

      // Apply ordering and pagination AFTER filters
      final int fetchLimit = limit ?? 30;
      final ordered = query.order('created_at', ascending: false);
      final finalQuery = offset != null
          ? ordered.range(offset, offset + fetchLimit - 1)
          : ordered.limit(fetchLimit);

      final response = await finalQuery;
      final logs = (response as List).map((json) => _fromJson(json)).toList();
      return Right(logs);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch audit logs: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AuditLog>>> getEntityAuditLogs({
    required String entityType,
    required String entityId,
    String? shopId,
  }) async {
    try {
      var query = _supabase
          .from('audit_logs')
          .select()
          .eq('entity_type', entityType)
          .eq('entity_id', entityId);

      if (shopId != null) query = query.eq('shop_id', shopId);

      final response = await query.order('created_at', ascending: false);
      final logs = (response as List).map((json) => _fromJson(json)).toList();
      return Right(logs);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch entity audit logs: $e'));
    }
  }
}
