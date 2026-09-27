import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_client_flutter/features/notifications/data/notification_inbox_repository.dart';
import 'package:wallet_client_flutter/features/notifications/domain/notification_message.dart';

void main() {
  test(
    'concurrent notification arrivals cannot overwrite each other',
    () async {
      SharedPreferences.setMockInitialValues({});
      final repository = NotificationInboxRepository();
      await Future.wait([
        for (var i = 0; i < 12; i++)
          repository.upsertMessage(
            NotificationMessage(
              id: 'event:$i',
              eventId: 'arc-mainnet:$i',
              title: 'Arc',
              body: 'Received',
              receivedAt: DateTime.utc(2026),
            ),
          ),
      ]);
      expect((await repository.loadMessages()).length, 12);
    },
  );
  test(
    'network and root survive serialization; old Solana messages still parse',
    () {
      final message = NotificationMessage(
        id: 'arc:1',
        title: 'Received USDC on Arc',
        body: '1 USDC',
        receivedAt: DateTime.utc(2026),
        chainId: 'arc-mainnet',
        ownerAddress: 'root',
        signature: 'hash',
      );
      final restored = NotificationMessage.fromJson(message.toJson());
      expect(restored.chainId, 'arc-mainnet');
      expect(restored.ownerAddress, 'root');
      expect(restored.signature, 'hash');
      expect(NotificationMessage.fromJson({'id': 'legacy'}).chainId, isNull);
    },
  );
  test(
    'retried FCM event deduplicates and preserves read state and deletion',
    () async {
      SharedPreferences.setMockInitialValues({});
      final repository = NotificationInboxRepository();
      NotificationMessage message(String id) => NotificationMessage(
        id: id,
        title: 'Arc',
        body: '1 USDC',
        receivedAt: DateTime.utc(2026),
        eventId: 'arc-mainnet:hash:1',
        chainId: 'arc-mainnet',
        ownerAddress: 'root',
      );
      await repository.upsertMessage(message('delivery-1'));
      await repository.markRead('delivery-1');
      final retried = await repository.upsertMessage(message('delivery-2'));
      expect(retried.length, 1);
      expect(retried.single.isRead, true);
      await repository.deleteMessage('delivery-2');
      expect(await repository.upsertMessage(message('delivery-3')), isEmpty);
    },
  );
}
