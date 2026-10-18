import 'wallet_derivation.dart';

enum WalletStatus { loading, noWallet, locked, unlocked, error }

enum WalletCustody {
  localMnemonic,
  mobileWalletAdapter,
  seedVault,

  /// Keys live on an offline signer phone; signing goes through QR codes.
  airGap,
}

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

/// What the wallet switcher shows for each stored wallet.
class WalletSummary {
  const WalletSummary({
    required this.publicKey,
    required this.name,
    required this.custody,
  });

  final String publicKey;
  final String name;
  final WalletCustody custody;

  bool get isExternal => custody != WalletCustody.localMnemonic;

  @override
  bool operator ==(Object other) =>
      other is WalletSummary &&
      other.publicKey == publicKey &&
      other.name == name &&
      other.custody == custody;

  @override
  int get hashCode => Object.hash(publicKey, name, custody);
}

class WalletControllerState {
  const WalletControllerState({
    required this.status,
    this.walletPublicKeys = const [],
    this.wallets = const [],
    this.publicKey,
    this.derivation = WalletDerivation.legacy,
    this.custody = WalletCustody.localMnemonic,
    this.mnemonic,
    this.mnemonicTokenId,
    this.mwaAuthToken,
    this.seedVaultDerivationPath,
    this.walletLabel,
    this.biometricEnabled = false,
    this.loggedOut = false,
    this.errorMessage,
    this.childModeEnabled = false,
    this.hasChildModePin = false,
    this.childWallets = const [],
    this.travelGuardArmed = false,
    this.travelGuardSession = false,
  });

  final WalletStatus status;
  final List<String> walletPublicKeys;
  final List<WalletSummary> wallets;
  final String? publicKey;
  final WalletDerivation derivation;
  final WalletCustody custody;

  /// ⚠️ DEPRECATED: Use mnemonicTokenId instead
  /// Kept for backward compatibility only - will be phased out
  final String? mnemonic;

  /// 🔐 Security: Opaque token for ephemeral mnemonic access
  /// The actual mnemonic is stored in MnemonicEphemeralStore, NOT in this state
  final String? mnemonicTokenId;

  /// Mobile Wallet Adapter authorization token for Seeker Seed Vault Wallet.
  /// This is not a private key; it only lets the app request wallet approval.
  final String? mwaAuthToken;

  final String? seedVaultDerivationPath;

  final String? walletLabel;

  final bool biometricEnabled;
  final bool loggedOut;
  final String? errorMessage;

  /// 👶 Child mode: true = restricted (Receive only), false = parent mode (full access)
  final bool childModeEnabled;
  final bool hasChildModePin;

  /// 🏠 Parent mode: List of child wallets to monitor
  final List<ChildWallet> childWallets;

  /// A travel guard PIN is set (it opens one chosen wallet alone).
  final bool travelGuardArmed;

  /// Unlocked with the travel guard PIN: only that wallet exists for this
  /// session and nothing hints at the others or at the guard itself.
  final bool travelGuardSession;

  bool get hasWallet => walletPublicKeys.isNotEmpty;

  WalletSummary? get activeWallet {
    for (final wallet in wallets) {
      if (wallet.publicKey == publicKey) {
        return wallet;
      }
    }
    return null;
  }

  bool get isExternalWallet =>
      custody == WalletCustody.mobileWalletAdapter ||
      custody == WalletCustody.seedVault ||
      custody == WalletCustody.airGap;
  bool get isUnlocked =>
      status == WalletStatus.unlocked &&
      (isExternalWallet || mnemonicTokenId != null || mnemonic != null);

  WalletControllerState copyWith({
    WalletStatus? status,
    List<String>? walletPublicKeys,
    List<WalletSummary>? wallets,
    String? publicKey,
    WalletDerivation? derivation,
    WalletCustody? custody,
    String? mnemonic,
    String? mnemonicTokenId,
    String? mwaAuthToken,
    String? seedVaultDerivationPath,
    String? walletLabel,
    bool? biometricEnabled,
    bool? loggedOut,
    String? errorMessage,
    bool? childModeEnabled,
    bool? hasChildModePin,
    List<ChildWallet>? childWallets,
    bool? travelGuardArmed,
    bool? travelGuardSession,
    bool clearMnemonic = false,
    bool clearMnemonicToken = false,
    bool clearError = false,
  }) {
    return WalletControllerState(
      status: status ?? this.status,
      walletPublicKeys: walletPublicKeys ?? this.walletPublicKeys,
      wallets: wallets ?? this.wallets,
      publicKey: publicKey ?? this.publicKey,
      derivation: derivation ?? this.derivation,
      custody: custody ?? this.custody,
      mnemonic: clearMnemonic ? null : mnemonic ?? this.mnemonic,
      mnemonicTokenId: clearMnemonicToken
          ? null
          : mnemonicTokenId ?? this.mnemonicTokenId,
      mwaAuthToken: mwaAuthToken ?? this.mwaAuthToken,
      seedVaultDerivationPath:
          seedVaultDerivationPath ?? this.seedVaultDerivationPath,
      walletLabel: walletLabel ?? this.walletLabel,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      loggedOut: loggedOut ?? this.loggedOut,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      childModeEnabled: childModeEnabled ?? this.childModeEnabled,
      hasChildModePin: hasChildModePin ?? this.hasChildModePin,
      childWallets: childWallets ?? this.childWallets,
      travelGuardArmed: travelGuardArmed ?? this.travelGuardArmed,
      travelGuardSession: travelGuardSession ?? this.travelGuardSession,
    );
  }

  static const loading = WalletControllerState(status: WalletStatus.loading);
  static const noWallet = WalletControllerState(
    status: WalletStatus.noWallet,
    walletPublicKeys: [],
  );
}
