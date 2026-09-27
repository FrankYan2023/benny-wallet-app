import 'dart:convert';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/notification_message.dart';

class NotificationInboxRepository {
  static const _storageKey = 'notification_inbox_v1';
  static const _deletedReceivedIdsKey = 'notification_deleted_received_ids_v1';
  static const _maxMessages = 80;
  Future<void> _pending = Future<void>.value();
  Future<T> _mutate<T>(Future<T> Function() action) async {
    final previous = _pending;
    final done = Completer<void>();
    _pending = done.future;
    await previous;
    try {
      return await action();
    } finally {
      done.complete();
    }
  }

  Future<List<NotificationMessage>> upsertMessage(
    NotificationMessage message,
  ) => _mutate(() => _upsertMessage(message));
  Future<List<NotificationMessage>> syncMessages(
    List<NotificationMessage> messages,
  ) => _mutate(() => _syncMessages(messages));
  Future<List<NotificationMessage>> markAllRead() => _mutate(_markAllRead);
  Future<List<NotificationMessage>> markRead(String id) =>
      _mutate(() => _markRead(id));
  Future<List<NotificationMessage>> deleteMessage(String id) =>
      _mutate(() => _deleteMessage(id));

  Future<List<NotificationMessage>> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }

    final messages =
        decoded
            .whereType<Map>()
            .map(
              (item) =>
                  NotificationMessage.fromJson(Map<String, dynamic>.from(item)),
            )
            .where((message) => message.id.isNotEmpty)
            .toList()
          ..sort((a, b) => b.receivedAt.compareTo(a.receivedAt));

    return messages;
  }

  Future<List<NotificationMessage>> _upsertMessage(
    NotificationMessage message,
  ) async {
    final messages = await loadMessages();
    final existing = messages
        .where(
          (item) =>
              item.id == message.id ||
              (message.eventId != null &&
                  item.eventId == message.eventId &&
                  item.ownerAddress == message.ownerAddress),
        )
        .firstOrNull;
    if (existing != null) message = message.copyWith(isRead: existing.isRead);
    if (message.eventId != null &&
        (await loadDeletedReceivedIds()).contains(message.eventId))
      return messages;
    final withoutExisting = messages
        .where(
          (item) =>
              item.id != message.id &&
              !(message.eventId != null &&
                  item.eventId == message.eventId &&
                  item.ownerAddress == message.ownerAddress),
        )
        .toList();
    final next = [message, ...withoutExisting]
      ..sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
    final capped = next.take(_maxMessages).toList();
    await _save(capped);
    return capped;
  }

  Future<List<NotificationMessage>> _syncMessages(
    List<NotificationMessage> incomingMessages,
  ) async {
    if (incomingMessages.isEmpty) {
      return loadMessages();
    }

    final messages = await loadMessages();
    final deletedReceivedIds = await loadDeletedReceivedIds();
    final existingIds = messages.map((message) => message.id).toSet();
    final existingEventIds = messages
        .map((message) => message.eventId)
        .whereType<String>()
        .toSet();
    final additions = incomingMessages.where((message) {
      final eventId = message.eventId;
      if (existingIds.contains(message.id)) {
        return false;
      }
      if (eventId != null && existingEventIds.contains(eventId)) {
        return false;
      }
      if (eventId != null && deletedReceivedIds.contains(eventId)) {
        return false;
      }
      return true;
    });

    final next = [...additions, ...messages]
      ..sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
    final capped = next.take(_maxMessages).toList();
    await _save(capped);
    return capped;
  }

  Future<List<NotificationMessage>> _markAllRead() async {
    final messages = await loadMessages();
    final next = [
      for (final message in messages) message.copyWith(isRead: true),
    ];
    await _save(next);
    return next;
  }

  Future<List<NotificationMessage>> _markRead(String id) async {
    final messages = await loadMessages();
    final next = [
      for (final message in messages)
        message.id == id ? message.copyWith(isRead: true) : message,
    ];
    await _save(next);
    return next;
  }

  Future<List<NotificationMessage>> _deleteMessage(String id) async {
    final messages = await loadMessages();
    NotificationMessage? deletedMessage;
    for (final message in messages) {
      if (message.id == id) {
        deletedMessage = message;
        break;
      }
    }
    if (deletedMessage?.eventId case final eventId?) {
      await _saveDeletedReceivedId(eventId);
    }
    final next = messages.where((message) => message.id != id).toList();
    await _save(next);
    return next;
  }

  Future<Set<String>> loadDeletedReceivedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_deletedReceivedIdsKey)?.toSet() ?? <String>{};
  }

  Future<void> _save(List<NotificationMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode([for (final message in messages) message.toJson()]),
    );
  }

  Future<void> _saveDeletedReceivedId(String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final deletedIds = await loadDeletedReceivedIds();
    deletedIds.add(eventId);
    await prefs.setStringList(_deletedReceivedIdsKey, deletedIds.toList());
  }
}
