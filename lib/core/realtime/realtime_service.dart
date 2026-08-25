import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_client.dart';

class RealtimeService {
  final Map<String, RealtimeChannel> _channels = {};
  final Map<String, Timer> _retryTimers = {};
  bool _isConnected = false;
  bool _disposed = false;

  bool get isConnected => _isConnected;

  /// Subscribe to a specific table with separate callbacks for INSERT, UPDATE, DELETE.
  void subscribeToTable(
    String table, {
    required void Function(Map<String, dynamic>) onInsert,
    required void Function(Map<String, dynamic>) onUpdate,
    required void Function(String) onDelete,
  }) {
    // Unsubscribe first if already subscribed
    unsubscribe(table);

    final channelName = 'public:$table';
    final channel = SupabaseConfig.client.channel(channelName);

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: table,
      callback: (payload) {
        if (payload.eventType == PostgresChangeEvent.insert) {
          onInsert(payload.newRecord);
        } else if (payload.eventType == PostgresChangeEvent.update) {
          onUpdate(payload.newRecord);
        } else if (payload.eventType == PostgresChangeEvent.delete) {
          final id = payload.oldRecord['id'] as String?;
          if (id != null) {
            onDelete(id);
          }
        }
      },
    ).subscribe((status, [error]) {
      if (status == RealtimeSubscribeStatus.subscribed) {
        _isConnected = true;
      } else if (status == RealtimeSubscribeStatus.channelError ||
          status == RealtimeSubscribeStatus.timedOut) {
        _isConnected = false;
      }
    });

    _channels[table] = channel;
  }

  /// Convenience method for the products table.
  /// The [onUpsert] callback receives a map with keys:
  /// - 'event_type': 'INSERT', 'UPDATE', or 'DELETE'
  /// - 'new': the new record data (Map<String, dynamic>)
  /// - 'old': the old record data (Map<String, dynamic>)
  ///
  /// If [shopId] is provided, only events for that shop's products are
  /// forwarded. This prevents cross-shop data leaking into the BLoC.
  void subscribeToProducts(
    void Function(Map<String, dynamic> payload) onUpsert, {
    String? shopId,
  }) {
    unsubscribe('products');

    const channelName = 'public:products';
    final channel = SupabaseConfig.client.channel(channelName);

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'products',
      // Server-side filter — server only sends rows for this shop.
      filter: shopId != null
          ? PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'shop_id',
              value: shopId,
            )
          : null,
      callback: (PostgresChangePayload change) async {
        // Client-side filter as a safety net. For DELETE events newRecord is
        // empty, so read shop_id from the old record instead; when the old
        // record has no shop_id (DELETE payloads often carry only the id),
        // fetch the row by id to verify its shop before forwarding.
        if (shopId != null) {
          final isDelete = change.eventType == PostgresChangeEvent.delete;
          final recordShopId = (isDelete ? change.oldRecord : change.newRecord)[
              'shop_id'] as String?;
          if (recordShopId != null && recordShopId != shopId) {
            return;
          }
          if (recordShopId == null &&
              !await _verifyDeleteShop(
                  change.oldRecord['id'] as String?, shopId)) {
            return;
          }
        }

        final eventType = change.eventType.name.toUpperCase();
        onUpsert({
          'event_type': eventType,
          'new': change.newRecord,
          'old': change.oldRecord,
        });
      },
    ).subscribe((status, [error]) {
      if (status == RealtimeSubscribeStatus.subscribed) {
        _isConnected = true;
      } else if (status == RealtimeSubscribeStatus.channelError ||
          status == RealtimeSubscribeStatus.timedOut) {
        _isConnected = false;
        _scheduleRetry('products', () => subscribeToProducts(onUpsert, shopId: shopId));
      }
    });

    _channels['products'] = channel;
  }

  /// Shop verification for DELETE events whose payload lacks shop_id.
  /// Returns true when the event should still be forwarded: the row cannot
  /// be verified (already deleted / lookup failed) or it matches [shopId].
  Future<bool> _verifyDeleteShop(String? id, String shopId) async {
    if (id == null) return false;
    try {
      final row = await SupabaseConfig.client
          .from('products')
          .select('shop_id')
          .eq('id', id)
          .maybeSingle();
      if (row == null) return true; // row already gone — removal is a no-op
      return row['shop_id'] == shopId;
    } catch (_) {
      return true;
    }
  }

  /// Re-subscribe after a short delay when the channel errors or times out.
  void _scheduleRetry(String key, void Function() resubscribe) {
    if (_disposed) return;
    _retryTimers[key]?.cancel();
    _retryTimers[key] = Timer(const Duration(seconds: 5), () {
      _retryTimers.remove(key);
      if (!_disposed) {
        resubscribe();
      }
    });
  }

  /// Unsubscribe from a specific table.
  void unsubscribe(String table) {
    _retryTimers.remove(table)?.cancel();
    final channel = _channels.remove(table);
    if (channel != null) {
      SupabaseConfig.client.removeChannel(channel);
      if (_channels.isEmpty) {
        _isConnected = false;
      }
    }
  }

  /// Clean up all active subscriptions.
  void dispose() {
    _disposed = true;
    for (final timer in _retryTimers.values) {
      timer.cancel();
    }
    _retryTimers.clear();
    for (final channel in _channels.values) {
      SupabaseConfig.client.removeChannel(channel);
    }
    _channels.clear();
    _isConnected = false;
  }
}
