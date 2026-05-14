package com.benny.wallet

import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

class MainActivity : FlutterFragmentActivity() {
	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(
			flutterEngine.dartExecutor.binaryMessenger,
			SCREEN_SECURITY_CHANNEL,
		).setMethodCallHandler { call, result ->
			when (call.method) {
				"setSecureScreen" -> {
					val enabled = call.argument<Boolean>("enabled") ?: false
					if (enabled) {
						window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
					} else {
						window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
					}
					result.success(null)
				}

				else -> result.notImplemented()
			}
		}

		MethodChannel(
			flutterEngine.dartExecutor.binaryMessenger,
			APP_BADGE_CHANNEL,
		).setMethodCallHandler { call, result ->
			when (call.method) {
				"clearBadge" -> {
					val notificationManager = getSystemService(
						Context.NOTIFICATION_SERVICE,
					) as NotificationManager
					notificationManager.cancelAll()
					result.success(null)
				}
				else -> result.notImplemented()
			}
		}

		MethodChannel(
			flutterEngine.dartExecutor.binaryMessenger,
			BIOMETRIC_SESSION_CHANNEL,
		).setMethodCallHandler { call, result ->
			try {
				when (call.method) {
					"encrypt" -> {
						val clearText = call.argument<String>("clearText")
							?: throw IllegalArgumentException("Missing clearText")
						result.success(encryptBiometricSession(clearText))
					}

					"decrypt" -> {
						val cipherText = call.argument<String>("cipherText")
							?: throw IllegalArgumentException("Missing cipherText")
						val nonce = call.argument<String>("nonce")
							?: throw IllegalArgumentException("Missing nonce")
						result.success(decryptBiometricSession(cipherText, nonce))
					}

					"clear" -> {
						clearBiometricSessionKey()
						result.success(null)
					}

					else -> result.notImplemented()
				}
			} catch (error: Exception) {
				result.error(
					"android_security_error",
					error.message ?: "Android security operation failed.",
					null,
				)
			}
		}
	}

	private fun encryptBiometricSession(clearText: String): Map<String, String> {
		val cipher = Cipher.getInstance(TRANSFORMATION)
		cipher.init(Cipher.ENCRYPT_MODE, getOrCreateBiometricSessionKey())
		val encrypted = cipher.doFinal(clearText.toByteArray(Charsets.UTF_8))

		return mapOf(
			"cipherText" to Base64.encodeToString(encrypted, Base64.NO_WRAP),
			"nonce" to Base64.encodeToString(cipher.iv, Base64.NO_WRAP),
		)
	}

	private fun decryptBiometricSession(cipherText: String, nonce: String): String {
		val cipher = Cipher.getInstance(TRANSFORMATION)
		val iv = Base64.decode(nonce, Base64.NO_WRAP)
		val spec = GCMParameterSpec(GCM_TAG_LENGTH_BITS, iv)
		cipher.init(Cipher.DECRYPT_MODE, getOrCreateBiometricSessionKey(), spec)

		val decrypted = cipher.doFinal(Base64.decode(cipherText, Base64.NO_WRAP))
		return String(decrypted, Charsets.UTF_8)
	}

	private fun clearBiometricSessionKey() {
		val keyStore = KeyStore.getInstance(ANDROID_KEYSTORE).apply { load(null) }
		if (keyStore.containsAlias(BIOMETRIC_SESSION_KEY_ALIAS)) {
			keyStore.deleteEntry(BIOMETRIC_SESSION_KEY_ALIAS)
		}
	}

	private fun getOrCreateBiometricSessionKey(): SecretKey {
		val keyStore = KeyStore.getInstance(ANDROID_KEYSTORE).apply { load(null) }
		val existingKey = keyStore.getKey(BIOMETRIC_SESSION_KEY_ALIAS, null) as? SecretKey
		if (existingKey != null) {
			return existingKey
		}

		val keyGenerator = KeyGenerator.getInstance(
			KeyProperties.KEY_ALGORITHM_AES,
			ANDROID_KEYSTORE,
		)
		val builder = KeyGenParameterSpec.Builder(
			BIOMETRIC_SESSION_KEY_ALIAS,
			KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT,
		).setKeySize(256)
			.setBlockModes(KeyProperties.BLOCK_MODE_GCM)
			.setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
			.setRandomizedEncryptionRequired(true)

		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
			builder.setInvalidatedByBiometricEnrollment(true)
		}

		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
			builder.setUserAuthenticationParameters(
				BIOMETRIC_AUTH_WINDOW_SECONDS,
				KeyProperties.AUTH_BIOMETRIC_STRONG,
			)
		} else {
			@Suppress("DEPRECATION")
			builder.setUserAuthenticationValidityDurationSeconds(
				BIOMETRIC_AUTH_WINDOW_SECONDS,
			)
		}

		keyGenerator.init(builder.build())
		return keyGenerator.generateKey()
	}

	companion object {
		private const val SCREEN_SECURITY_CHANNEL = "benny_wallet/screen_security"
		private const val APP_BADGE_CHANNEL = "benny_wallet/app_badge"
		private const val BIOMETRIC_SESSION_CHANNEL = "benny_wallet/biometric_session"
		private const val ANDROID_KEYSTORE = "AndroidKeyStore"
		private const val BIOMETRIC_SESSION_KEY_ALIAS = "benny_wallet_biometric_session"
		private const val TRANSFORMATION = "AES/GCM/NoPadding"
		private const val GCM_TAG_LENGTH_BITS = 128
		private const val BIOMETRIC_AUTH_WINDOW_SECONDS = 30
	}
}
