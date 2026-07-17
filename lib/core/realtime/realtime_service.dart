import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_client.dart';

class RealtimeService {
  final Map<String, RealtimeChannel> _channels = {};
  bool _isConnected = false;

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
  void subscribeToProducts(void Function(Map<String, dynamic> payload) onUpsert) {
    unsubscribe('products');

    const channelName = 'public:products';
    final channel = SupabaseConfig.client.channel(channelName);

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'products',
      callback: (PostgresChangePayload change) {
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
      }
    });

    _channels['products'] = channel;
  }

  /// Unsubscribe from a specific table.
  void unsubscribe(String table) {
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
    for (final channel in _channels.values) {
      SupabaseConfig.client.removeChannel(channel);
    }
    _channels.clear();
    _isConnected = false;
  }
}
