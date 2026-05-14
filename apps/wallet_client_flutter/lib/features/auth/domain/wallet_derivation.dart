class WalletDerivation {
  const WalletDerivation({this.accountIndex, this.changeIndex});

  final int? accountIndex;
  final int? changeIndex;

  static const legacy = WalletDerivation();
  static const standard = WalletDerivation(accountIndex: 0, changeIndex: 0);

  String get hdPath {
    final path = StringBuffer("m/44'/501'");

    if (accountIndex != null) {
      path.write("/$accountIndex'");
    } else if (changeIndex != null) {
      path.write("/0'");
    }

    if (changeIndex != null) {
      path.write("/$changeIndex'");
    }

    return path.toString();
  }

  String get importLabel {
    if (accountIndex == null && changeIndex == null) {
      return 'Legacy';
    }

    final walletNumber = (accountIndex ?? 0) + 1;
    if (changeIndex == null) {
      return 'Account $walletNumber';
    }

    return 'Wallet $walletNumber';
  }

  Map<String, dynamic> toJson() {
    return {'accountIndex': accountIndex, 'changeIndex': changeIndex};
  }

  WalletDerivation copyWith({
    int? accountIndex,
    int? changeIndex,
    bool clearAccountIndex = false,
    bool clearChangeIndex = false,
  }) {
    return WalletDerivation(
      accountIndex: clearAccountIndex
          ? null
          : accountIndex ?? this.accountIndex,
      changeIndex: clearChangeIndex ? null : changeIndex ?? this.changeIndex,
    );
  }

  factory WalletDerivation.fromJson(Map<String, dynamic> json) {
    return WalletDerivation(
      accountIndex: (json['accountIndex'] as num?)?.toInt(),
      changeIndex: (json['changeIndex'] as num?)?.toInt(),
    );
  }
}
