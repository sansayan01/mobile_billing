// ignore_for_file: prefer_const_constructors

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/core/supabase/supabase_client.dart';
import 'package:billing_app/features/report/data/models/report_models.dart';
import 'package:billing_app/features/report/domain/entities/report_entities.dart';
import 'package:billing_app/features/report/domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  SupabaseClient get _supabase => SupabaseConfig.client;

  /// Resolve shopId: if not provided, fetch from current user's profile.
  Future<String?> _resolveShopId(String? shopId) async {
    if (shopId != null) return shopId;
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;
      final profile = await _supabase
          .from('profiles')
          .select('shop_id')
          .eq('id', userId)
          .maybeSingle();
      if (profile != null) {
        return profile['shop_id'] as String?;
      }
    } catch (_) {
      // If profile fetch fails, return null — RLS may block the operation.
    }
    return null;
  }

  @override
  Future<Either<Failure, List<BillSummary>>> getBillHistory({
    DateTime? from,
    DateTime? to,
    int page = 1,
    int limit = 20,
    String? shopId,
    String? searchQuery,
    String? paymentMethod,
  }) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);
      // Start with select() to get PostgrestFilterBuilder, then add filters
      var query = _supabase
          .from('bills')
          .select('*, profiles(name)');

      if (effectiveShopId != null) {
        query = query.eq('shop_id', effectiveShopId);
      }

      if (from != null) {
        query = query.gte('created_at', from.toIso8601String());
      }
      if (to != null) {
        final endOfDay =
            DateTime(to.year, to.month, to.day, 23, 59, 59, 999);
        query = query.lte('created_at', endOfDay.toIso8601String());
      }

      if (searchQuery != null && searchQuery!.trim().isNotEmpty) {
        final term = searchQuery!.trim();
        query = query.or('customer_name.ilike.%$term%,id.eq.$term');
      }
      if (paymentMethod != null && paymentMethod!.trim().isNotEmpty) {
        query = query.eq('payment_method', paymentMethod!.trim());
      }

      final start = (page - 1) * limit;
      final end = start + limit - 1;

      final response = await query.range(start, end).order('created_at', ascending: false);

      final bills = (response as List<dynamic>)
          .map(
              (e) => BillSummaryModel.fromSupabaseRow(e as Map<String, dynamic>))
          .toList();

      return Right(bills);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch bill history: $e'));
    }
  }

  @override
  Future<Either<Failure, BillSummary>> getBillDetail(
    String billId, {
    String? shopId,
  }) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);
      var billQuery = _supabase
          .from('bills')
          .select('*, profiles(name)')
          .eq('id', billId) as dynamic;

      if (effectiveShopId != null) {
        billQuery = billQuery.eq('shop_id', effectiveShopId);
      }

      final response = await billQuery.maybeSingle();

      if (response == null) {
        return Left(ServerFailure('Bill not found'));
      }

      var itemsQuery = _supabase
          .from('bill_items')
          .select()
          .eq('bill_id', billId);
      if (effectiveShopId != null) {
        itemsQuery = itemsQuery.eq('shop_id', effectiveShopId);
      }
      final itemsResponse = await itemsQuery.order('id', ascending: true);

      final items = (itemsResponse as List<dynamic>)
          .map((e) => BillItemModel.fromJson(e as Map<String, dynamic>))
          .toList();

      final bill = BillSummaryModel.fromSupabaseRow(response);
      return Right(bill.copyWith(items: items, itemCount: items.length));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch bill detail: $e'));
    }
  }

  @override
  Future<Either<Failure, DailySales>> getDailySales(
    DateTime date, {
    String? shopId,
  }) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      var query = _supabase
          .from('bills')
          .select('grand_total, discount')
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String()) as dynamic;

      if (effectiveShopId != null) {
        query = query.eq('shop_id', effectiveShopId);
      }

      final response = await query;

      final rows = response as List<dynamic>;

      double totalSales = 0.0;
      double totalDiscount = 0.0;

      for (final row in rows) {
        final r = row as Map<String, dynamic>;
        totalSales += (r['grand_total'] as num?)?.toDouble() ?? 0.0;
        totalDiscount += (r['discount'] as num?)?.toDouble() ?? 0.0;
      }

      final billCount = rows.length;
      final averageBill = billCount > 0 ? totalSales / billCount : 0.0;

      return Right(DailySalesModel(
        date: date,
        totalSales: totalSales,
        billCount: billCount,
        averageBill: averageBill,
        totalDiscount: totalDiscount,
      ));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch daily sales: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DailySales>>> getSalesRange(
    DateTime from,
    DateTime to, {
    String? shopId,
  }) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);
      final startDate = DateTime(from.year, from.month, from.day);
      final endDate =
          DateTime(to.year, to.month, to.day).add(const Duration(days: 1));

      var query = _supabase
          .from('bills')
          .select('grand_total, discount, created_at')
          .gte('created_at', startDate.toIso8601String())
          .lt('created_at', endDate.toIso8601String())
          .order('created_at', ascending: true) as dynamic;

      if (effectiveShopId != null) {
        query = query.eq('shop_id', effectiveShopId);
      }

      final response = await query;

      final rows = response as List<dynamic>;

      // Group bills by calendar date
      final Map<DateTime, List<Map<String, dynamic>>> grouped = {};
      for (final row in rows) {
        final r = row as Map<String, dynamic>;
        final billDate = DateTime.parse(r['created_at'] as String);
        final dayKey =
            DateTime(billDate.year, billDate.month, billDate.day);
        grouped.putIfAbsent(dayKey, () => []).add(r);
      }

      final dailySalesList = grouped.entries.map((entry) {
        final dayRows = entry.value;

        double totalSales = 0.0;
        double totalDiscount = 0.0;

        for (final r in dayRows) {
          totalSales += (r['grand_total'] as num?)?.toDouble() ?? 0.0;
          totalDiscount += (r['discount'] as num?)?.toDouble() ?? 0.0;
        }

        final billCount = dayRows.length;
        final averageBill = billCount > 0 ? totalSales / billCount : 0.0;

        return DailySalesModel(
          date: entry.key,
          totalSales: totalSales,
          billCount: billCount,
          averageBill: averageBill,
          totalDiscount: totalDiscount,
        );
      }).toList();

      return Right(dailySalesList);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch sales range: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getLowStockProducts(
    int threshold, {
    String? shopId,
  }) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);
      var query = _supabase
          .from('products')
          .select('name, stock, price')
          .lte('stock', threshold) as dynamic;

      if (effectiveShopId != null) {
        query = query.eq('shop_id', effectiveShopId);
      }

      query = query.order('stock', ascending: true);

      final response = await query;

      final products = (response as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      return Right(products);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch low stock products: $e'));
    }
  }

  @override
  Future<Either<Failure, List<StockMovement>>> getStockMovements({
    String? productId,
    DateTime? from,
    DateTime? to,
    String? changeType,
    String? shopId,
  }) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);
      var query = _supabase
          .from('inventory_log')
          .select('*, products(name), profiles(name)');

      if (effectiveShopId != null) {
        query = query.eq('shop_id', effectiveShopId);
      }
      if (productId != null) {
        query = query.eq('product_id', productId);
      }
      if (from != null) {
        query = query.gte('created_at', from.toIso8601String());
      }
      if (to != null) {
        final endOfDay =
            DateTime(to.year, to.month, to.day, 23, 59, 59, 999);
        query = query.lte('created_at', endOfDay.toIso8601String());
      }
      if (changeType != null) {
        query = query.eq('change_type', changeType);
      }

      final response = await query.order('created_at', ascending: false);

      final movements = (response as List<dynamic>)
          .map((e) =>
              StockMovementModel.fromSupabaseRow(e as Map<String, dynamic>))
          .toList();

      return Right(movements);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch stock movements: $e'));
    }
  }
}
