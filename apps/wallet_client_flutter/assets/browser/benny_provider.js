// Benny Wallet in-app browser provider. Injected at document start into
// every page of Benny's own browser; registers Benny with the Solana Wallet
// Standard and as window.benny (window.solana when free). Every request is
// passed to the app, which shows its own review page; nothing is signed
// here. __BENNY_ICON__ is replaced with the wallet icon (data URI).
(function () {
  'use strict';
  if (window.__bennyWalletInjected) return;
  window.__bennyWalletInjected = true;

  var CHAIN = 'solana:mainnet';
  var CHAINS = [CHAIN, 'solana:5eykt4UsFv8P8NJdTREpY1vzqKqZKvdp'];
  var ICON = '__BENNY_ICON__';
  var FEATURES = [
    'solana:signTransaction',
    'solana:signAndSendTransaction',
    'solana:signMessage',
  ];

  // The app's handler becomes callable once the platform is ready.
  var ready = new Promise(function (resolve) {
    if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
      resolve();
      return;
    }
    window.addEventListener('flutterInAppWebViewPlatformReady', function () {
      resolve();
    }, { once: true });
  });

  function call(method, params) {
    return ready.then(function () {
      return window.flutter_inappwebview.callHandler('bennyWallet', {
        method: method,
        params: params || {},
      });
    }).then(function (reply) {
      if (!reply || reply.error) {
        var error = new Error((reply && reply.error) || 'Request failed.');
        error.code = (reply && reply.code) || 4001;
        throw error;
      }
      return reply.result;
    });
  }

  function toBase64(bytes) {
    var binary = '';
    var chunk = 0x8000;
    for (var i = 0; i < bytes.length; i += chunk) {
      binary += String.fromCharCode.apply(null, bytes.subarray(i, i + chunk));
    }
    return btoa(binary);
  }

  function fromBase64(text) {
    var binary = atob(text);
    var bytes = new Uint8Array(binary.length);
    for (var i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
    return bytes;
  }

  // ---- Wallet Standard -------------------------------------------------

  var accounts = [];
  var listeners = { change: [] };

  function makeAccount(result) {
    return Object.freeze({
      address: result.address,
      publicKey: fromBase64(result.publicKey),
      chains: CHAINS.slice(),
      features: FEATURES.slice(),
      label: result.label || undefined,
      icon: ICON,
    });
  }

  function setAccounts(next) {
    accounts = next;
    listeners.change.forEach(function (listener) {
      try { listener({ accounts: accounts }); } catch (e) { /* ignore */ }
    });
  }

  function connect(input) {
    var silent = !!(input && input.silent);
    return call('connect', { silent: silent }).then(function (result) {
      if (result) setAccounts([makeAccount(result)]);
      return { accounts: accounts };
    }).catch(function (error) {
      if (silent) return { accounts: [] };
      throw error;
    });
  }

  function disconnect() {
    return call('disconnect').then(function () { setAccounts([]); });
  }

  function signTransactionInputs(inputs, method) {
    return call(method, {
      transactions: inputs.map(function (input) { return toBase64(input.transaction); }),
    });
  }

  var wallet = {
    version: '1.0.0',
    name: 'Benny Wallet',
    icon: ICON,
    chains: CHAINS.slice(),
    get accounts() { return accounts.slice(); },
    features: {
      'standard:connect': { version: '1.0.0', connect: connect },
      'standard:disconnect': { version: '1.0.0', disconnect: disconnect },
      'standard:events': {
        version: '1.0.0',
        on: function (event, listener) {
          (listeners[event] = listeners[event] || []).push(listener);
          return function () {
            listeners[event] = (listeners[event] || []).filter(function (l) { return l !== listener; });
          };
        },
      },
      'solana:signTransaction': {
        version: '1.0.0',
        supportedTransactionVersions: ['legacy', 0],
        signTransaction: function () {
          var inputs = Array.prototype.slice.call(arguments);
          return signTransactionInputs(inputs, 'signTransactions').then(function (result) {
            return result.transactions.map(function (t) { return { signedTransaction: fromBase64(t) }; });
          });
        },
      },
      'solana:signAndSendTransaction': {
        version: '1.0.0',
        supportedTransactionVersions: ['legacy', 0],
        signAndSendTransaction: function () {
          var inputs = Array.prototype.slice.call(arguments);
          return signTransactionInputs(inputs, 'signAndSendTransactions').then(function (result) {
            return result.signatures.map(function (s) { return { signature: fromBase64(s) }; });
          });
        },
      },
      'solana:signMessage': {
        version: '1.0.0',
        signMessage: function () {
          var inputs = Array.prototype.slice.call(arguments);
          return Promise.all(inputs.map(function (input) {
            return call('signMessage', { message: toBase64(input.message) }).then(function (result) {
              return { signedMessage: input.message, signature: fromBase64(result.signature) };
            });
          }));
        },
      },
    },
  };

  function RegisterWalletEvent(callback) {
    var event = new Event('wallet-standard:register-wallet', { bubbles: false, cancelable: false, composed: false });
    Object.defineProperty(event, 'detail', { value: callback });
    return event;
  }

  function registerStandard() {
    var callback = function (api) { api.register(wallet); };
    try { window.dispatchEvent(RegisterWalletEvent(callback)); } catch (e) { /* ignore */ }
    try {
      window.addEventListener('wallet-standard:app-ready', function (event) { callback(event.detail); });
    } catch (e) { /* ignore */ }
  }

  // ---- Legacy provider (window.benny / window.solana) ----------------

  function PublicKey(address, bytes) {
    this._address = address;
    this._bytes = bytes;
  }
  PublicKey.prototype.toBase58 = function () { return this._address; };
  PublicKey.prototype.toString = function () { return this._address; };
  PublicKey.prototype.toJSON = function () { return this._address; };
  PublicKey.prototype.toBytes = function () { return new Uint8Array(this._bytes); };
  PublicKey.prototype.toBuffer = function () { return this.toBytes(); };
  PublicKey.prototype.equals = function (other) {
    return !!other && typeof other.toBase58 === 'function' && other.toBase58() === this._address;
  };

  function serialize(tx) {
    // VersionedTransaction has a version; a legacy Transaction does not.
    if ('version' in tx) return tx.serialize();
    return tx.serialize({ requireAllSignatures: false, verifySignatures: false });
  }

  function rebuild(original, bytes) {
    var ctor = original.constructor;
    if (typeof ctor.deserialize === 'function') return ctor.deserialize(bytes);
    if (typeof ctor.from === 'function') return ctor.from(bytes);
    return bytes;
  }

  var legacyListeners = {};
  function emit(event, value) {
    (legacyListeners[event] || []).forEach(function (l) { try { l(value); } catch (e) { /* ignore */ } });
  }

  var legacy = {
    isBenny: true,
    publicKey: null,
    isConnected: false,
    connect: function (options) {
      var silent = !!(options && options.onlyIfTrusted);
      return call('connect', { silent: silent }).then(function (result) {
        legacy.publicKey = new PublicKey(result.address, fromBase64(result.publicKey));
        legacy.isConnected = true;
        setAccounts([makeAccount(result)]);
        emit('connect', legacy.publicKey);
        return { publicKey: legacy.publicKey };
      });
    },
    disconnect: function () {
      return disconnect().then(function () {
        legacy.publicKey = null;
        legacy.isConnected = false;
        emit('disconnect');
      });
    },
    signTransaction: function (tx) {
      return call('signTransactions', { transactions: [toBase64(serialize(tx))] }).then(function (result) {
        return rebuild(tx, fromBase64(result.transactions[0]));
      });
    },
    signAllTransactions: function (txs) {
      return call('signTransactions', {
        transactions: txs.map(function (tx) { return toBase64(serialize(tx)); }),
      }).then(function (result) {
        return result.transactions.map(function (t, i) { return rebuild(txs[i], fromBase64(t)); });
      });
    },
    signAndSendTransaction: function (tx) {
      return call('signAndSendTransactions', { transactions: [toBase64(serialize(tx))] }).then(function (result) {
        var bytes = fromBase64(result.signatures[0]);
        return { signature: result.base58Signatures ? result.base58Signatures[0] : bytes, publicKey: legacy.publicKey };
      });
    },
    signMessage: function (message) {
      return call('signMessage', { message: toBase64(message) }).then(function (result) {
        return { signature: fromBase64(result.signature), publicKey: legacy.publicKey };
      });
    },
    on: function (event, listener) {
      (legacyListeners[event] = legacyListeners[event] || []).push(listener);
    },
    off: function (event, listener) {
      legacyListeners[event] = (legacyListeners[event] || []).filter(function (l) { return l !== listener; });
    },
    removeListener: function (event, listener) { legacy.off(event, listener); },
  };

  try { Object.defineProperty(window, 'benny', { value: legacy, configurable: false }); } catch (e) { /* ignore */ }
  if (typeof window.solana === 'undefined') {
    try { window.solana = legacy; } catch (e) { /* ignore */ }
  }

  registerStandard();
})();
