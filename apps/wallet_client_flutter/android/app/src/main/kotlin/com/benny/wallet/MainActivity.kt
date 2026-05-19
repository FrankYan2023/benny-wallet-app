package com.benny.wallet

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import android.util.Log
import android.view.WindowManager
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import com.solana.mobilewalletadapter.clientlib.ActivityResultSender
import com.solana.mobilewalletadapter.clientlib.ConnectionIdentity
import com.solana.mobilewalletadapter.clientlib.MobileWalletAdapter
import com.solana.mobilewalletadapter.clientlib.Solana
import com.solana.mobilewalletadapter.clientlib.TransactionResult
import com.solanamobile.seedvault.SeedVault
import com.solanamobile.seedvault.SigningRequest
import com.solanamobile.seedvault.Wallet
import com.solanamobile.seedvault.WalletContractV1
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import java.security.KeyStore
import java.util.ArrayList
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

class MainActivity : FlutterFragmentActivity() {
	private val mainScope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
	private lateinit var mobileWalletActivityResultSender: ActivityResultSender
	private lateinit var seedVaultActivityResultLauncher: ActivityResultLauncher<Intent>
	private lateinit var seedVaultPermissionLauncher: ActivityResultLauncher<String>
	private var pendingSeedVaultActivityHandler: ((Int, Intent?) -> Unit)? = null
	private var pendingSeedVaultPermissionHandler: ((Boolean) -> Unit)? = null

	override fun onCreate(savedInstanceState: Bundle?) {
		super.onCreate(savedInstanceState)
		mobileWalletActivityResultSender = ActivityResultSender(this)
		seedVaultActivityResultLauncher = registerForActivityResult(
			ActivityResultContracts.StartActivityForResult(),
		) { activityResult ->
			val handler = pendingSeedVaultActivityHandler ?: return@registerForActivityResult
			pendingSeedVaultActivityHandler = null
			handler(activityResult.resultCode, activityResult.data)
		}
		seedVaultPermissionLauncher = registerForActivityResult(
			ActivityResultContracts.RequestPermission(),
		) { granted ->
			val handler = pendingSeedVaultPermissionHandler ?: return@registerForActivityResult
			pendingSeedVaultPermissionHandler = null
			handler(granted)
		}
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

				"isSeedVaultAvailable" -> {
					result.success(SeedVault.isAvailable(this))
				}

				"listSeedVaultAccounts" -> {
					listSeedVaultAccounts(result)
				}

				"authorizeSeedVaultSeed" -> {
					authorizeSeedVaultSeed(result)
				}

				"deauthorizeSeedVaultSeed" -> {
					val authToken = call.argument<String>("authToken")
					if (authToken.isNullOrBlank()) {
						result.success(false)
						return@setMethodCallHandler
					}
					deauthorizeSeedVaultSeed(authToken, result)
				}

				"markSeedVaultAccountAsUserWallet" -> {
					val authToken = call.argument<String>("authToken")
					val accountId = call.argument<String>("accountId")
					if (authToken.isNullOrBlank() || accountId.isNullOrBlank()) {
						result.success(false)
						return@setMethodCallHandler
					}
					markSeedVaultAccountAsUserWallet(authToken, accountId, result)
				}

				"signSeedVaultTransactions" -> {
					val authToken = call.argument<String>("authToken")
					val derivationPath = call.argument<String>("derivationPath")
					val transactions = call.argument<List<String>>("transactions")
					if (authToken.isNullOrBlank() || derivationPath.isNullOrBlank()) {
						result.error(
							"seed_vault_invalid_request",
							"Missing Seed Vault auth token or derivation path.",
							null,
						)
						return@setMethodCallHandler
					}
					if (transactions == null || transactions.isEmpty()) {
						result.error(
							"seed_vault_invalid_request",
							"Missing transactions.",
							null,
						)
						return@setMethodCallHandler
					}
					signSeedVaultTransactions(authToken, derivationPath, transactions, result)
				}

				"signSeedVaultMessages" -> {
					val authToken = call.argument<String>("authToken")
					val derivationPath = call.argument<String>("derivationPath")
					val messages = call.argument<List<String>>("messages")
					if (authToken.isNullOrBlank() || derivationPath.isNullOrBlank()) {
						result.error(
							"seed_vault_invalid_request",
							"Missing Seed Vault auth token or derivation path.",
							null,
						)
						return@setMethodCallHandler
					}
					if (messages == null || messages.isEmpty()) {
						result.error(
							"seed_vault_invalid_request",
							"Missing messages.",
							null,
						)
						return@setMethodCallHandler
					}
					signSeedVaultMessages(authToken, derivationPath, messages, result)
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
						val accounts = authResult.accounts.mapIndexed { index, account ->
							mapOf(
								"publicKeyBase64" to Base64.encodeToString(account.publicKey, Base64.NO_WRAP),
								"accountLabel" to (account.accountLabel ?: "Seeker Account ${index + 1}"),
							)
						}
						if (accounts.isEmpty()) {
							result.error(
								"mwa_no_accounts",
								"Seeker Wallet did not return any accounts.",
								null,
							)
							return@launch
						}
						result.success(
							mapOf(
								"authToken" to authResult.authToken,
								"accounts" to accounts,
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

	private fun listSeedVaultAccounts(result: MethodChannel.Result) {
		try {
			result.success(seedVaultAccountSnapshot())
		} catch (error: Exception) {
			result.error(
				"seed_vault_failure",
				error.message ?: "Unable to read Seed Vault accounts.",
				error.javaClass.name,
			)
		}
	}

	private fun authorizeSeedVaultSeed(result: MethodChannel.Result) {
		withSeedVaultAccess(result) {
			authorizeSeedVaultSeedWithAccess(result)
		}
	}

	private fun authorizeSeedVaultSeedWithAccess(result: MethodChannel.Result) {
		try {
			deauthorizeSeedVaultSeedsForPurpose()
			val intent = Wallet.authorizeSeed(
				this,
				WalletContractV1.PURPOSE_SIGN_SOLANA_TRANSACTION,
			)
			launchSeedVaultIntent(intent, result) { resultCode, data ->
				try {
					val authToken = Wallet.onAuthorizeSeedResult(resultCode, data)
					result.success(seedVaultAccountSnapshot(authTokenFilter = authToken))
				} catch (error: Exception) {
					result.error(
						"seed_vault_authorize_failed",
						error.message ?: "Seed Vault authorization was cancelled.",
						error.javaClass.name,
					)
				}
			}
		} catch (error: Exception) {
			result.error(
				"seed_vault_authorize_failed",
				error.message ?: "Seed Vault authorization failed.",
				error.javaClass.name,
			)
		}
	}

	private fun deauthorizeSeedVaultSeedsForPurpose() {
		val authTokens = mutableSetOf<Long>()
		try {
			Wallet.getAuthorizedSeeds(this, WalletContractV1.AUTHORIZED_SEEDS_ALL_COLUMNS)?.use { seedCursor ->
				while (seedCursor.moveToNext()) {
					val authPurpose = seedCursor.getOptionalInt(
						WalletContractV1.AUTHORIZED_SEEDS_AUTH_PURPOSE,
					)
					if (authPurpose != null &&
						authPurpose != WalletContractV1.PURPOSE_SIGN_SOLANA_TRANSACTION
					) {
						continue
					}
					val authToken = seedCursor.getOptionalLong(
						WalletContractV1.AUTHORIZED_SEEDS_AUTH_TOKEN,
					) ?: continue
					authTokens.add(authToken)
				}
			}
		} catch (_: SecurityException) {
			return
		} catch (_: Exception) {
			return
		}

		for (authToken in authTokens) {
			try {
				Wallet.deauthorizeSeed(this, authToken)
			} catch (_: Wallet.NotModifiedException) {
				// The token was already gone; the connect flow can continue.
			} catch (_: SecurityException) {
				return
			} catch (_: Exception) {
				// A stale token should not block the user from opening Seed Vault.
			}
		}
	}

	private fun withSeedVaultAccess(
		result: MethodChannel.Result,
		action: () -> Unit,
	) {
		if (hasSeedVaultAccess()) {
			action()
			return
		}
		if (pendingSeedVaultPermissionHandler != null) {
			result.error(
				"seed_vault_busy",
				"Another Seed Vault permission request is already in progress.",
				null,
			)
			return
		}
		pendingSeedVaultPermissionHandler = { granted ->
			if (granted || hasSeedVaultAccess()) {
				action()
			} else {
				result.error(
					"seed_vault_permission_denied",
					"Seed Vault permission was denied.",
					null,
				)
			}
		}
		try {
			seedVaultPermissionLauncher.launch(WalletContractV1.PERMISSION_ACCESS_SEED_VAULT)
		} catch (error: Exception) {
			pendingSeedVaultPermissionHandler = null
			result.error(
				"seed_vault_permission_failed",
				error.message ?: "Unable to request Seed Vault permission.",
				error.javaClass.name,
			)
		}
	}

	private fun hasSeedVaultAccess(): Boolean {
		return checkSelfPermission(WalletContractV1.PERMISSION_ACCESS_SEED_VAULT) ==
			PackageManager.PERMISSION_GRANTED ||
			checkSelfPermission(WalletContractV1.PERMISSION_ACCESS_SEED_VAULT_PRIVILEGED) ==
		PackageManager.PERMISSION_GRANTED
	}

	private fun deauthorizeSeedVaultSeed(
		authToken: String,
		result: MethodChannel.Result,
	) {
		try {
			Wallet.deauthorizeSeed(this, authToken.toLong())
			result.success(true)
		} catch (_: Wallet.NotModifiedException) {
			result.success(false)
		} catch (error: NumberFormatException) {
			result.error(
				"seed_vault_invalid_auth_token",
				"Invalid Seed Vault auth token.",
				error.javaClass.name,
			)
		} catch (error: SecurityException) {
			result.error(
				"seed_vault_permission_denied",
				error.message ?: "Seed Vault permission was denied.",
				error.javaClass.name,
			)
		} catch (error: Exception) {
			result.error(
				"seed_vault_deauthorize_failed",
				error.message ?: "Unable to deauthorize Seed Vault seed.",
				error.javaClass.name,
			)
		}
	}

	private fun markSeedVaultAccountAsUserWallet(
		authToken: String,
		accountId: String,
		result: MethodChannel.Result,
	) {
		try {
			val token = authToken.toLong()
			val id = accountId.toLong()
			Wallet.updateAccountIsUserWallet(this, token, id, true)
			Wallet.updateAccountIsValid(this, token, id, true)
			result.success(true)
		} catch (_: Wallet.NotModifiedException) {
			result.success(true)
		} catch (error: NumberFormatException) {
			result.error(
				"seed_vault_invalid_account",
				"Invalid Seed Vault account.",
				error.javaClass.name,
			)
		} catch (error: SecurityException) {
			result.error(
				"seed_vault_permission_denied",
				error.message ?: "Seed Vault permission was denied.",
				error.javaClass.name,
			)
		} catch (error: Exception) {
			result.error(
				"seed_vault_metadata_failed",
				error.message ?: "Unable to update Seed Vault account metadata.",
				error.javaClass.name,
			)
		}
	}

	private fun signSeedVaultTransactions(
		authToken: String,
		derivationPath: String,
		transactionsBase64: List<String>,
		result: MethodChannel.Result,
	) {
		try {
			val requests = transactionsBase64.mapTo(ArrayList()) { encodedTransaction ->
				SigningRequest(
					Base64.decode(encodedTransaction, Base64.DEFAULT),
					listOf(Uri.parse(derivationPath)),
				)
			}
			val intent = Wallet.signTransactions(this, authToken.toLong(), requests)
			launchSeedVaultIntent(intent, result) { resultCode, data ->
				try {
					val responses = Wallet.onSignTransactionsResult(resultCode, data)
					result.success(
						mapOf(
							"signaturesBase64" to responses.map { response ->
								Base64.encodeToString(
									response.signatures.first(),
									Base64.NO_WRAP,
								)
							},
						),
					)
				} catch (error: Exception) {
					result.error(
						"seed_vault_sign_failed",
						error.message ?: "Seed Vault transaction signing failed.",
						error.javaClass.name,
					)
				}
			}
		} catch (error: Exception) {
			result.error(
				"seed_vault_sign_failed",
				error.message ?: "Unable to start Seed Vault transaction signing.",
				error.javaClass.name,
			)
		}
	}

	private fun signSeedVaultMessages(
		authToken: String,
		derivationPath: String,
		messagesBase64: List<String>,
		result: MethodChannel.Result,
	) {
		try {
			val requests = messagesBase64.mapTo(ArrayList()) { encodedMessage ->
				SigningRequest(
					Base64.decode(encodedMessage, Base64.DEFAULT),
					listOf(Uri.parse(derivationPath)),
				)
			}
			val intent = Wallet.signMessages(this, authToken.toLong(), requests)
			launchSeedVaultIntent(intent, result) { resultCode, data ->
				try {
					val responses = Wallet.onSignMessagesResult(resultCode, data)
					result.success(
						mapOf(
							"signaturesBase64" to responses.map { response ->
								Base64.encodeToString(
									response.signatures.first(),
									Base64.NO_WRAP,
								)
							},
						),
					)
				} catch (error: Exception) {
					result.error(
						"seed_vault_sign_failed",
						error.message ?: "Seed Vault message signing failed.",
						error.javaClass.name,
					)
				}
			}
		} catch (error: Exception) {
			result.error(
				"seed_vault_sign_failed",
				error.message ?: "Unable to start Seed Vault message signing.",
				error.javaClass.name,
			)
		}
	}

	private fun launchSeedVaultIntent(
		intent: Intent,
		result: MethodChannel.Result,
		handler: (Int, Intent?) -> Unit,
	) {
		if (pendingSeedVaultActivityHandler != null) {
			result.error(
				"seed_vault_busy",
				"Another Seed Vault request is already in progress.",
				null,
			)
			return
		}
		if (intent.component == null) {
			SeedVault.resolveComponentForIntent(this, intent)
		}
		pendingSeedVaultActivityHandler = handler
		try {
			seedVaultActivityResultLauncher.launch(intent)
		} catch (error: Exception) {
			pendingSeedVaultActivityHandler = null
			throw error
		}
	}

	private fun seedVaultAccountSnapshot(
		fallbackAccounts: List<Map<String, Any?>> = emptyList(),
		authTokenFilter: Long? = null,
	): Map<String, Any> {
		val available = SeedVault.isAvailable(this)
		if (!available) {
			return mapOf(
				"available" to false,
				"hasUnauthorizedSeeds" to false,
				"accounts" to emptyList<Map<String, Any?>>(),
			)
		}

		var canReadSeedVaultProvider = true
		val hasUnauthorizedSeeds = try {
			Wallet.hasUnauthorizedSeedsForPurpose(
				this,
				WalletContractV1.PURPOSE_SIGN_SOLANA_TRANSACTION,
			)
		} catch (_: SecurityException) {
			canReadSeedVaultProvider = false
			true
		} catch (_: Exception) {
			false
		}

		val accounts = mutableListOf<Map<String, Any?>>()
		if (authTokenFilter != null) {
			try {
				val seedName = seedVaultName(authTokenFilter)
				val isBackedUp = seedVaultIsBackedUp(authTokenFilter)
				addSeedVaultAccounts(
					accounts = accounts,
					authToken = authTokenFilter,
					seedName = seedName,
					isBackedUp = isBackedUp,
				)
			} catch (_: SecurityException) {
				canReadSeedVaultProvider = false
			}
		} else {
			try {
				Wallet.getAuthorizedSeeds(this, WalletContractV1.AUTHORIZED_SEEDS_ALL_COLUMNS)?.use { seedCursor ->
					while (seedCursor.moveToNext()) {
						val authPurpose = seedCursor.getOptionalInt(
							WalletContractV1.AUTHORIZED_SEEDS_AUTH_PURPOSE,
						)
						if (authPurpose != null &&
							authPurpose != WalletContractV1.PURPOSE_SIGN_SOLANA_TRANSACTION
						) {
							continue
						}

						val authToken = seedCursor.getOptionalLong(
							WalletContractV1.AUTHORIZED_SEEDS_AUTH_TOKEN,
						) ?: continue
						val seedName = seedCursor.getOptionalString(
							WalletContractV1.AUTHORIZED_SEEDS_SEED_NAME,
						)
						val isBackedUp = seedCursor.getOptionalBoolean(
							WalletContractV1.AUTHORIZED_SEEDS_IS_BACKED_UP,
						)

						addSeedVaultAccounts(
							accounts = accounts,
							authToken = authToken,
							seedName = seedName,
							isBackedUp = isBackedUp,
						)
					}
				}
			} catch (_: SecurityException) {
				canReadSeedVaultProvider = false
			}
		}

		for (fallbackAccount in fallbackAccounts) {
			val fallbackPublicKey = fallbackAccount["publicKeyEncoded"] as? String
			val hasFallback = fallbackPublicKey != null &&
				accounts.any { it["publicKeyEncoded"] == fallbackPublicKey }
			if (!hasFallback) {
				accounts.add(fallbackAccount)
			}
		}

		return mapOf(
			"available" to true,
			"hasUnauthorizedSeeds" to (hasUnauthorizedSeeds || !canReadSeedVaultProvider),
			"accounts" to accounts,
		)
	}

	private fun addSeedVaultAccounts(
		accounts: MutableList<Map<String, Any?>>,
		authToken: Long,
		seedName: String?,
		isBackedUp: Boolean?,
	) {
		var count = 0
		Wallet.getAccounts(this, authToken, WalletContractV1.ACCOUNTS_ALL_COLUMNS)?.use { accountCursor ->
			while (accountCursor.moveToNext()) {
				val isValid = accountCursor.getOptionalBoolean(
					WalletContractV1.ACCOUNTS_ACCOUNT_IS_VALID,
				)
				if (isValid == false) {
					continue
				}
				val publicKeyBase64 = accountCursor.getOptionalBlob(
					WalletContractV1.ACCOUNTS_PUBLIC_KEY_RAW,
				)?.let { Base64.encodeToString(it, Base64.NO_WRAP) }
				val publicKeyEncoded = accountCursor.getOptionalString(
					WalletContractV1.ACCOUNTS_PUBLIC_KEY_ENCODED,
				)
				if (publicKeyBase64.isNullOrBlank() && publicKeyEncoded.isNullOrBlank()) {
					continue
				}

				accounts.add(
					mapOf(
						"seedAuthToken" to authToken.toString(),
						"seedName" to seedName,
						"isBackedUp" to isBackedUp,
						"accountId" to accountCursor.getOptionalLong(
							WalletContractV1.ACCOUNTS_ACCOUNT_ID,
						)?.toString(),
						"accountName" to accountCursor.getOptionalString(
							WalletContractV1.ACCOUNTS_ACCOUNT_NAME,
						),
						"derivationPath" to accountCursor.getOptionalString(
							WalletContractV1.ACCOUNTS_BIP32_DERIVATION_PATH,
						),
						"publicKeyBase64" to publicKeyBase64,
						"publicKeyEncoded" to publicKeyEncoded,
						"isUserWallet" to accountCursor.getOptionalBoolean(
							WalletContractV1.ACCOUNTS_ACCOUNT_IS_USER_WALLET,
						),
						"isValid" to isValid,
					),
				)
				count += 1
			}
		}
		Log.d(TAG, "Seed Vault provider returned $count account(s) for token $authToken seed=$seedName")
	}

	private fun seedVaultName(authToken: Long): String? {
		return try {
			Wallet.getAuthorizedSeed(this, authToken, WalletContractV1.AUTHORIZED_SEEDS_ALL_COLUMNS)?.use {
				if (it.moveToFirst()) {
					it.getOptionalString(WalletContractV1.AUTHORIZED_SEEDS_SEED_NAME)
				} else {
					null
				}
			}
		} catch (_: SecurityException) {
			null
		}
	}

	private fun seedVaultIsBackedUp(authToken: Long): Boolean? {
		return try {
			Wallet.getAuthorizedSeed(this, authToken, WalletContractV1.AUTHORIZED_SEEDS_ALL_COLUMNS)?.use {
				if (it.moveToFirst()) {
					it.getOptionalBoolean(WalletContractV1.AUTHORIZED_SEEDS_IS_BACKED_UP)
				} else {
					null
				}
			}
		} catch (_: SecurityException) {
			null
		}
	}

	private fun Cursor.getOptionalColumnIndex(columnName: String): Int {
		val index = getColumnIndex(columnName)
		return if (index >= 0 && !isNull(index)) index else -1
	}

	private fun Cursor.getOptionalString(columnName: String): String? {
		val index = getOptionalColumnIndex(columnName)
		return if (index >= 0) getString(index) else null
	}

	private fun Cursor.getOptionalLong(columnName: String): Long? {
		val index = getOptionalColumnIndex(columnName)
		return if (index >= 0) getLong(index) else null
	}

	private fun Cursor.getOptionalInt(columnName: String): Int? {
		val index = getOptionalColumnIndex(columnName)
		return if (index >= 0) getInt(index) else null
	}

	private fun Cursor.getOptionalBoolean(columnName: String): Boolean? {
		return getOptionalInt(columnName)?.let { it != 0 }
	}

	private fun Cursor.getOptionalBlob(columnName: String): ByteArray? {
		val index = getOptionalColumnIndex(columnName)
		return if (index >= 0) getBlob(index) else null
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
		private const val TAG = "BennySeedVault"
		private const val ANDROID_KEYSTORE = "AndroidKeyStore"
		private const val BIOMETRIC_SESSION_KEY_ALIAS = "benny_wallet_biometric_session"
		private const val TRANSFORMATION = "AES/GCM/NoPadding"
		private const val GCM_TAG_LENGTH_BITS = 128
		private const val BIOMETRIC_AUTH_WINDOW_SECONDS = 30
	}
}
