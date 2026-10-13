import 'package:solana/dto.dart';

enum TransactionDirection { sent, received, unknown }

enum TransactionKind { transfer, swap }

class TransactionActivity {
  const TransactionActivity({
    required this.signature,
    required this.symbol,
    required this.kind,
    required this.direction,
    required this.amount,
    required this.counterparty,
    required this.relatedSymbol,
    required this.status,
    required this.timestamp,
  });

  final String signature;
  final String symbol;
  final TransactionKind kind;
  final TransactionDirection direction;
  final String amount;
  final String counterparty;
  final String relatedSymbol;
  final String status;
  final DateTime? timestamp;

  factory TransactionActivity.fromBackendJson({
    required Map<String, dynamic> json,
    required String symbol,
  }) {
    return TransactionActivity(
      signature: json['signature'] as String? ?? '--',
      symbol: symbol,
      kind: _readKind(json['kind'] as String?),
      direction: _readDirection(json['direction'] as String?),
      amount: json['amount'] as String? ?? '--',
      counterparty: json['counterparty'] as String? ?? '--',
      relatedSymbol: json['relatedSymbol'] as String? ?? '',
      status: json['status'] as String? ?? 'unknown',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? ''),
    );
  }

  factory TransactionActivity.fromTransaction({
    required TransactionDetails tx,
    required String ownerAddress,
    required String trackedAddress,
    required String symbol,
  }) {
    final parsedTransaction = tx.transaction;
    String amount = '--';
    String counterparty = '--';
    var direction = TransactionDirection.unknown;

    if (parsedTransaction is ParsedTransaction) {
      for (final instruction in parsedTransaction.message.instructions) {
        if (instruction is ParsedInstructionSystem) {
          instruction.parsed.map(
            transfer: (transfer) {
              amount = transfer.info.lamports.toString();
              if (transfer.info.source == ownerAddress ||
                  transfer.info.source == trackedAddress) {
                direction = TransactionDirection.sent;
                counterparty = transfer.info.destination;
              } else if (transfer.info.destination == ownerAddress ||
                  transfer.info.destination == trackedAddress) {
                direction = TransactionDirection.received;
                counterparty = transfer.info.source;
              }
            },
            transferChecked: (transfer) {
              amount = transfer.info.lamports.toString();
              if (transfer.info.source == ownerAddress ||
                  transfer.info.source == trackedAddress) {
                direction = TransactionDirection.sent;
                counterparty = transfer.info.destination;
              } else if (transfer.info.destination == ownerAddress ||
                  transfer.info.destination == trackedAddress) {
                direction = TransactionDirection.received;
                counterparty = transfer.info.source;
              }
            },
            unsupported: (_) {},
          );
          break;
        }

        if (instruction is ParsedInstructionSplToken) {
          instruction.parsed.map(
            transfer: (transfer) {
              amount = transfer.info.amount;
              if (transfer.info.source == trackedAddress) {
                direction = TransactionDirection.sent;
                counterparty = transfer.info.destination;
              } else if (transfer.info.destination == trackedAddress) {
                direction = TransactionDirection.received;
                counterparty = transfer.info.source;
              }
            },
            transferChecked: (transfer) {
              amount =
                  transfer.info.tokenAmount.uiAmountString ??
                  transfer.info.tokenAmount.amount;
              if (transfer.info.source == trackedAddress) {
                direction = TransactionDirection.sent;
                counterparty = transfer.info.destination;
              } else if (transfer.info.destination == trackedAddress) {
                direction = TransactionDirection.received;
                counterparty = transfer.info.source;
              }
            },
            generic: (_) {},
          );
          break;
        }
      }
    }

    return TransactionActivity(
      signature:
          parsedTransaction is ParsedTransaction &&
              parsedTransaction.signatures.isNotEmpty
          ? parsedTransaction.signatures.first
          : '--',
      symbol: symbol,
      kind: TransactionKind.transfer,
      direction: direction,
      amount: amount,
      counterparty: counterparty,
      relatedSymbol: '',
      status: tx.meta?.err == null ? 'success' : 'failed',
      timestamp: tx.blockTime == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              tx.blockTime! * 1000,
              isUtc: true,
            ).toLocal(),
    );
  }
}

TransactionDirection _readDirection(String? value) {
  return switch (value) {
    'sent' => TransactionDirection.sent,
    'received' => TransactionDirection.received,
    _ => TransactionDirection.unknown,
  };
}

TransactionKind _readKind(String? value) {
  return switch (value) {
    'swap' => TransactionKind.swap,
    _ => TransactionKind.transfer,
  };
}
