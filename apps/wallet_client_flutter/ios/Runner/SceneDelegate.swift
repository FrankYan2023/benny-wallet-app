import Flutter
import CryptoKit
import Security
import UIKit
import UserNotifications

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }

    registerAppBadgeChannel(binaryMessenger: controller.binaryMessenger)
    registerBiometricSessionChannel(binaryMessenger: controller.binaryMessenger)
  }

  private func registerAppBadgeChannel(binaryMessenger: FlutterBinaryMessenger) {
    let badgeChannel = FlutterMethodChannel(
      name: "benny_wallet/app_badge",
      binaryMessenger: binaryMessenger
    )
    badgeChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "clearBadge":
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        result(nil)
      case "openNotificationSettings":
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
          result(nil)
          return
        }
        UIApplication.shared.open(url, options: [:]) { _ in
          result(nil)
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func registerBiometricSessionChannel(binaryMessenger: FlutterBinaryMessenger) {
    let biometricSessionChannel = FlutterMethodChannel(
      name: "benny_wallet/biometric_session",
      binaryMessenger: binaryMessenger
    )
    biometricSessionChannel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(
          FlutterError(
            code: "ios_security_error",
            message: "Biometric session handler is unavailable.",
            details: nil
          )
        )
        return
      }

      do {
        switch call.method {
        case "encrypt":
          guard
            let arguments = call.arguments as? [String: Any],
            let clearText = arguments["clearText"] as? String
          else {
            throw BiometricSessionError.invalidArguments("Missing clearText")
          }
          result(try self.encryptBiometricSession(clearText))

        case "decrypt":
          guard
            let arguments = call.arguments as? [String: Any],
            let cipherText = arguments["cipherText"] as? String,
            let nonce = arguments["nonce"] as? String
          else {
            throw BiometricSessionError.invalidArguments("Missing cipherText or nonce")
          }
          result(try self.decryptBiometricSession(cipherText: cipherText, nonce: nonce))

        case "clear":
          try self.clearBiometricSessionKey()
          result(nil)

        default:
          result(FlutterMethodNotImplemented)
        }
      } catch {
        result(
          FlutterError(
            code: "ios_security_error",
            message: error.localizedDescription,
            details: nil
          )
        )
      }
    }
  }

  private func encryptBiometricSession(_ clearText: String) throws -> [String: String] {
    let key = try getOrCreateBiometricSessionKey()
    let sealedBox = try AES.GCM.seal(Data(clearText.utf8), using: key)

    var cipherAndTag = Data(sealedBox.ciphertext)
    cipherAndTag.append(sealedBox.tag)

    return [
      "cipherText": cipherAndTag.base64EncodedString(),
      "nonce": Data(sealedBox.nonce).base64EncodedString()
    ]
  }

  private func decryptBiometricSession(cipherText: String, nonce: String) throws -> String {
    let key = try getOrCreateBiometricSessionKey()

    guard let cipherAndTag = Data(base64Encoded: cipherText) else {
      throw BiometricSessionError.invalidArguments("Invalid cipherText")
    }
    guard let nonceData = Data(base64Encoded: nonce) else {
      throw BiometricSessionError.invalidArguments("Invalid nonce")
    }
    guard cipherAndTag.count > Self.gcmTagLengthBytes else {
      throw BiometricSessionError.invalidArguments("Invalid encrypted payload")
    }

    let cipherData = cipherAndTag.prefix(cipherAndTag.count - Self.gcmTagLengthBytes)
    let tagData = cipherAndTag.suffix(Self.gcmTagLengthBytes)
    let sealedBox = try AES.GCM.SealedBox(
      nonce: AES.GCM.Nonce(data: nonceData),
      ciphertext: cipherData,
      tag: tagData
    )
    let decryptedData = try AES.GCM.open(sealedBox, using: key)

    guard let clearText = String(data: decryptedData, encoding: .utf8), !clearText.isEmpty else {
      throw BiometricSessionError.cryptoFailed("Keychain decryption returned empty plaintext")
    }

    return clearText
  }

  private func getOrCreateBiometricSessionKey() throws -> SymmetricKey {
    if let existingKeyData = try readBiometricSessionKeyData() {
      return SymmetricKey(data: existingKeyData)
    }

    var keyData = Data(count: Self.symmetricKeyLengthBytes)
    let status = keyData.withUnsafeMutableBytes { buffer in
      SecRandomCopyBytes(kSecRandomDefault, Self.symmetricKeyLengthBytes, buffer.baseAddress!)
    }
    guard status == errSecSuccess else {
      throw BiometricSessionError.keychainFailed("Unable to generate a biometric session key")
    }

    try storeBiometricSessionKeyData(keyData)
    return SymmetricKey(data: keyData)
  }

  private func readBiometricSessionKeyData() throws -> Data? {
    var query = biometricSessionKeyQuery()
    query[kSecReturnData as String] = true
    query[kSecMatchLimit as String] = kSecMatchLimitOne

    var result: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    if status == errSecItemNotFound {
      return nil
    }
    guard status == errSecSuccess else {
      throw BiometricSessionError.keychainFailed("Unable to read the biometric session key")
    }

    return result as? Data
  }

  private func storeBiometricSessionKeyData(_ keyData: Data) throws {
    try clearBiometricSessionKey()

    var query = biometricSessionKeyQuery()
    query[kSecValueData as String] = keyData
    query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly

    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else {
      throw BiometricSessionError.keychainFailed("Unable to store the biometric session key")
    }
  }

  private func clearBiometricSessionKey() throws {
    let status = SecItemDelete(biometricSessionKeyQuery() as CFDictionary)
    guard status == errSecSuccess || status == errSecItemNotFound else {
      throw BiometricSessionError.keychainFailed("Unable to clear the biometric session key")
    }
  }

  private func biometricSessionKeyQuery() -> [String: Any] {
    [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: Self.biometricSessionService,
      kSecAttrAccount as String: Self.biometricSessionAccount
    ]
  }

  private enum BiometricSessionError: LocalizedError {
    case invalidArguments(String)
    case keychainFailed(String)
    case cryptoFailed(String)

    var errorDescription: String? {
      switch self {
      case .invalidArguments(let message), .keychainFailed(let message), .cryptoFailed(let message):
        return message
      }
    }
  }

  private static let biometricSessionService = "benny_wallet_biometric_session"
  private static let biometricSessionAccount = "mnemonic_key"
  private static let symmetricKeyLengthBytes = 32
  private static let gcmTagLengthBytes = 16
}
