import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Utility class for secure clipboard operations with automatic data clearing.
/// 
/// This addresses security issue #2 (Clipboard not cleared):
/// Prevents sensitive data (mnemonic phrases, addresses) from remaining
/// in the system clipboard indefinitely, reducing attack surface for
/// malicious apps that monitor clipboard changes.
class ClipboardUtils {
  /// Default duration before clipboard is automatically cleared (30 seconds).
  /// Override for more sensitive data.
  static const Duration defaultClearDelay = Duration(seconds: 30);

  /// Duration for highly sensitive data like mnemonic phrases (15 seconds).
  static const Duration sensitiveClearDelay = Duration(seconds: 15);

  /// Duration for less sensitive data like addresses (60 seconds).
  static const Duration addressClearDelay = Duration(seconds: 60);

  /// Copies text to clipboard and automatically clears it after [clearDelay].
  ///
  /// Parameters:
  /// - [text]: The text to copy to clipboard
  /// - [clearDelay]: How long to wait before clearing (default: 30s)
  /// - [isSensitive]: If true, logs a security warning (for mnemonic phrases)
  ///
  /// Example:
  /// ```dart
  /// // For mnemonic phrase (most sensitive)
  /// await ClipboardUtils.setDataWithAutoWipe(
  ///   mnemonic,
  ///   clearDelay: ClipboardUtils.sensitiveClearDelay,
  ///   isSensitive: true,
  /// );
  ///
  /// // For wallet address (less sensitive)
  /// await ClipboardUtils.setDataWithAutoWipe(
  ///   address,
  ///   clearDelay: ClipboardUtils.addressClearDelay,
  /// );
  /// ```
  static Future<void> setDataWithAutoWipe(
    String text, {
    Duration clearDelay = defaultClearDelay,
    bool isSensitive = false,
  }) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));

      if (isSensitive) {
        debugPrint(
          '[SECURITY] Sensitive data copied to clipboard. '
          'Will be cleared in ${clearDelay.inSeconds}s.',
        );
      }

      // Schedule clipboard wipe
      Future.delayed(clearDelay, () async {
        try {
          // Verify that the clipboard still contains our data before clearing
          // to avoid accidentally clearing user's new clipboard content
          final current = await Clipboard.getData('text/plain');
          if (current?.text == text) {
            await Clipboard.setData(const ClipboardData(text: ''));
            if (isSensitive) {
              debugPrint('[SECURITY] Clipboard cleared after $clearDelay.');
            }
          }
        } catch (e) {
          // Silently fail - some devices may not support clipboard operations
          debugPrint('[SECURITY] Clipboard wipe failed: $e');
        }
      });
    } catch (e) {
      debugPrint('[ERROR] Failed to copy to clipboard: $e');
      rethrow;
    }
  }
}
