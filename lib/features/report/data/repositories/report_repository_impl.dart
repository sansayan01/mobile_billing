// ignore_for_file: prefer_const_constructors

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
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
          .select('*, profiles(name), bill_items(*)');

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

      // Server-side filter: payment method only (product search needs client-side)
      if (paymentMethod != null && paymentMethod.trim().isNotEmpty) {
        query = query.eq('payment_method', paymentMethod.trim());
      }

      // Fetch more than needed for client-side product search filtering
      final searchTerm = (searchQuery != null && searchQuery.trim().isNotEmpty)
          ? searchQuery.trim().toLowerCase()
          : null;

      // For product search, fetch a larger batch and filter client-side
      final fetchLimit = searchTerm != null ? 100 : 20;
      final start = (page - 1) * limit;
      final end = start + fetchLimit - 1;

      final response = await query.range(start, end).order('created_at', ascending: false);

      var bills = (response as List<dynamic>)
          .map(
              (e) => BillSummaryModel.fromSupabaseRow(e as Map<String, dynamic>))
          .toList();

      // Client-side filtering for customer name, bill ID, and product names
      if (searchTerm != null) {
        bills = bills.where((bill) {
          // Match customer name
          if (bill.customerName?.toLowerCase().contains(searchTerm) == true) {
            return true;
          }
          // Match bill ID (full or partial)
          if (bill.id.toLowerCase().contains(searchTerm)) {
            return true;
          }
          // Match product names in bill items
          if (bill.items.any((item) =>
              item.productName.toLowerCase().contains(searchTerm))) {
            return true;
          }
          return false;
        }).toList();
      }

      // Paginate the filtered results
      final paginatedBills = bills.take(limit).toList();

      return Right(paginatedBills);
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
  Future<Either<Failure, BillSummary>> updateBill(
    String billId,
    Map<String, dynamic> updates, {
    String? shopId,
    List<BillItem>? items,
  }) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);
      final staffId = _supabase.auth.currentUser?.id;

      // 1. Update bill columns (customer_name, customer_phone, discount, payment_method)
      var query = _supabase
          .from('bills')
          .update(updates) as dynamic;

      if (effectiveShopId != null) {
        query = query.eq('shop_id', effectiveShopId);
      }

      await query.eq('id', billId);

      // 2. If items provided, handle item-level changes
      if (items != null) {
        // Fetch existing bill_items from DB — bill_id is unique UUID
        final existingRows = await _supabase
            .from('bill_items')
            .select()
            .eq('bill_id', billId);
        final existingItems = (existingRows as List<dynamic>)
            .map((e) => BillItemModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // Build maps by productId for diffing
        final existingByProductId = <String, BillItem>{};
        for (final item in existingItems) {
          existingByProductId[item.productId] = item;
        }

        final newByProductId = <String, BillItem>{};
        for (final item in items) {
          newByProductId[item.productId] = item;
        }

        final now = DateTime.now().toIso8601String();

        // a) Removed items — restore stock
        for (final existing in existingItems) {
          if (!newByProductId.containsKey(existing.productId)) {
            // Delete bill_item row
            await _supabase
                .from('bill_items')
                .delete()
                .eq('id', existing.id);

            // Restore stock — product_id is unique UUID
            final productRow = await _supabase
                .from('products')
                .select('stock')
                .eq('id', existing.productId)
                .maybeSingle();

            if (productRow != null) {
              final currentStock = (productRow['stock'] as num).toInt();
              await _supabase
                  .from('products')
                  .update({'stock': currentStock + existing.quantity})
                  .eq('id', existing.productId);
            }

            // Log inventory
            if (staffId != null) {
              await _supabase.from('inventory_log').insert({
                'id': const Uuid().v4(),
                'product_id': existing.productId,
                'shop_id': effectiveShopId ?? '',
                'staff_id': staffId,
                'change_type': 'return',
                'quantity': existing.quantity,
                'created_at': now,
                'notes': 'Bill edit: removed from bill $billId',
              });
            }
          }
        }

        // b) Modified items — adjust stock diff
        for (final newItem in items) {
          final existing = existingByProductId[newItem.productId];
          if (existing != null) {
            // Check if qty or price changed
            if (existing.quantity != newItem.quantity ||
                existing.price != newItem.price) {
              // Update bill_item row
              await _supabase
                  .from('bill_items')
                  .update({
                    'quantity': newItem.quantity,
                    'price': newItem.price,
                    'total': newItem.price * newItem.quantity,
                  })
                  .eq('id', existing.id);

              // Adjust stock diff
              final qtyDiff = newItem.quantity - existing.quantity;
              if (qtyDiff != 0) {
                // Get current stock first
                final productRow = await _supabase
                    .from('products')
                    .select('stock')
                    .eq('id', newItem.productId)
                    .maybeSingle();

                if (productRow != null) {
                  final currentStock = (productRow['stock'] as num).toInt();
                  await _supabase
                      .from('products')
                      .update({'stock': currentStock - qtyDiff})
                      .eq('id', newItem.productId);
                }
              }

              // Log inventory if qty changed
              if (qtyDiff != 0 && staffId != null) {
                await _supabase.from('inventory_log').insert({
                  'id': const Uuid().v4(),
                  'product_id': newItem.productId,
                  'shop_id': effectiveShopId ?? '',
                  'staff_id': staffId,
                  'change_type': qtyDiff > 0 ? 'sell' : 'return',
                  'quantity': qtyDiff > 0 ? -qtyDiff : qtyDiff.abs(),
                  'created_at': now,
                  'notes': 'Bill edit: qty changed in bill $billId',
                });
              }
            }
          } else {
            // c) New item — insert bill_item + deduct stock
            await _supabase.from('bill_items').insert({
              'id': const Uuid().v4(),
              'bill_id': billId,
              'shop_id': effectiveShopId ?? '',
              'product_id': newItem.productId,
              'product_name': newItem.productName,
              'quantity': newItem.quantity,
              'price': newItem.price,
              'total': newItem.price * newItem.quantity,
            });

            // Deduct stock — product_id is unique UUID
            final productRow = await _supabase
                .from('products')
                .select('stock')
                .eq('id', newItem.productId)
                .maybeSingle();

            if (productRow != null) {
              final currentStock = (productRow['stock'] as num).toInt();
              await _supabase
                  .from('products')
                  .update({'stock': currentStock - newItem.quantity})
                  .eq('id', newItem.productId);
            }

            // Log inventory
            if (staffId != null) {
              await _supabase.from('inventory_log').insert({
                'id': const Uuid().v4(),
                'product_id': newItem.productId,
                'shop_id': effectiveShopId ?? '',
                'staff_id': staffId,
                'change_type': 'sell',
                'quantity': -newItem.quantity,
                'created_at': now,
                'notes': 'Bill edit: added to bill $billId',
              });
            }
          }
        }

        // d) Recalculate bill totals
        final totalAmount = items.fold<double>(
            0, (sum, item) => sum + item.price * item.quantity);
        final discount = (updates['discount'] as num?)?.toDouble() ?? 0.0;
        final grandTotal = totalAmount - discount;

        await _supabase
            .from('bills')
            .update({
              'total_amount': totalAmount,
              'grand_total': grandTotal,
              'item_count': items.length,
            })
            .eq('id', billId);
      }

      // 3. Re-fetch full bill with items
      final updatedRow = await _supabase
          .from('bills')
          .select('*, profiles(name)')
          .eq('id', billId)
          .maybeSingle();

      if (updatedRow == null) {
        return Left(ServerFailure('Bill not found after update'));
      }

      // Fetch items
      var finalItemsQuery = _supabase
          .from('bill_items')
          .select()
          .eq('bill_id', billId);
      if (effectiveShopId != null) {
        finalItemsQuery = finalItemsQuery.eq('shop_id', effectiveShopId);
      }
      final finalItemsResponse = await finalItemsQuery.order('id', ascending: true);

      final finalItems = (finalItemsResponse as List<dynamic>)
          .map((e) => BillItemModel.fromJson(e as Map<String, dynamic>))
          .toList();

      final bill = BillSummaryModel.fromSupabaseRow(updatedRow);
      return Right(bill.copyWith(items: finalItems, itemCount: finalItems.length));
    } catch (e) {
      return Left(ServerFailure('Failed to update bill: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBill(
    String billId, {
    String? shopId,
  }) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);
      final staffId = _supabase.auth.currentUser?.id;
      final now = DateTime.now().toIso8601String();

      // 1. Fetch bill items BEFORE deleting (to restore stock)
      // bill_id is a UUID and unique, so no shop_id filter needed here.
      final itemsResponse = await _supabase
          .from('bill_items')
          .select()
          .eq('bill_id', billId);
      final items = (itemsResponse as List<dynamic>)
          .map((e) => BillItemModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // 2. Restore stock for each item + log inventory
      for (final item in items) {
        // Restore stock — product_id is a UUID and unique, so no shop_id
        // filter needed. This also handles legacy products where shop_id
        // may be NULL (created before the multi-tenant migration).
        final productRow = await _supabase
            .from('products')
            .select('stock')
            .eq('id', item.productId)
            .maybeSingle();

        if (productRow != null) {
          final currentStock = (productRow['stock'] as num).toInt();
          await _supabase
              .from('products')
              .update({'stock': currentStock + item.quantity})
              .eq('id', item.productId);
        }

        // Log inventory restoration
        if (staffId != null) {
          await _supabase.from('inventory_log').insert({
            'id': const Uuid().v4(),
            'product_id': item.productId,
            'shop_id': effectiveShopId ?? '',
            'staff_id': staffId,
            'change_type': 'return',
            'quantity': item.quantity,
            'created_at': now,
            'notes': 'Bill deleted: $billId',
          });
        }
      }

      // 3. Delete bill_items — bill_id is unique UUID
      await _supabase
          .from('bill_items')
          .delete()
          .eq('bill_id', billId);

      // 4. Delete the bill itself — bill id is unique UUID
      await _supabase
          .from('bills')
          .delete()
          .eq('id', billId);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete bill: $e'));
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
