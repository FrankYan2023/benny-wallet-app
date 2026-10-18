import 'dart:io';

void blockNetwork() {
  HttpOverrides.global = _SignerHttpOverrides();
}

class _SignerHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..findProxy = ((_) => 'DIRECT')
      ..connectionFactory = (uri, proxyHost, proxyPort) => Future.error(
        const SocketException('Network access is disabled on the signer.'),
      );
  }
}

void allowNetwork() {
  if (HttpOverrides.current is _SignerHttpOverrides) {
    HttpOverrides.global = null;
  }
}
