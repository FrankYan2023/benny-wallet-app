import 'dart:convert';
import 'dart:typed_data';

import 'package:solana/base58.dart';

import 'airgap_protocol.dart';

/// Well-known program ids the signer can explain.
abstract final class SolanaPrograms {
  static const system = '11111111111111111111111111111111';
  static const token = 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA';
  static const token2022 = 'TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb';
  static const associatedToken = 'ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL';
  static const computeBudget = 'ComputeBudget111111111111111111111111111111';
  static const memo = 'MemoSq4gqABAXKb96qnH8TysNcWxMyWCqXgDLGmfcHr';
  static const memoV1 = 'Memo1UhkJRfHyvLMcVucJwxXeuD728EqVDDwQDxFMNo';
  static const jupiterV6 = 'JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4';
  static const pumpFun = '6EF8rrecthR5Dkzon8Nwu78hRvfCKubJ14M5uBEwF6P';
  static const pumpAmm = 'pAMMBay6oceH9fJKBRHGP5D4bD4sWpmSwMn52FMfXEA';

  /// PumpPortal's router; the backend builds pump.fun trades through it.
  static const pumpPortal = 'FAdo9NCw1ssek6Z6yeWzWjhLVsr8uiCwcWNUnKgzTnHe';
  static const wrappedSol = 'So11111111111111111111111111111111111111112';
}

class SolanaMessageException implements Exception {
  const SolanaMessageException(this.message);

  final String message;

  @override
  String toString() => 'SolanaMessageException: $message';
}

/// How much attention an instruction needs on the confirm screen.
enum InstructionRisk { normal, notice, danger }

enum ParsedInstructionKind {
  solTransfer,
  tokenTransfer,
  createTokenAccount,
  closeTokenAccount,
  computeUnitLimit,
  computeUnitPrice,
  memo,
  swap,
  tokenApprove,
  setAuthority,
  assignAccount,
  createAccount,
  advanceNonce,
  syncNative,
  unknown,
}

/// Decoded fields of an instruction that name an account. Used to record
/// which of them were read from a lookup table: the signature covers only
/// the table address and index, so the address shown is the wallet's word.
enum AccountField {
  from,
  to,
  owner,
  mint,
  swapInputMint,
  swapOutputMint,

  /// The user's account the swap takes the input from.
  swapInputAccount,

  /// The user's account the swap pays the output into.
  swapOutputAccount,
}

class ParsedInstruction {
  const ParsedInstruction({
    required this.kind,
    required this.programId,
    required this.risk,
    this.from,
    this.to,
    this.owner,
    this.mint,
    this.amount,
    this.decimals,
    this.text,
    this.accounts = const [],
    this.swap,
    this.idempotent = false,
    this.newAccountOwner,
    this.fromTable = const {},
  });

  final ParsedInstructionKind kind;
  final String programId;
  final InstructionRisk risk;

  /// Source account (wallet for SOL, token account for tokens).
  final String? from;

  /// Destination (wallet for SOL, token account for tokens).
  final String? to;

  /// Authority / owner that signs for the source.
  final String? owner;
  final String? mint;

  /// Raw amount: lamports, token base units, compute units or micro-lamports.
  final BigInt? amount;
  final int? decimals;

  /// Memo text.
  final String? text;

  /// Accounts of an unknown instruction, for the generic view.
  final List<String> accounts;

  /// What a swap instruction trades, as far as its layout tells.
  final SwapDetails? swap;

  /// An account creation that does nothing if the account already exists.
  final bool idempotent;

  /// createAccount: the program that will own the new account.
  final String? newAccountOwner;

  /// The decoded fields whose address came from a wallet-supplied lookup
  /// table and so cannot be checked by the signer.
  final Set<AccountField> fromTable;

  /// The source, destination, owner or mint came from a lookup table.
  bool get addressFromTable =>
      fromTable.contains(AccountField.from) ||
      fromTable.contains(AccountField.to) ||
      fromTable.contains(AccountField.owner) ||
      fromTable.contains(AccountField.mint);
}

/// Tokens and amounts of a swap. Mints are null when the instruction does
/// not name them; amounts are raw base units.
class SwapDetails {
  const SwapDetails({
    this.inputMint,
    this.outputMint,
    this.inputAmount,
    this.outputAmount,
    this.inputIsMaximum = false,
    this.outputIsMinimum = false,
    this.inputAccount,
    this.outputAccount,
    this.outputIsNative = false,
    this.slippageBps,
  });

  final String? inputMint;
  final String? outputMint;
  final BigInt? inputAmount;
  final BigInt? outputAmount;

  /// The amount in is a cap (exact-out and pump.fun buys).
  final bool inputIsMaximum;

  /// The amount out is the least accepted (slippage already applied).
  final bool outputIsMinimum;

  /// The user's token account the input is taken from (null: native SOL
  /// from the user's wallet, or not named).
  final String? inputAccount;

  /// Where the output is paid: the user's token account, or with
  /// [outputIsNative] the wallet that receives native SOL.
  final String? outputAccount;
  final bool outputIsNative;

  /// Slippage the route allows, in basis points (Jupiter only).
  final int? slippageBps;
}

class ParsedSolanaMessage {
  ParsedSolanaMessage({
    required this.version,
    required this.feePayer,
    required this.requiredSigners,
    required this.recentBlockhash,
    required this.instructions,
    required this.hasUnresolvedAccounts,
    required this.usesLookupTables,
    required this.estimatedFeeLamports,
    this.lookupReferences = const {},
    this.accountKeys = const [],
    this.staticAccountKeys = const [],
    this.referencedAccounts = const {},
    BigInt? priorityFeeLamports,
  }) : priorityFeeLamports = priorityFeeLamports ?? BigInt.zero;

  /// null for legacy messages, else the version number (0).
  final int? version;
  final String feePayer;
  final List<String> requiredSigners;
  final String recentBlockhash;
  final List<ParsedInstruction> instructions;

  /// Lookup-table accounts that the request did not supply.
  final bool hasUnresolvedAccounts;
  final bool usesLookupTables;
  final BigInt estimatedFeeLamports;

  /// Lookup table address (base58) → indexes the message reads from it.
  /// The online wallet uses this to fetch exactly the entries to send.
  final Map<String, Set<int>> lookupReferences;

  /// Every account the message reads or writes that the signer could
  /// resolve, static keys first.
  final List<String> accountKeys;

  /// The keys written in the message itself (covered by the signature).
  final List<String> staticAccountKeys;

  /// Accounts some instruction actually uses (accounts and programs).
  final Set<String> referencedAccounts;

  /// The part of [estimatedFeeLamports] above the base signature fee.
  final BigInt priorityFeeLamports;

  InstructionRisk get highestRisk {
    var risk = hasUnresolvedAccounts
        ? InstructionRisk.danger
        : InstructionRisk.normal;
    for (final instruction in instructions) {
      if (instruction.risk.index > risk.index) {
        risk = instruction.risk;
      }
    }
    return risk;
  }
}

class _Reader {
  _Reader(this.bytes);

  final Uint8List bytes;
  int offset = 0;

  bool get isDone => offset == bytes.length;

  int u8() {
    if (offset >= bytes.length) {
      throw const SolanaMessageException('Message ends early.');
    }
    return bytes[offset++];
  }

  int compactU16() {
    var value = 0;
    for (var i = 0; i < 3; i++) {
      final byte = u8();
      value |= (byte & 0x7f) << (7 * i);
      if ((byte & 0x80) == 0) {
        return value;
      }
    }
    throw const SolanaMessageException('Invalid compact length.');
  }

  Uint8List take(int length) {
    if (length < 0 || length > bytes.length - offset) {
      throw const SolanaMessageException('Message ends early.');
    }
    final out = Uint8List.fromList(bytes.sublist(offset, offset + length));
    offset += length;
    return out;
  }
}

class _Data {
  _Data(this.bytes);

  final Uint8List bytes;

  bool has(int offset, int length) => bytes.length >= offset + length;

  bool startsWith(List<int> prefix) {
    if (bytes.length < prefix.length) {
      return false;
    }
    for (var i = 0; i < prefix.length; i++) {
      if (bytes[i] != prefix[i]) {
        return false;
      }
    }
    return true;
  }

  BigInt uLe(int offset, int length) {
    var value = BigInt.zero;
    for (var i = length - 1; i >= 0; i--) {
      value = (value << 8) | BigInt.from(bytes[offset + i]);
    }
    return value;
  }
}

/// Parses Solana message bytes (legacy and v0) entirely offline and turns
/// the instructions the signer knows into human-readable entries. Anything
/// it does not understand is reported as [InstructionRisk.danger].
abstract final class SolanaMessageParser {
  static const baseFeeLamportsPerSignature = 5000;
  static const _defaultComputeUnitsPerInstruction = 200000;

  /// True when [bytes] decode as a complete Solana message. Used to refuse
  /// "message" signatures that are really transactions.
  static bool looksLikeTransaction(Uint8List bytes) {
    try {
      parse(bytes);
      return true;
    } on Object {
      return false;
    }
  }

  static ParsedSolanaMessage parse(
    Uint8List bytes, {
    List<AirGapLookupTable> lookupTables = const [],
  }) {
    final reader = _Reader(bytes);
    int? version;
    var first = reader.u8();
    if (first & 0x80 != 0) {
      version = first & 0x7f;
      if (version != 0) {
        throw SolanaMessageException('Unsupported message version $version.');
      }
      first = reader.u8();
    }
    final numRequiredSignatures = first;
    reader
      ..u8() // read-only signed
      ..u8(); // read-only unsigned
    final keyCount = reader.compactU16();
    if (keyCount == 0 || keyCount > 256) {
      throw const SolanaMessageException('Invalid account count.');
    }
    final staticKeys = [
      for (var i = 0; i < keyCount; i++) base58encode(reader.take(32)),
    ];
    if (numRequiredSignatures == 0 || numRequiredSignatures > keyCount) {
      throw const SolanaMessageException('Invalid signer count.');
    }
    final blockhash = base58encode(reader.take(32));
    final instructionCount = reader.compactU16();
    if (instructionCount > 64) {
      throw const SolanaMessageException('Too many instructions.');
    }
    final rawInstructions = <(int, List<int>, Uint8List)>[];
    for (var i = 0; i < instructionCount; i++) {
      final programIndex = reader.u8();
      final accountCount = reader.compactU16();
      final accounts = [for (var j = 0; j < accountCount; j++) reader.u8()];
      final dataLength = reader.compactU16();
      rawInstructions.add((programIndex, accounts, reader.take(dataLength)));
    }

    // v0: append lookup-table accounts (all writable first, then readonly).
    final writableLookups = <String?>[];
    final readonlyLookups = <String?>[];
    var usesLookupTables = false;
    final lookupReferences = <String, Set<int>>{};
    if (version == 0) {
      final tableCount = reader.compactU16();
      for (var i = 0; i < tableCount; i++) {
        usesLookupTables = true;
        final tableKey = reader.take(32);
        final writable = [
          for (var j = 0, n = reader.compactU16(); j < n; j++) reader.u8(),
        ];
        final readonly = [
          for (var j = 0, n = reader.compactU16(); j < n; j++) reader.u8(),
        ];
        lookupReferences
            .putIfAbsent(base58encode(tableKey), () => <int>{})
            .addAll([...writable, ...readonly]);
        final table = lookupTables
            .where((t) => sameBytes(t.address, tableKey))
            .firstOrNull;
        String? resolve(int index) {
          final key = table?.entries[index];
          return key == null ? null : base58encode(key);
        }

        writableLookups.addAll(writable.map(resolve));
        readonlyLookups.addAll(readonly.map(resolve));
      }
    }
    if (!reader.isDone) {
      throw const SolanaMessageException('Trailing bytes in message.');
    }

    final allKeys = <String?>[
      ...staticKeys,
      ...writableLookups,
      ...readonlyLookups,
    ];
    var unresolved = false;
    String account(int index) {
      if (index >= allKeys.length) {
        throw const SolanaMessageException('Account index out of range.');
      }
      final key = allKeys[index];
      if (key == null) {
        unresolved = true;
        return '?';
      }
      return key;
    }

    final instructions = <ParsedInstruction>[];
    final referenced = <String>{};
    BigInt? unitLimit;
    BigInt? unitPrice;
    for (final (programIndex, accountIndexes, data) in rawInstructions) {
      if (programIndex >= staticKeys.length) {
        throw const SolanaMessageException('Program must be a static key.');
      }
      final programId = staticKeys[programIndex];
      final accounts = [for (final index in accountIndexes) account(index)];
      referenced
        ..add(programId)
        ..addAll(accounts.where((a) => a != '?'));
      // Positions whose address the wallet supplied through a table.
      bool fromTable(int position) =>
          position < accountIndexes.length &&
          accountIndexes[position] >= staticKeys.length;
      final parsed = _parseInstruction(programId, accounts, data, fromTable);
      if (parsed.kind == ParsedInstructionKind.computeUnitLimit) {
        unitLimit = parsed.amount;
      } else if (parsed.kind == ParsedInstructionKind.computeUnitPrice) {
        unitPrice = parsed.amount;
      }
      instructions.add(parsed);
    }

    final baseFee = BigInt.from(
      baseFeeLamportsPerSignature * numRequiredSignatures,
    );
    var fee = baseFee;
    if (unitPrice != null) {
      final units =
          unitLimit ??
          BigInt.from(
            _defaultComputeUnitsPerInstruction *
                instructions
                    .where((i) => i.programId != SolanaPrograms.computeBudget)
                    .length,
          );
      // micro-lamports per unit, rounded up.
      fee += (unitPrice * units + BigInt.from(999999)) ~/ BigInt.from(1000000);
    }

    return ParsedSolanaMessage(
      version: version,
      feePayer: staticKeys.first,
      requiredSigners: staticKeys.sublist(0, numRequiredSignatures),
      recentBlockhash: blockhash,
      instructions: instructions,
      hasUnresolvedAccounts: unresolved,
      usesLookupTables: usesLookupTables,
      estimatedFeeLamports: fee,
      lookupReferences: lookupReferences,
      accountKeys: allKeys.nonNulls.toList(),
      staticAccountKeys: staticKeys,
      referencedAccounts: referenced,
      priorityFeeLamports: fee - baseFee,
    );
  }

  static ParsedInstruction _parseInstruction(
    String programId,
    List<String> accounts,
    Uint8List bytes,
    bool Function(int position) tableAt,
  ) {
    final data = _Data(bytes);
    Set<AccountField> table(Map<AccountField, int> positions) => {
      for (final MapEntry(:key, :value) in positions.entries)
        if (tableAt(value)) key,
    };
    ParsedInstruction unknown([InstructionRisk risk = InstructionRisk.danger]) {
      return ParsedInstruction(
        kind: ParsedInstructionKind.unknown,
        programId: programId,
        risk: risk,
        accounts: accounts,
      );
    }

    String? at(int index) => index < accounts.length ? accounts[index] : null;

    switch (programId) {
      case SolanaPrograms.system:
        if (!data.has(0, 4)) {
          return unknown();
        }
        final type = data.uLe(0, 4).toInt();
        switch (type) {
          case 2 when data.has(4, 8):
            final fields = table({AccountField.from: 0, AccountField.to: 1});
            return ParsedInstruction(
              kind: ParsedInstructionKind.solTransfer,
              programId: programId,
              // A destination from a table is the wallet's word only.
              risk: fields.isEmpty
                  ? InstructionRisk.normal
                  : InstructionRisk.danger,
              from: at(0),
              to: at(1),
              amount: data.uLe(4, 8),
              fromTable: fields,
            );
          case 0 when data.has(4, 8):
            // u32 type, u64 lamports, u64 space, owner program.
            final owner = data.has(20, 32)
                ? base58encode(Uint8List.sublistView(bytes, 20, 52))
                : null;
            final standard =
                owner == SolanaPrograms.system ||
                owner == SolanaPrograms.token ||
                owner == SolanaPrograms.token2022;
            return ParsedInstruction(
              kind: ParsedInstructionKind.createAccount,
              programId: programId,
              // Another program would own (and could move) the lamports.
              risk: standard ? InstructionRisk.notice : InstructionRisk.danger,
              from: at(0),
              to: at(1),
              amount: data.uLe(4, 8),
              newAccountOwner: owner,
              fromTable: table({AccountField.from: 0, AccountField.to: 1}),
            );
          case 1:
            return ParsedInstruction(
              kind: ParsedInstructionKind.assignAccount,
              programId: programId,
              risk: InstructionRisk.danger,
              from: at(0),
              accounts: accounts,
            );
          case 4:
            // A durable nonce: the signature never expires.
            return ParsedInstruction(
              kind: ParsedInstructionKind.advanceNonce,
              programId: programId,
              risk: InstructionRisk.notice,
              from: at(0),
            );
        }
        return unknown();
      case SolanaPrograms.token:
      case SolanaPrograms.token2022:
        if (!data.has(0, 1)) {
          return unknown();
        }
        switch (bytes[0]) {
          case 3 when data.has(1, 8):
            final fields = table({
              AccountField.from: 0,
              AccountField.to: 1,
              AccountField.owner: 2,
            });
            return ParsedInstruction(
              kind: ParsedInstructionKind.tokenTransfer,
              programId: programId,
              risk: fields.isEmpty
                  ? InstructionRisk.notice
                  : InstructionRisk.danger,
              from: at(0),
              to: at(1),
              owner: at(2),
              amount: data.uLe(1, 8),
              fromTable: fields,
            );
          case 12 when data.has(1, 9):
            final fields = table({
              AccountField.from: 0,
              AccountField.mint: 1,
              AccountField.to: 2,
              AccountField.owner: 3,
            });
            return ParsedInstruction(
              kind: ParsedInstructionKind.tokenTransfer,
              programId: programId,
              risk: fields.isEmpty
                  ? InstructionRisk.normal
                  : InstructionRisk.danger,
              from: at(0),
              mint: at(1),
              to: at(2),
              owner: at(3),
              amount: data.uLe(1, 8),
              decimals: bytes[9],
              fromTable: fields,
            );
          case 4 || 13:
            return ParsedInstruction(
              kind: ParsedInstructionKind.tokenApprove,
              programId: programId,
              risk: InstructionRisk.danger,
              from: at(0),
              to: bytes[0] == 4 ? at(1) : at(2),
              amount: data.has(1, 8) ? data.uLe(1, 8) : null,
              accounts: accounts,
            );
          case 6:
            return ParsedInstruction(
              kind: ParsedInstructionKind.setAuthority,
              programId: programId,
              risk: InstructionRisk.danger,
              from: at(0),
              accounts: accounts,
            );
          case 9:
            return ParsedInstruction(
              kind: ParsedInstructionKind.closeTokenAccount,
              programId: programId,
              risk: InstructionRisk.notice,
              from: at(0),
              to: at(1),
              owner: at(2),
              fromTable: table({
                AccountField.from: 0,
                AccountField.to: 1,
                AccountField.owner: 2,
              }),
            );
          case 17:
            return ParsedInstruction(
              kind: ParsedInstructionKind.syncNative,
              programId: programId,
              risk: InstructionRisk.normal,
              from: at(0),
            );
          case 1 || 16 || 18:
            return ParsedInstruction(
              kind: ParsedInstructionKind.createTokenAccount,
              programId: programId,
              risk: InstructionRisk.normal,
              to: at(0),
              mint: at(1),
              fromTable: table({AccountField.to: 0, AccountField.mint: 1}),
            );
        }
        return unknown();
      case SolanaPrograms.associatedToken:
        if (bytes.isEmpty || bytes[0] == 0 || bytes[0] == 1) {
          return ParsedInstruction(
            kind: ParsedInstructionKind.createTokenAccount,
            programId: programId,
            risk: InstructionRisk.normal,
            from: at(0),
            to: at(1),
            owner: at(2),
            mint: at(3),
            idempotent: bytes.isNotEmpty && bytes[0] == 1,
            fromTable: table({
              AccountField.from: 0,
              AccountField.to: 1,
              AccountField.owner: 2,
              AccountField.mint: 3,
            }),
          );
        }
        return unknown();
      case SolanaPrograms.computeBudget:
        if (data.has(0, 5) && bytes[0] == 2) {
          return ParsedInstruction(
            kind: ParsedInstructionKind.computeUnitLimit,
            programId: programId,
            risk: InstructionRisk.normal,
            amount: data.uLe(1, 4),
          );
        }
        if (data.has(0, 9) && bytes[0] == 3) {
          return ParsedInstruction(
            kind: ParsedInstructionKind.computeUnitPrice,
            programId: programId,
            risk: InstructionRisk.normal,
            amount: data.uLe(1, 8),
          );
        }
        return unknown(InstructionRisk.notice);
      case SolanaPrograms.memo:
      case SolanaPrograms.memoV1:
        return ParsedInstruction(
          kind: ParsedInstructionKind.memo,
          programId: programId,
          risk: InstructionRisk.normal,
          text: utf8.decode(bytes, allowMalformed: true),
        );
      case SolanaPrograms.jupiterV6:
        final (swap, positions) =
            _jupiterSwap(data, at) ?? (null, const <AccountField, int>{});
        final slippage = swap?.slippageBps ?? 0;
        return ParsedInstruction(
          kind: ParsedInstructionKind.swap,
          programId: programId,
          // 100% slippage or more accepts getting nothing back.
          risk: slippage >= 10000
              ? InstructionRisk.danger
              : InstructionRisk.notice,
          accounts: accounts,
          swap: swap,
          fromTable: table(positions),
        );
      case SolanaPrograms.pumpFun:
      case SolanaPrograms.pumpAmm:
      case SolanaPrograms.pumpPortal:
        final swap = switch (programId) {
          SolanaPrograms.pumpFun => _pumpFunSwap(data, at),
          SolanaPrograms.pumpPortal => _pumpFunSwap(
            data,
            at,
            buy: _portalBuy,
            sell: _portalSell,
            buyExactSolIn: null,
          ),
          _ => _pumpAmmSwap(data, at),
        };
        if (swap == null) {
          return unknown(InstructionRisk.notice);
        }
        return ParsedInstruction(
          kind: ParsedInstructionKind.swap,
          programId: programId,
          risk: InstructionRisk.notice,
          accounts: accounts,
          swap: swap.$1,
          fromTable: table(swap.$2),
        );
    }
    return unknown();
  }

  // Anchor discriminators: sha256("global:<name>")[0..8].
  static const _jupRoute = [229, 23, 203, 151, 122, 227, 173, 42];
  static const _jupSharedRoute = [193, 32, 155, 51, 65, 214, 156, 129];
  static const _jupExactOut = [208, 51, 239, 151, 123, 43, 237, 92];
  static const _jupSharedExactOut = [176, 209, 105, 168, 154, 125, 69, 62];
  static const _jupRouteLedger = [150, 86, 71, 116, 167, 93, 14, 104];
  static const _jupSharedRouteLedger = [230, 121, 143, 80, 119, 159, 106, 170];
  static const _buy = [102, 6, 61, 18, 1, 218, 235, 234];
  static const _sell = [51, 230, 133, 164, 1, 127, 131, 173];
  // PumpPortal keeps pump.fun's accounts and arguments; only the second
  // discriminator byte differs.
  static const _portalBuy = [102, 50, 61, 18, 1, 218, 235, 234];
  static const _portalSell = [51, 50, 133, 164, 1, 127, 131, 173];
  static const _buyExactSolIn = [56, 252, 116, 8, 158, 223, 205, 95];
  static const _buyExactQuoteIn = [198, 46, 21, 82, 180, 217, 232, 112];

  /// Jupiter v6 routes end with (in, quoted out, slippage bps u16, platform
  /// fee bps u8); exact-out routes with (out, quoted in, slippage, fee).
  ///
  /// Accounts: `route`, `exact_out_route` and `route_with_token_ledger` take
  /// the user's source at 2, destination at 3 and an optional final
  /// destination at 4 (the Jupiter program id when unset). The `shared_*`
  /// variants take the user's source at 3, destination at 6, mints at 7, 8.
  static (SwapDetails, Map<AccountField, int>)? _jupiterSwap(
    _Data data,
    String? Function(int) at,
  ) {
    final length = data.bytes.length;
    if (length < 8 + 19) {
      return null;
    }
    BigInt tail(int fromEnd) => data.uLe(length - fromEnd, 8);
    final slippage = data.uLe(length - 3, 2).toInt();
    BigInt minimum(BigInt quoted) => slippage >= 10000
        ? BigInt.zero
        : quoted * BigInt.from(10000 - slippage) ~/ BigInt.from(10000);
    BigInt maximum(BigInt quoted) =>
        quoted * BigInt.from(10000 + slippage) ~/ BigInt.from(10000);

    final shared =
        data.startsWith(_jupSharedRoute) ||
        data.startsWith(_jupSharedExactOut) ||
        data.startsWith(_jupSharedRouteLedger);
    final int inputAccount;
    final int outputAccount;
    if (shared) {
      inputAccount = 3;
      outputAccount = 6;
    } else {
      final finalDestination = at(4);
      inputAccount = 2;
      outputAccount =
          finalDestination != null &&
              finalDestination != SolanaPrograms.jupiterV6
          ? 4
          : 3;
    }
    (SwapDetails, Map<AccountField, int>) details({
      int? inputMint,
      required int outputMint,
      BigInt? inputAmount,
      BigInt? outputAmount,
      bool inputIsMaximum = false,
      bool outputIsMinimum = false,
    }) => (
      SwapDetails(
        inputMint: inputMint == null ? null : at(inputMint),
        outputMint: at(outputMint),
        inputAmount: inputAmount,
        outputAmount: outputAmount,
        inputIsMaximum: inputIsMaximum,
        outputIsMinimum: outputIsMinimum,
        inputAccount: at(inputAccount),
        outputAccount: at(outputAccount),
        slippageBps: slippage,
      ),
      {
        AccountField.swapInputMint: ?inputMint,
        AccountField.swapOutputMint: outputMint,
        AccountField.swapInputAccount: inputAccount,
        AccountField.swapOutputAccount: outputAccount,
      },
    );

    if (data.startsWith(_jupRoute) || data.startsWith(_jupSharedRoute)) {
      return details(
        inputMint: shared ? 7 : null,
        outputMint: shared ? 8 : 5,
        inputAmount: tail(19),
        outputAmount: minimum(tail(11)),
        outputIsMinimum: true,
      );
    }
    if (data.startsWith(_jupExactOut) || data.startsWith(_jupSharedExactOut)) {
      return details(
        inputMint: shared ? 7 : 5,
        outputMint: shared ? 8 : 6,
        inputAmount: maximum(tail(11)),
        outputAmount: tail(19),
        inputIsMaximum: true,
      );
    }
    if (data.startsWith(_jupRouteLedger) ||
        data.startsWith(_jupSharedRouteLedger)) {
      return details(
        inputMint: shared ? 7 : null,
        outputMint: shared ? 8 : 5,
        outputAmount: minimum(tail(11)),
        outputIsMinimum: true,
      );
    }
    return null;
  }

  /// pump.fun bonding curve (and PumpPortal, same accounts): the token mint
  /// is account 2, the user's token account (`associated_user`) 5 and the
  /// user's wallet 6; the other side is always native SOL.
  static (SwapDetails, Map<AccountField, int>)? _pumpFunSwap(
    _Data data,
    String? Function(int) at, {
    List<int> buy = _buy,
    List<int> sell = _sell,
    List<int>? buyExactSolIn = _buyExactSolIn,
  }) {
    if (!data.has(8, 16)) {
      return null;
    }
    final mint = at(2);
    const buyFields = {
      AccountField.swapOutputMint: 2,
      AccountField.swapOutputAccount: 5,
    };
    if (data.startsWith(buy)) {
      return (
        SwapDetails(
          inputMint: SolanaPrograms.wrappedSol,
          outputMint: mint,
          inputAmount: data.uLe(16, 8),
          outputAmount: data.uLe(8, 8),
          inputIsMaximum: true,
          outputAccount: at(5),
        ),
        buyFields,
      );
    }
    if (buyExactSolIn != null && data.startsWith(buyExactSolIn)) {
      return (
        SwapDetails(
          inputMint: SolanaPrograms.wrappedSol,
          outputMint: mint,
          inputAmount: data.uLe(8, 8),
          outputAmount: data.uLe(16, 8),
          outputIsMinimum: true,
          outputAccount: at(5),
        ),
        buyFields,
      );
    }
    if (data.startsWith(sell)) {
      return (
        SwapDetails(
          inputMint: mint,
          outputMint: SolanaPrograms.wrappedSol,
          inputAmount: data.uLe(8, 8),
          outputAmount: data.uLe(16, 8),
          outputIsMinimum: true,
          inputAccount: at(5),
          outputAccount: at(6),
          outputIsNative: true,
        ),
        const {
          AccountField.swapInputMint: 2,
          AccountField.swapInputAccount: 5,
          AccountField.swapOutputAccount: 6,
        },
      );
    }
    return null;
  }

  /// PumpSwap AMM: base mint is account 3, quote mint account 4, the user's
  /// base token account 5 and quote token account 6.
  static (SwapDetails, Map<AccountField, int>)? _pumpAmmSwap(
    _Data data,
    String? Function(int) at,
  ) {
    if (!data.has(8, 16)) {
      return null;
    }
    final base = at(3);
    final quote = at(4);
    const buyFields = {
      AccountField.swapInputMint: 4,
      AccountField.swapOutputMint: 3,
      AccountField.swapInputAccount: 6,
      AccountField.swapOutputAccount: 5,
    };
    if (data.startsWith(_buy)) {
      return (
        SwapDetails(
          inputMint: quote,
          outputMint: base,
          inputAmount: data.uLe(16, 8),
          outputAmount: data.uLe(8, 8),
          inputIsMaximum: true,
          inputAccount: at(6),
          outputAccount: at(5),
        ),
        buyFields,
      );
    }
    if (data.startsWith(_buyExactQuoteIn)) {
      return (
        SwapDetails(
          inputMint: quote,
          outputMint: base,
          inputAmount: data.uLe(8, 8),
          outputAmount: data.uLe(16, 8),
          outputIsMinimum: true,
          inputAccount: at(6),
          outputAccount: at(5),
        ),
        buyFields,
      );
    }
    if (data.startsWith(_sell)) {
      return (
        SwapDetails(
          inputMint: base,
          outputMint: quote,
          inputAmount: data.uLe(8, 8),
          outputAmount: data.uLe(16, 8),
          outputIsMinimum: true,
          inputAccount: at(5),
          outputAccount: at(6),
        ),
        const {
          AccountField.swapInputMint: 3,
          AccountField.swapOutputMint: 4,
          AccountField.swapInputAccount: 5,
          AccountField.swapOutputAccount: 6,
        },
      );
    }
    return null;
  }
}
