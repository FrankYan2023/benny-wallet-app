import 'wallet_derivation.dart';

enum WalletStatus { loading, noWallet, locked, unlocked, error }

/// 👶 Child wallet information for parent monitoring
class ChildWallet {
  const ChildWallet({
    required this.id,
    required this.name,
    required this.address,
  });

  final String id; // Unique identifier (UUID or timestamp-based)
  final String name; // Child's name
  final String address; // Child's wallet address on Solana

  ChildWallet copyWith({String? id, String? name, String? address}) {
    return ChildWallet(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'address': address};
  }

  factory ChildWallet.fromJson(Map<String, dynamic> json) {
    return ChildWallet(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
    );
  }
}

class WalletControllerState {
  const WalletControllerState({
    required this.status,
    this.walletPublicKeys = const [],
    this.publicKey,
    this.derivation = WalletDerivation.legacy,
    this.mnemonic,
    this.mnemonicTokenId,
    this.biometricEnabled = false,
    this.loggedOut = false,
    this.errorMessage,
    this.childModeEnabled = false,
    this.hasChildModePin = false,
    this.childWallets = const [],
  });

  final WalletStatus status;
  final List<String> walletPublicKeys;
  final String? publicKey;
  final WalletDerivation derivation;

  /// ⚠️ DEPRECATED: Use mnemonicTokenId instead
  /// Kept for backward compatibility only - will be phased out
  final String? mnemonic;

  /// 🔐 Security: Opaque token for ephemeral mnemonic access
  /// The actual mnemonic is stored in MnemonicEphemeralStore, NOT in this state
  final String? mnemonicTokenId;

  final bool biometricEnabled;
  final bool loggedOut;
  final String? errorMessage;

  /// 👶 Child mode: true = restricted (Receive only), false = parent mode (full access)
  final bool childModeEnabled;
  final bool hasChildModePin;

  /// 🏠 Parent mode: List of child wallets to monitor
  final List<ChildWallet> childWallets;

  bool get hasWallet => walletPublicKeys.isNotEmpty;
  bool get isUnlocked =>
      status == WalletStatus.unlocked &&
      (mnemonicTokenId != null || mnemonic != null);

  WalletControllerState copyWith({
    WalletStatus? status,
    List<String>? walletPublicKeys,
    String? publicKey,
    WalletDerivation? derivation,
    String? mnemonic,
    String? mnemonicTokenId,
    bool? biometricEnabled,
    bool? loggedOut,
    String? errorMessage,
    bool? childModeEnabled,
    bool? hasChildModePin,
    List<ChildWallet>? childWallets,
    bool clearMnemonic = false,
    bool clearMnemonicToken = false,
    bool clearError = false,
  }) {
    return WalletControllerState(
      status: status ?? this.status,
      walletPublicKeys: walletPublicKeys ?? this.walletPublicKeys,
      publicKey: publicKey ?? this.publicKey,
      derivation: derivation ?? this.derivation,
      mnemonic: clearMnemonic ? null : mnemonic ?? this.mnemonic,
      mnemonicTokenId: clearMnemonicToken
          ? null
          : mnemonicTokenId ?? this.mnemonicTokenId,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      loggedOut: loggedOut ?? this.loggedOut,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      childModeEnabled: childModeEnabled ?? this.childModeEnabled,
      hasChildModePin: hasChildModePin ?? this.hasChildModePin,
      childWallets: childWallets ?? this.childWallets,
    );
  }

  static const loading = WalletControllerState(status: WalletStatus.loading);
  static const noWallet = WalletControllerState(
    status: WalletStatus.noWallet,
    walletPublicKeys: [],
  );
}
