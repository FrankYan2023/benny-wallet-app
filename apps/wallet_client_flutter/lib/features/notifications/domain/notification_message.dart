class NotificationMessage {
  const NotificationMessage({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.isRead = false,
    this.type,
    this.eventId,
    this.signature,
    this.mintAddress,
    this.recipientAddress,
    this.senderAddress,
    this.amountText,
    this.symbol,
  });

  final String id;
  final String title;
  final String body;
  final DateTime receivedAt;
  final bool isRead;
  final String? type;
  final String? eventId;
  final String? signature;
  final String? mintAddress;
  final String? recipientAddress;
  final String? senderAddress;
  final String? amountText;
  final String? symbol;

  NotificationMessage copyWith({bool? isRead}) {
    return NotificationMessage(
      id: id,
      title: title,
      body: body,
      receivedAt: receivedAt,
      isRead: isRead ?? this.isRead,
      type: type,
      eventId: eventId,
      signature: signature,
      mintAddress: mintAddress,
      recipientAddress: recipientAddress,
      senderAddress: senderAddress,
      amountText: amountText,
      symbol: symbol,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'receivedAt': receivedAt.toIso8601String(),
      'isRead': isRead,
      'type': type,
      'eventId': eventId,
      'signature': signature,
      'mintAddress': mintAddress,
      'recipientAddress': recipientAddress,
      'senderAddress': senderAddress,
      'amountText': amountText,
      'symbol': symbol,
    };
  }

  static NotificationMessage fromJson(Map<String, dynamic> json) {
    return NotificationMessage(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Notification',
      body: json['body'] as String? ?? '',
      receivedAt:
          DateTime.tryParse(json['receivedAt'] as String? ?? '') ??
          DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
      type: _readString(json['type']),
      eventId: _readString(json['eventId']),
      signature: _readString(json['signature']),
      mintAddress: _readString(json['mintAddress']),
      recipientAddress: _readString(json['recipientAddress']),
      senderAddress: _readString(json['senderAddress']),
      amountText: _readString(json['amountText']),
      symbol: _readString(json['symbol']),
    );
  }

  bool get isIncomingFunds => type == 'incoming_funds';
}

String? _readString(Object? value) {
  if (value is! String || value.trim().isEmpty) {
    return null;
  }
  return value.trim();
}
