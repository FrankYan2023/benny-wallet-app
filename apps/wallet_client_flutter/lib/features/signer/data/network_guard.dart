import 'network_guard_stub.dart'
    if (dart.library.io) 'network_guard_io.dart'
    as impl;

/// Refuses every Dart-level network connection for the rest of the process.
/// Installed before the signer UI starts; the setup flow additionally makes
/// the user switch the radios off, which also covers native code.
void blockNetworkForSigner() => impl.blockNetwork();

/// Undoes [blockNetworkForSigner] when the user leaves signer mode before
/// any seed was stored.
void allowNetworkAfterSigner() => impl.allowNetwork();
