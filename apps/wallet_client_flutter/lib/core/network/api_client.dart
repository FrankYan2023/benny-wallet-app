import 'package:dio/dio.dart';
import 'package:shared_types/shared_types.dart';

import '../constants/app_constants.dart';
import 'backend_session_manager.dart';

class RemoteAppConfig {
  const RemoteAppConfig({
    required this.assetRefreshIntervalSec,
    required this.priceRefreshIntervalSec,
    required this.supportBiometric,
    required this.supportMnemonicExport,
  });

  final int assetRefreshIntervalSec;
  final int priceRefreshIntervalSec;
  final bool supportBiometric;
  final bool supportMnemonicExport;

  factory RemoteAppConfig.fromJson(Map<String, dynamic> json) {
    return RemoteAppConfig(
      assetRefreshIntervalSec: json['assetRefreshIntervalSec'] as int,
      priceRefreshIntervalSec: json['priceRefreshIntervalSec'] as int,
      supportBiometric: json['supportBiometric'] as bool,
      supportMnemonicExport: json['supportMnemonicExport'] as bool,
    );
  }
}

class RemoteAppUpdateInfo {
  const RemoteAppUpdateInfo({
    required this.configured,
    required this.currentBuild,
    required this.downloadUrl,
    required this.latestBuild,
    required this.latestVersion,
    required this.message,
    required this.minSupportedBuild,
    required this.platform,
    required this.required,
    required this.storeUrl,
    required this.title,
    required this.updateAvailable,
  });

  final bool configured;
  final int currentBuild;
  final String? downloadUrl;
  final int? latestBuild;
  final String? latestVersion;
  final String? message;
  final int? minSupportedBuild;
  final String platform;
  final bool required;
  final String? storeUrl;
  final String? title;
  final bool updateAvailable;

  factory RemoteAppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return RemoteAppUpdateInfo(
      configured: json['configured'] as bool? ?? false,
      currentBuild: json['currentBuild'] as int? ?? 0,
      downloadUrl: json['downloadUrl'] as String?,
      latestBuild: json['latestBuild'] as int?,
      latestVersion: json['latestVersion'] as String?,
      message: json['message'] as String?,
      minSupportedBuild: json['minSupportedBuild'] as int?,
      platform: json['platform'] as String? ?? 'unknown',
      required: json['required'] as bool? ?? false,
      storeUrl: json['storeUrl'] as String?,
      title: json['title'] as String?,
      updateAvailable: json['updateAvailable'] as bool? ?? false,
    );
  }
}

class RemoteTokenCatalogItem {
  const RemoteTokenCatalogItem({
    required this.mintAddress,
    required this.symbol,
    required this.name,
    required this.decimals,
    required this.logoUrl,
    required this.isNative,
    required this.isVisible,
    required this.category,
  });

  final String mintAddress;
  final String symbol;
  final String name;
  final int decimals;
  final String logoUrl;
  final bool isNative;
  final bool isVisible;
  final String category;

  factory RemoteTokenCatalogItem.fromJson(Map<String, dynamic> json) {
    return RemoteTokenCatalogItem(
      mintAddress: json['mintAddress'] as String,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      decimals: json['decimals'] as int,
      logoUrl: json['logoUrl'] as String? ?? '',
      isNative: json['isNative'] as bool? ?? false,
      isVisible: json['isVisible'] as bool? ?? true,
      category: json['category'] as String? ?? 'core',
    );
  }
}

class RemoteImportWalletScanItem {
  const RemoteImportWalletScanItem({
    required this.address,
    required this.assetCount,
  });

  final String address;
  final int assetCount;

  factory RemoteImportWalletScanItem.fromJson(Map<String, dynamic> json) {
    return RemoteImportWalletScanItem(
      address: json['address'] as String? ?? '',
      assetCount: (json['assetCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class RemoteWalletProfile {
  const RemoteWalletProfile({
    required this.ownerAddress,
    required this.accountRole,
    required this.childModeEnabled,
    required this.childModePinCipherText,
    required this.childModePinNonce,
    required this.childModePinSalt,
  });

  final String ownerAddress;
  final String accountRole;
  final bool childModeEnabled;
  final String childModePinCipherText;
  final String childModePinNonce;
  final String childModePinSalt;

  bool get hasChildModePin =>
      childModePinCipherText.isNotEmpty &&
      childModePinNonce.isNotEmpty &&
      childModePinSalt.isNotEmpty;

  factory RemoteWalletProfile.fromJson(Map<String, dynamic> json) {
    return RemoteWalletProfile(
      ownerAddress: json['ownerAddress'] as String? ?? '',
      accountRole: json['accountRole'] as String? ?? 'parent',
      childModeEnabled: json['childModeEnabled'] as bool? ?? false,
      childModePinCipherText: json['childModePinCipherText'] as String? ?? '',
      childModePinNonce: json['childModePinNonce'] as String? ?? '',
      childModePinSalt: json['childModePinSalt'] as String? ?? '',
    );
  }
}

class RemoteChildAccount {
  const RemoteChildAccount({
    required this.id,
    required this.parentAddress,
    required this.childAddress,
    required this.childName,
    required this.status,
  });

  final String id;
  final String parentAddress;
  final String childAddress;
  final String childName;
  final String status;

  factory RemoteChildAccount.fromJson(Map<String, dynamic> json) {
    return RemoteChildAccount(
      id: json['id'] as String? ?? '',
      parentAddress: json['parentAddress'] as String? ?? '',
      childAddress: json['childAddress'] as String? ?? '',
      childName: json['childName'] as String? ?? 'Child',
      status: json['status'] as String? ?? 'active',
    );
  }
}

class RemoteWalletProfileSnapshot {
  const RemoteWalletProfileSnapshot({
    required this.profile,
    required this.childAccounts,
  });

  final RemoteWalletProfile profile;
  final List<RemoteChildAccount> childAccounts;

  factory RemoteWalletProfileSnapshot.fromJson(Map<String, dynamic> json) {
    final profileJson = json['profile'];
    final childAccountsJson =
        json['childAccounts'] as List<dynamic>? ?? const [];
    return RemoteWalletProfileSnapshot(
      profile: RemoteWalletProfile.fromJson(
        profileJson is Map<String, dynamic> ? profileJson : const {},
      ),
      childAccounts: childAccountsJson
          .whereType<Map<String, dynamic>>()
          .map(RemoteChildAccount.fromJson)
          .toList(growable: false),
    );
  }

  bool get hasCloudData {
    return profile.childModeEnabled ||
        profile.accountRole == 'child' ||
        profile.hasChildModePin ||
        childAccounts.isNotEmpty;
  }
}

class RemoteSendHistoryItem {
  const RemoteSendHistoryItem({
    required this.signature,
    required this.txType,
    required this.status,
    required this.result,
    required this.statusSource,
    required this.submittedAt,
    this.fromMint,
    this.toMint,
    this.amount,
    this.referenceId,
    this.destinationAddress,
    this.feeLamports,
    this.errorMessage,
    this.description,
    this.confirmedAt,
    this.finalizedAt,
  });

  final String signature;
  final String txType;
  final String status;
  final String result;
  final String statusSource;
  final String? fromMint;
  final String? toMint;
  final String? amount;
  final String? referenceId;
  final String? destinationAddress;
  final int? feeLamports;
  final String? errorMessage;
  final String? description;
  final String submittedAt;
  final String? confirmedAt;
  final String? finalizedAt;

  factory RemoteSendHistoryItem.fromJson(Map<String, dynamic> json) {
    final requestPayload = json['requestPayload'];
    String? destinationAddress;
    final topLevelDestinationAddress = json['destinationAddress'];
    if (topLevelDestinationAddress is String &&
        topLevelDestinationAddress.trim().isNotEmpty) {
      destinationAddress = topLevelDestinationAddress.trim();
    }
    if (requestPayload is Map) {
      final value = requestPayload['destinationAddress'];
      if (value is String && value.trim().isNotEmpty) {
        destinationAddress = value.trim();
      }
    }

    return RemoteSendHistoryItem(
      signature: json['signature'] as String? ?? '',
      txType: json['txType'] as String? ?? 'send',
      status: json['status'] as String? ?? 'submitted',
      result: json['result'] as String? ?? 'pending',
      statusSource: json['statusSource'] as String? ?? 'sender_submit',
      fromMint: json['fromMint'] as String?,
      toMint: json['toMint'] as String?,
      amount: json['amount'] as String?,
      referenceId: json['referenceId'] as String?,
      destinationAddress: destinationAddress,
      feeLamports: (json['feeLamports'] as num?)?.toInt(),
      errorMessage: json['errorMessage'] as String?,
      description: json['description'] as String?,
      submittedAt: json['submittedAt'] as String? ?? '',
      confirmedAt: json['confirmedAt'] as String?,
      finalizedAt: json['finalizedAt'] as String?,
    );
  }
}

class RemoteReceivedTransferItem {
  const RemoteReceivedTransferItem({
    required this.id,
    required this.signature,
    required this.recipientAddress,
    required this.mintAddress,
    required this.symbol,
    required this.name,
    required this.logoUrl,
    required this.amountText,
    required this.status,
    required this.createdAt,
    this.relatedTransfers = const [],
    this.senderAddress,
    this.slot,
    this.feeLamports,
    this.notifiedAt,
    this.confirmedAt,
  });

  final String id;
  final String signature;
  final String recipientAddress;
  final String? senderAddress;
  final String mintAddress;
  final String symbol;
  final String name;
  final String logoUrl;
  final String amountText;
  final int? slot;
  final int? feeLamports;
  final String status;
  final String? notifiedAt;
  final String? confirmedAt;
  final String createdAt;
  final List<RemoteReceivedTransferItem> relatedTransfers;

  factory RemoteReceivedTransferItem.fromJson(Map<String, dynamic> json) {
    return RemoteReceivedTransferItem(
      id: json['id'] as String? ?? '',
      signature: json['signature'] as String? ?? '',
      recipientAddress: json['recipientAddress'] as String? ?? '',
      senderAddress: _readNonEmptyString(json['senderAddress']),
      mintAddress: json['mintAddress'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      logoUrl: json['logoUrl'] as String? ?? '',
      amountText: json['amountText'] as String? ?? '',
      slot: (json['slot'] as num?)?.toInt(),
      feeLamports: (json['feeLamports'] as num?)?.toInt(),
      status: json['status'] as String? ?? 'confirmed',
      notifiedAt: json['notifiedAt'] as String?,
      confirmedAt: json['confirmedAt'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
      relatedTransfers: (json['relatedTransfers'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(
            (item) => RemoteReceivedTransferItem.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    );
  }

  String get displayAmount {
    if (amountText.isEmpty) {
      return symbol;
    }
    if (symbol.isEmpty) {
      return amountText;
    }
    return '$amountText $symbol';
  }
}

String? _readNonEmptyString(Object? value) {
  if (value is! String || value.trim().isEmpty) {
    return null;
  }
  return value.trim();
}

class BackendApiClient {
  BackendApiClient({BackendSessionManager? sessionManager, Dio? dio})
    : _sessionManager = sessionManager,
      _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AppConstants.apiBaseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

  final Dio _dio;
  final BackendSessionManager? _sessionManager;

  Future<Map<String, dynamic>> getPortfolio(String ownerAddress) async {
    return _requestJsonMap(
      () => _dio.post<Map<String, dynamic>>(
        '/v1/portfolio',
        data: {'ownerAddress': ownerAddress},
      ),
      fallback: 'Unable to load your wallet right now.',
    );
  }

  Future<List<RemoteImportWalletScanItem>> scanImportWalletAddresses(
    List<String> addresses, {
    List<String> fallbackAddresses = const [],
  }) async {
    final payload = await _requestJsonMap(
      () => _dio.post<Map<String, dynamic>>(
        '/v1/import-wallet/scan',
        data: {'addresses': addresses, 'fallbackAddresses': fallbackAddresses},
        options: Options(
          receiveTimeout: const Duration(seconds: 6),
          sendTimeout: const Duration(seconds: 6),
        ),
      ),
      fallback: 'Unable to scan wallet candidates right now.',
    );

    final items = (payload['items'] as List<dynamic>? ?? const []);
    return items
        .map(
          (item) =>
              RemoteImportWalletScanItem.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<Map<String, dynamic>> getTokenDetail(String mintAddress) async {
    return _requestJsonMap(
      () => _dio.post<Map<String, dynamic>>(
        '/v1/token-detail',
        data: {'mintAddress': mintAddress},
      ),
      fallback: 'Unable to load token details right now.',
    );
  }

  Future<Map<String, dynamic>> getAssetActivity({
    required String ownerAddress,
    required String mintAddress,
    int limit = 10,
  }) async {
    return _requestJsonMap(
      () => _dio.post<Map<String, dynamic>>(
        '/v1/asset-activity',
        data: {
          'ownerAddress': ownerAddress,
          'mintAddress': mintAddress,
          'limit': limit,
        },
      ),
      fallback: 'Unable to load asset activity right now.',
    );
  }

  Future<List<RemoteTokenCatalogItem>> getTokens() async {
    final payload = await _requestJsonMap(
      () => _dio.get<Map<String, dynamic>>('/v1/tokens'),
      fallback: 'Unable to load the token list right now.',
    );
    final items = (payload['items'] as List<dynamic>? ?? const []);
    return items
        .map(
          (item) =>
              RemoteTokenCatalogItem.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<RemoteTokenCatalogItem>> searchTokens(String query) async {
    final payload = await _requestJsonMap(
      () => _dio.get<Map<String, dynamic>>(
        '/v1/tokens/search',
        queryParameters: {'q': query},
      ),
      fallback: 'Unable to search tokens right now.',
    );
    final items = (payload['items'] as List<dynamic>? ?? const []);
    return items
        .map(
          (item) =>
              RemoteTokenCatalogItem.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<RemoteAppConfig> getConfig() async {
    final payload = await _requestJsonMap(
      () => _dio.get<Map<String, dynamic>>('/v1/config'),
      fallback: 'Unable to load app configuration right now.',
    );
    return RemoteAppConfig.fromJson(payload);
  }

  Future<RemoteAppUpdateInfo> checkAppUpdate({
    required int buildNumber,
    required String platform,
  }) async {
    final payload = await _requestJsonMap(
      () => _dio.get<Map<String, dynamic>>(
        '/v1/app-update/check',
        queryParameters: {'build': buildNumber, 'platform': platform},
      ),
      fallback: 'Unable to check for app updates right now.',
    );

    final updatePayload = payload['update'];
    if (updatePayload is! Map<String, dynamic>) {
      throw Exception('App update response is invalid.');
    }

    return RemoteAppUpdateInfo.fromJson(updatePayload);
  }

  Future<void> submitContactRequest({
    required String message,
    String email = '',
    String pagePath = '/app/settings/contact',
    String source = 'app',
  }) async {
    await _requestJsonMap(
      () => _dio.post<Map<String, dynamic>>(
        '/v1/contact',
        data: {
          'email': email,
          'message': message,
          'pagePath': pagePath,
          'source': source,
        },
      ),
      fallback:
          'Unable to send your message right now. Please try again shortly.',
    );
  }

  Future<List<PriceQuote>> getPrices(List<String> symbols) async {
    final payload = await _requestJsonMap(
      () => _dio.post<Map<String, dynamic>>(
        '/v1/prices',
        data: {'symbols': symbols},
      ),
      fallback: 'Unable to load prices right now.',
    );
    final items = (payload['items'] as List<dynamic>? ?? const []);
    return items
        .map((item) => PriceQuote.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> quoteSwap({
    required String inputMint,
    required String outputMint,
    required String amount,
    required int slippageBps,
  }) async {
    return _requestJsonMap(
      () => _dio.post<Map<String, dynamic>>(
        '/v1/swap/quote',
        data: {
          'inputMint': inputMint,
          'outputMint': outputMint,
          'amount': amount,
          'slippageBps': slippageBps,
        },
      ),
      fallback: 'Unable to load swap quote right now.',
    );
  }

  Future<Map<String, dynamic>> buildSwap({
    required String ownerAddress,
    required String inputMint,
    required String outputMint,
    required String amount,
    required int slippageBps,
    required String priorityPreset,
  }) async {
    return _requestJsonMapAuthenticated(
      (options) => _dio.post<Map<String, dynamic>>(
        '/v1/swap/build',
        data: {
          'ownerAddress': ownerAddress,
          'inputMint': inputMint,
          'outputMint': outputMint,
          'amount': amount,
          'slippageBps': slippageBps,
          'priorityPreset': priorityPreset,
        },
        options: options,
      ),
      fallback: 'Unable to prepare swap right now.',
    );
  }

  Future<Map<String, dynamic>> getAirdropProfile() async {
    return _requestJsonMapAuthenticated(
      (options) => _dio.get<Map<String, dynamic>>(
        '/v1/airdrop/profile',
        options: options,
      ),
      fallback: 'Unable to load your BYC airdrop profile right now.',
    );
  }

  Future<RemoteWalletProfileSnapshot> getWalletProfile() async {
    final payload = await _requestJsonMapAuthenticated(
      (options) => _dio.get<Map<String, dynamic>>(
        '/v1/wallet-profile',
        options: options,
      ),
      fallback: 'Unable to load wallet account cloud settings right now.',
    );
    return RemoteWalletProfileSnapshot.fromJson(payload);
  }

  Future<void> updateWalletChildMode({
    required bool childModeEnabled,
    required String childModePinCipherText,
    required String childModePinNonce,
    required String childModePinSalt,
  }) async {
    await _requestJsonMapAuthenticated(
      (options) => _dio.put<Map<String, dynamic>>(
        '/v1/wallet-profile/child-mode',
        data: {
          'childModeEnabled': childModeEnabled,
          'childModePinCipherText': childModePinCipherText,
          'childModePinNonce': childModePinNonce,
          'childModePinSalt': childModePinSalt,
        },
        options: options,
      ),
      fallback: 'Unable to sync child mode settings right now.',
    );
  }

  Future<void> clearWalletChildMode() async {
    await _requestJsonMapAuthenticated(
      (options) => _dio.delete<Map<String, dynamic>>(
        '/v1/wallet-profile/child-mode',
        options: options,
      ),
      fallback: 'Unable to clear child mode settings right now.',
    );
  }

  Future<void> upsertChildAccount({
    required String childName,
    required String childAddress,
  }) async {
    await _requestJsonMapAuthenticated(
      (options) => _dio.post<Map<String, dynamic>>(
        '/v1/child-accounts',
        data: {'childName': childName, 'childAddress': childAddress},
        options: options,
      ),
      fallback: 'Unable to sync child account right now.',
    );
  }

  Future<void> updateChildAccountByAddress({
    required String currentChildAddress,
    required String childName,
    required String childAddress,
  }) async {
    await _requestJsonMapAuthenticated(
      (options) => _dio.patch<Map<String, dynamic>>(
        '/v1/child-accounts/by-address/$currentChildAddress',
        data: {'childName': childName, 'childAddress': childAddress},
        options: options,
      ),
      fallback: 'Unable to sync child account right now.',
    );
  }

  Future<void> removeChildAccountByAddress(String childAddress) async {
    await _requestJsonMapAuthenticated(
      (options) => _dio.delete<Map<String, dynamic>>(
        '/v1/child-accounts/by-address/$childAddress',
        options: options,
      ),
      fallback: 'Unable to remove child account from cloud right now.',
    );
  }

  Future<Map<String, dynamic>> joinAirdrop({
    required String ownerAddress,
  }) async {
    return _requestJsonMapAuthenticated(
      (options) => _dio.post<Map<String, dynamic>>(
        '/v1/airdrop/join',
        data: {'ownerAddress': ownerAddress},
        options: options,
      ),
      fallback: 'Unable to join the BYC airdrop right now.',
    );
  }

  Future<Map<String, dynamic>> checkInAirdrop({
    required String ownerAddress,
  }) async {
    return _requestJsonMapAuthenticated(
      (options) => _dio.post<Map<String, dynamic>>(
        '/v1/airdrop/check-in',
        data: {'ownerAddress': ownerAddress},
        options: options,
      ),
      fallback: 'Unable to complete the BYC reward claim right now.',
    );
  }

  Future<void> registerInstallAnalytics({
    required String appVersion,
    required bool biometricEnabled,
    required String buildNumber,
    required bool childModeEnabled,
    required int childWalletCount,
    required String collectedAt,
    required String installId,
    required String locale,
    required String platform,
    required String source,
    required String timeZone,
    required int walletCount,
  }) async {
    await _requestJsonMap(
      () => _dio.post<Map<String, dynamic>>(
        '/v1/install-analytics',
        data: {
          'appVersion': appVersion,
          'biometricEnabled': biometricEnabled,
          'buildNumber': buildNumber,
          'childModeEnabled': childModeEnabled,
          'childWalletCount': childWalletCount,
          'collectedAt': collectedAt,
          'installId': installId,
          'locale': locale,
          'platform': platform,
          'source': source,
          'timeZone': timeZone,
          'walletCount': walletCount,
        },
      ),
      fallback: 'Unable to record install analytics right now.',
    );
  }

  Future<String> submitSenderTransaction({
    required String encodedTransaction,
    String? txType,
    String? fromMint,
    String? toMint,
    String? amount,
    String? referenceId,
    String? destinationAddress,
  }) async {
    final payload = await _requestJsonMapAuthenticated(
      (options) => _dio.post<Map<String, dynamic>>(
        '/v1/solana-sender/send',
        data: {
          'encodedTransaction': encodedTransaction,
          if (txType != null && txType.trim().isNotEmpty)
            'txType': txType.trim(),
          if (fromMint != null && fromMint.trim().isNotEmpty)
            'fromMint': fromMint.trim(),
          if (toMint != null && toMint.trim().isNotEmpty)
            'toMint': toMint.trim(),
          if (amount != null && amount.trim().isNotEmpty)
            'amount': amount.trim(),
          if (referenceId != null && referenceId.trim().isNotEmpty)
            'referenceId': referenceId.trim(),
          if (destinationAddress != null &&
              destinationAddress.trim().isNotEmpty)
            'destinationAddress': destinationAddress.trim(),
        },
        options: options,
      ),
      fallback: 'Unable to submit the transaction right now.',
    );

    final signature = payload['signature'];
    if (signature is! String || signature.isEmpty) {
      throw Exception(
        'The sender service did not return a transaction signature.',
      );
    }

    return signature;
  }

  Future<void> registerNotificationDevice({
    required String appVersion,
    required String buildNumber,
    required String fcmToken,
    required String installId,
    required bool notificationsEnabled,
    required String platform,
  }) async {
    await _requestJsonMapAuthenticated(
      (options) => _dio.post<Map<String, dynamic>>(
        '/v1/notifications/register-device',
        data: {
          'appVersion': appVersion,
          'buildNumber': buildNumber,
          'fcmToken': fcmToken,
          'installId': installId,
          'notificationsEnabled': notificationsEnabled,
          'platform': platform,
        },
        options: options,
      ),
      fallback: 'Unable to register this device for wallet notifications.',
    );
  }

  Future<List<RemoteReceivedTransferItem>> getReceivedTransfers({
    int limit = 50,
  }) async {
    final payload = await _requestJsonMapAuthenticated(
      (options) => _dio.get<Map<String, dynamic>>(
        '/v1/notifications/received',
        queryParameters: {'limit': limit},
        options: options,
      ),
      fallback: 'Unable to load received transfers right now.',
    );
    final items = payload['items'] as List<dynamic>? ?? const [];
    return items
        .map(
          (item) =>
              RemoteReceivedTransferItem.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<RemoteReceivedTransferItem> getReceivedTransfer(String id) async {
    final payload = await _requestJsonMapAuthenticated(
      (options) => _dio.get<Map<String, dynamic>>(
        '/v1/notifications/received/$id',
        options: options,
      ),
      fallback: 'Unable to load this received transfer right now.',
    );
    final item = payload['item'];
    if (item is! Map<String, dynamic>) {
      throw Exception('Received transfer detail was not returned.');
    }
    return RemoteReceivedTransferItem.fromJson(item);
  }

  Future<List<RemoteSendHistoryItem>> getSenderHistory({int limit = 50}) async {
    final payload = await _requestJsonMapAuthenticated(
      (options) => _dio.get<Map<String, dynamic>>(
        '/v1/solana-sender/history',
        queryParameters: {'limit': limit},
        options: options,
      ),
      fallback: 'Unable to load send history right now.',
    );
    final items = (payload['items'] as List<dynamic>? ?? const []);
    return items
        .map(
          (item) =>
              RemoteSendHistoryItem.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<Map<String, dynamic>> _requestJsonMapAuthenticated(
    Future<Response<Map<String, dynamic>>> Function(Options options) request, {
    required String fallback,
  }) async {
    try {
      final sessionManager = _sessionManager;
      if (sessionManager == null) {
        throw StateError(
          'Backend session manager is not configured for protected requests.',
        );
      }
      final headers = await sessionManager.currentHeaders();
      final response = await request(Options(headers: headers));
      return response.data ?? const {};
    } on DioException catch (error) {
      throw Exception(_messageFromDio(error, fallback: fallback));
    } on StateError catch (error) {
      throw Exception(error.message);
    } catch (error) {
      throw Exception(_messageFromUnknown(error, fallback: fallback));
    }
  }

  Future<Map<String, dynamic>> _requestJsonMap(
    Future<Response<Map<String, dynamic>>> Function() request, {
    required String fallback,
  }) async {
    try {
      final response = await request();
      return response.data ?? const {};
    } on DioException catch (error) {
      throw Exception(_messageFromDio(error, fallback: fallback));
    } on StateError catch (error) {
      throw Exception(error.message);
    } catch (error) {
      throw Exception(_messageFromUnknown(error, fallback: fallback));
    }
  }

  String _messageFromDio(DioException error, {required String fallback}) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
      final errorCode = data['error'];
      if (errorCode is String && errorCode.isNotEmpty) {
        return errorCode;
      }
    }

    if (data is String && data.isNotEmpty) {
      return data;
    }

    final statusCode = error.response?.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      return 'Backend authorization failed. Re-authenticate the wallet session and try again.';
    }

    final message = error.message;
    if (message != null && message.isNotEmpty) {
      return message;
    }
    return fallback;
  }

  String _messageFromUnknown(Object error, {required String fallback}) {
    final message = error.toString();
    if (message.isNotEmpty) {
      return message;
    }
    return fallback;
  }
}
