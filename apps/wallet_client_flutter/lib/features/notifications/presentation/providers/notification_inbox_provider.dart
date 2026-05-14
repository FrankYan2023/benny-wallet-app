import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/notification_inbox_repository.dart';
import '../../domain/notification_message.dart';

final notificationInboxRepositoryProvider =
    Provider<NotificationInboxRepository>((ref) {
      return NotificationInboxRepository();
    });

final notificationInboxProvider =
    StateNotifierProvider<
      NotificationInboxController,
      AsyncValue<List<NotificationMessage>>
    >((ref) {
      return NotificationInboxController(
        ref.read(notificationInboxRepositoryProvider),
      )..load();
    });

final unreadNotificationCountProvider = Provider<int>((ref) {
  final messages = ref.watch(notificationInboxProvider).valueOrNull;
  if (messages == null) {
    return 0;
  }
  return messages.where((message) => !message.isRead).length;
});

class NotificationInboxController
    extends StateNotifier<AsyncValue<List<NotificationMessage>>> {
  NotificationInboxController(this._repository)
    : super(const AsyncValue.loading());

  final NotificationInboxRepository _repository;

  Future<void> load() async {
    try {
      state = AsyncValue.data(await _repository.loadMessages());
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> recordRemoteMessage(RemoteMessage message) async {
    try {
      final notification = message.notification;
      final title = notification?.title ?? _readString(message.data['title']);
      final body =
          notification?.body ??
          _readString(message.data['body']) ??
          _bodyFromData(message.data);
      final id =
          message.messageId ??
          _readString(message.data['id']) ??
          '${DateTime.now().microsecondsSinceEpoch}';

      final next = await _repository.upsertMessage(
        NotificationMessage(
          id: id,
          title: title ?? 'Notification',
          body: body,
          receivedAt: message.sentTime ?? DateTime.now(),
          type: _readString(message.data['type']),
          eventId: _readString(message.data['eventId']),
        ),
      );
      state = AsyncValue.data(next);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> syncReceivedTransfers(
    List<RemoteReceivedTransferItem> transfers,
  ) async {
    try {
      final messages = [
        for (final transfer in transfers)
          if (transfer.id.isNotEmpty)
            NotificationMessage(
              id: 'received:${transfer.id}',
              title: 'Funds received',
              body: transfer.displayAmount.isEmpty
                  ? 'New funds arrived in your wallet.'
                  : 'You received ${transfer.displayAmount}',
              receivedAt:
                  _parseTimestamp(transfer.notifiedAt) ??
                  _parseTimestamp(transfer.confirmedAt) ??
                  _parseTimestamp(transfer.createdAt) ??
                  DateTime.now(),
              type: 'incoming_funds',
              eventId: transfer.id,
            ),
      ];
      state = AsyncValue.data(await _repository.syncMessages(messages));
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> markAllRead() async {
    final previous = state.valueOrNull;
    if (previous != null) {
      state = AsyncValue.data([
        for (final message in previous) message.copyWith(isRead: true),
      ]);
    }

    try {
      state = AsyncValue.data(await _repository.markAllRead());
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> markRead(String id) async {
    final previous = state.valueOrNull;
    if (previous != null) {
      state = AsyncValue.data([
        for (final message in previous)
          message.id == id ? message.copyWith(isRead: true) : message,
      ]);
    }

    try {
      state = AsyncValue.data(await _repository.markRead(id));
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> deleteMessage(String id) async {
    final previous = state.valueOrNull;
    if (previous != null) {
      state = AsyncValue.data([
        for (final message in previous)
          if (message.id != id) message,
      ]);
    }

    try {
      state = AsyncValue.data(await _repository.deleteMessage(id));
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  String _bodyFromData(Map<String, dynamic> data) {
    final amount = _readString(data['amountText']);
    final symbol = _readString(data['symbol']);
    if (amount != null && symbol != null) {
      return 'You received $amount $symbol';
    }
    return 'New funds arrived in your wallet.';
  }

  String? _readString(Object? value) {
    if (value is! String || value.trim().isEmpty) {
      return null;
    }
    return value.trim();
  }

  DateTime? _parseTimestamp(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
