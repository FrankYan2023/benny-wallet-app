enum ChainFamily { solana, evm }

enum ChainTransactionStatus { pending, finalSuccess, failed, unknown }

class ChainConfig {
  const ChainConfig({
    required this.id,
    required this.family,
    required this.displayName,
    required this.rpcUrl,
    required this.explorerUrl,
    required this.feeSymbol,
    required this.feeDecimals,
    this.chainId,
    this.isTestnet = false,
    this.deterministicFinality = false,
    this.nativeTokenContract,
    this.nativeTokenDecimals,
    this.nativeTransferEmitter,
    this.minimumGasPrice = 0,
  });
  final String id;
  final ChainFamily family;
  final String displayName;
  final String rpcUrl;
  final String explorerUrl;
  final String feeSymbol;
  final int feeDecimals;
  final int? chainId;
  final bool isTestnet;
  final bool deterministicFinality;
  final String? nativeTokenContract;
  final int? nativeTokenDecimals;
  final String? nativeTransferEmitter;
  final int minimumGasPrice;
  String get namespace => family == ChainFamily.evm ? 'eip155:$chainId' : id;
  Uri transactionUrl(String hash) =>
      Uri.parse('$explorerUrl/tx/${Uri.encodeComponent(hash)}');
}

class ChainAccount {
  const ChainAccount({
    required this.rootWalletId,
    required this.chainId,
    required this.address,
    this.canSign = true,
  });
  final String rootWalletId;
  final String chainId;
  final String address;
  final bool canSign;
}

class ChainAsset {
  const ChainAsset({
    required this.chainId,
    required this.symbol,
    required this.name,
    required this.decimals,
    required this.rawBalance,
    this.contractAddress,
    this.logoUrl,
    this.fiatPrice,
    this.isFeeAsset = false,
  });
  final String chainId;
  final String symbol;
  final String name;
  final int decimals;
  final BigInt rawBalance;
  final String? contractAddress;
  final String? logoUrl;
  final double? fiatPrice;
  final bool isFeeAsset;
  bool get isNative => contractAddress == null;
  String get id =>
      '$chainId:${contractAddress?.startsWith("0x") == true ? contractAddress!.toLowerCase() : contractAddress ?? "native"}';
  String get balanceText => formatUnits(rawBalance, decimals);
  ChainAsset withBalance(BigInt balance) => ChainAsset(
    chainId: chainId,
    symbol: symbol,
    name: name,
    decimals: decimals,
    rawBalance: balance,
    contractAddress: contractAddress,
    logoUrl: logoUrl,
    fiatPrice: fiatPrice,
    isFeeAsset: isFeeAsset,
  );
  Map<String, dynamic> toJson() => {
    'chainId': chainId,
    'symbol': symbol,
    'name': name,
    'decimals': decimals,
    'contractAddress': contractAddress,
    'logoUrl': logoUrl,
    'isFeeAsset': isFeeAsset,
  };
  factory ChainAsset.fromJson(Map<String, dynamic> json) => ChainAsset(
    chainId: json['chainId'] as String,
    symbol: json['symbol'] as String,
    name: json['name'] as String,
    decimals: json['decimals'] as int,
    rawBalance: BigInt.zero,
    contractAddress: json['contractAddress'] as String?,
    logoUrl: json['logoUrl'] as String?,
    isFeeAsset: json['isFeeAsset'] == true,
  );
}

class ChainFeeEstimate {
  const ChainFeeEstimate({
    required this.chainId,
    required this.symbol,
    required this.decimals,
    required this.maxFee,
    required this.estimatedFee,
    this.gasLimit,
    this.maxFeePerGas,
    this.maxPriorityFeePerGas,
  });
  final String chainId;
  final String symbol;
  final int decimals;
  final BigInt maxFee;
  final BigInt estimatedFee;
  final BigInt? gasLimit;
  final BigInt? maxFeePerGas;
  final BigInt? maxPriorityFeePerGas;
  String get displayText => '${formatUnits(maxFee, decimals)} $symbol';
}

class ChainTransferRequest {
  const ChainTransferRequest({
    required this.account,
    required this.asset,
    required this.to,
    required this.amount,
  });
  final ChainAccount account;
  final ChainAsset asset;
  final String to;
  final BigInt amount;
}

class PreparedChainTransaction {
  const PreparedChainTransaction({
    required this.request,
    required this.fee,
    required this.payload,
  });
  final ChainTransferRequest request;
  final ChainFeeEstimate fee;

  /// Protocol transaction data, interpreted only by its adapter.
  final Object payload;
}

class SignedChainTransaction {
  const SignedChainTransaction({
    required this.prepared,
    required this.encoded,
    this.transactionHash,
  });
  final PreparedChainTransaction prepared;
  final String encoded;
  final String? transactionHash;
}

class ChainActivity {
  const ChainActivity({
    required this.chainId,
    required this.hash,
    required this.from,
    required this.to,
    required this.asset,
    required this.amount,
    required this.status,
    this.timestamp,
    this.fee,
    this.logIndex,
    this.type = 'transfer',
  });
  final String chainId;
  final String hash;
  final String from;
  final String to;
  final ChainAsset asset;
  final BigInt amount;
  final ChainTransactionStatus status;
  final DateTime? timestamp;
  final BigInt? fee;
  final int? logIndex;
  final String type;
  String get id => '$chainId:$hash:${logIndex ?? "transaction"}';
}

/// Exact base-unit conversion. Never round an amount the user is authorizing.
BigInt parseUnits(String input, int decimals) {
  if (decimals < 0 ||
      decimals > 255 ||
      !RegExp(r'^\d+(\.\d+)?$').hasMatch(input.trim())) {
    throw const FormatException('Enter a positive decimal amount.');
  }
  final parts = input.trim().split('.');
  final fraction = parts.length == 2 ? parts[1] : '';
  if (fraction.length > decimals)
    throw FormatException('Use at most $decimals decimal places.');
  return BigInt.parse(parts[0]) * BigInt.from(10).pow(decimals) +
      (fraction.isEmpty
          ? BigInt.zero
          : BigInt.parse(fraction.padRight(decimals, '0')));
}

String formatUnits(BigInt value, int decimals) {
  if (decimals == 0) return value.toString();
  final digits = value.abs().toString().padLeft(decimals + 1, '0');
  final whole = digits.substring(0, digits.length - decimals);
  final fraction = digits
      .substring(digits.length - decimals)
      .replaceFirst(RegExp(r'0+$'), '');
  return '${value.isNegative ? "-" : ""}$whole${fraction.isEmpty ? "" : ".$fraction"}';
}
