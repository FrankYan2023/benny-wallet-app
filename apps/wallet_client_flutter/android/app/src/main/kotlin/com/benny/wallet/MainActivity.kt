package com.benny.wallet

import android.app.NotificationManager
import android.content.Context
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import android.view.WindowManager
import com.solana.mobilewalletadapter.clientlib.ActivityResultSender
import com.solana.mobilewalletadapter.clientlib.ConnectionIdentity
import com.solana.mobilewalletadapter.clientlib.MobileWalletAdapter
import com.solana.mobilewalletadapter.clientlib.Solana
import com.solana.mobilewalletadapter.clientlib.TransactionResult
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

class MainActivity : FlutterFragmentActivity() {
	private val mainScope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
	private lateinit var mobileWalletActivityResultSender: ActivityResultSender

	override fun onCreate(savedInstanceState: Bundle?) {
		super.onCreate(savedInstanceState)
		mobileWalletActivityResultSender = ActivityResultSender(this)
	}

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

		MethodChannel(
			flutterEngine.dartExecutor.binaryMessenger,
			MOBILE_WALLET_ADAPTER_CHANNEL,
		).setMethodCallHandler { call, result ->
			when (call.method) {
				"getDeviceInfo" -> {
					result.success(getDeviceInfo())
				}

				"connect" -> {
					val authToken = call.argument<String>("authToken")
					connectMobileWallet(authToken, result)
				}

				"signAndSendTransactions" -> {
					val authToken = call.argument<String>("authToken")
					val transactions = call.argument<List<String>>("transactions")
					if (transactions == null || transactions.isEmpty()) {
						result.error(
							"mwa_invalid_request",
							"Missing transactions.",
							null,
						)
						return@setMethodCallHandler
					}
					signAndSendMobileWalletTransactions(authToken, transactions, result)
				}

				"signMessages" -> {
					val authToken = call.argument<String>("authToken")
					val messages = call.argument<List<String>>("messages")
					val addresses = call.argument<List<String>>("addresses")
					if (messages == null || messages.isEmpty()) {
						result.error(
							"mwa_invalid_request",
							"Missing messages.",
							null,
						)
						return@setMethodCallHandler
					}
					if (addresses == null || addresses.isEmpty()) {
						result.error(
							"mwa_invalid_request",
							"Missing signer addresses.",
							null,
						)
						return@setMethodCallHandler
					}
					signMobileWalletMessages(authToken, messages, addresses, result)
				}

				else -> result.notImplemented()
			}
		}
	}

	override fun onDestroy() {
		mainScope.cancel()
		super.onDestroy()
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

	private fun getDeviceInfo(): Map<String, String> {
		return mapOf(
			"brand" to Build.BRAND,
			"manufacturer" to Build.MANUFACTURER,
			"model" to Build.MODEL,
			"fingerprint" to Build.FINGERPRINT,
		)
	}

	private fun connectMobileWallet(authToken: String?, result: MethodChannel.Result) {
		mainScope.launch {
			try {
				val adapter = createMobileWalletAdapter(authToken)
				when (val connectResult = adapter.connect(mobileWalletActivityResultSender)) {
					is TransactionResult.Success -> {
						val authResult = connectResult.authResult
						val account = authResult.accounts.first()
						result.success(
							mapOf(
								"authToken" to authResult.authToken,
								"publicKeyBase64" to Base64.encodeToString(account.publicKey, Base64.NO_WRAP),
								"accountLabel" to account.accountLabel,
								"walletUriBase" to authResult.walletUriBase?.toString(),
								"walletIcon" to authResult.walletIcon?.toString(),
							),
						)
					}

					is TransactionResult.NoWalletFound -> result.error(
						"mwa_no_wallet",
						connectResult.message,
						null,
					)

					is TransactionResult.Failure -> result.error(
						"mwa_failure",
						connectResult.message,
						connectResult.e.message,
					)
				}
			} catch (error: Exception) {
				result.error(
					"mwa_failure",
					error.message ?: "Mobile Wallet Adapter connection failed.",
					error.javaClass.name,
				)
			}
		}
	}

	private fun signAndSendMobileWalletTransactions(
		authToken: String?,
		transactionsBase64: List<String>,
		result: MethodChannel.Result,
	) {
		mainScope.launch {
			try {
				val adapter = createMobileWalletAdapter(authToken)
				val transactions = try {
					transactionsBase64
						.map { Base64.decode(it, Base64.DEFAULT) }
						.toTypedArray()
				} catch (error: IllegalArgumentException) {
					result.error(
						"mwa_invalid_transaction",
						"Transaction payload is not valid base64.",
						error.message,
					)
					return@launch
				}

				when (
					val transactionResult = adapter.transact(mobileWalletActivityResultSender) {
						signAndSendTransactions(transactions)
					}
				) {
					is TransactionResult.Success -> {
						result.success(
							mapOf(
								"authToken" to transactionResult.authResult.authToken,
								"signaturesBase64" to transactionResult.payload.signatures.map {
									Base64.encodeToString(it, Base64.NO_WRAP)
								},
							),
						)
					}

					is TransactionResult.NoWalletFound -> result.error(
						"mwa_no_wallet",
						transactionResult.message,
						null,
					)

					is TransactionResult.Failure -> result.error(
						"mwa_failure",
						transactionResult.message,
						transactionResult.e.message,
					)
				}
			} catch (error: Exception) {
				result.error(
					"mwa_failure",
					error.message ?: "Mobile Wallet Adapter signing failed.",
					error.javaClass.name,
				)
			}
		}
	}

	private fun signMobileWalletMessages(
		authToken: String?,
		messagesBase64: List<String>,
		addressesBase64: List<String>,
		result: MethodChannel.Result,
	) {
		mainScope.launch {
			try {
				val adapter = createMobileWalletAdapter(authToken)
				val messages = try {
					messagesBase64
						.map { Base64.decode(it, Base64.DEFAULT) }
						.toTypedArray()
				} catch (error: IllegalArgumentException) {
					result.error(
						"mwa_invalid_message",
						"Message payload is not valid base64.",
						error.message,
					)
					return@launch
				}
				val addresses = try {
					addressesBase64
						.map { Base64.decode(it, Base64.DEFAULT) }
						.toTypedArray()
				} catch (error: IllegalArgumentException) {
					result.error(
						"mwa_invalid_address",
						"Signer address is not valid base64.",
						error.message,
					)
					return@launch
				}

				when (
					val transactionResult = adapter.transact(mobileWalletActivityResultSender) {
						signMessagesDetached(messages, addresses)
					}
				) {
					is TransactionResult.Success -> {
						result.success(
							mapOf(
								"authToken" to transactionResult.authResult.authToken,
								"signaturesBase64" to transactionResult.payload.messages.map { signedMessage ->
									Base64.encodeToString(
										signedMessage.signatures.first(),
										Base64.NO_WRAP,
									)
								},
							),
						)
					}

					is TransactionResult.NoWalletFound -> result.error(
						"mwa_no_wallet",
						transactionResult.message,
						null,
					)

					is TransactionResult.Failure -> result.error(
						"mwa_failure",
						transactionResult.message,
						transactionResult.e.message,
					)
				}
			} catch (error: Exception) {
				result.error(
					"mwa_failure",
					error.message ?: "Mobile Wallet Adapter message signing failed.",
					error.javaClass.name,
				)
			}
		}
	}

	private fun createMobileWalletAdapter(authToken: String?): MobileWalletAdapter {
		return MobileWalletAdapter(
			connectionIdentity = ConnectionIdentity(
				identityUri = Uri.parse("https://gobennyapp.com"),
				iconUri = Uri.parse("benny_logo.png"),
				identityName = "Benny Wallet Lite",
			),
		).apply {
			blockchain = Solana.Mainnet
			this.authToken = authToken
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
		private const val MOBILE_WALLET_ADAPTER_CHANNEL = "benny_wallet/mobile_wallet_adapter"
		private const val ANDROID_KEYSTORE = "AndroidKeyStore"
		private const val BIOMETRIC_SESSION_KEY_ALIAS = "benny_wallet_biometric_session"
		private const val TRANSFORMATION = "AES/GCM/NoPadding"
		private const val GCM_TAG_LENGTH_BITS = 128
		private const val BIOMETRIC_AUTH_WINDOW_SECONDS = 30
	}
}
