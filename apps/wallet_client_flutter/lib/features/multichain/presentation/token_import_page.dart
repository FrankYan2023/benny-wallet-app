import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/chains/chain_models.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../providers/multichain_providers.dart';
import 'chain_widgets.dart';
import 'network_page.dart';

class TokenImportPage extends ConsumerStatefulWidget {
  const TokenImportPage({super.key, required this.chainId});
  static const routePath = '/networks/:chainId/import-token';
  final String chainId;

  @override
  ConsumerState<TokenImportPage> createState() => _TokenImportPageState();
}

class _TokenImportPageState extends ConsumerState<TokenImportPage> {
  final _address = TextEditingController();
  ChainAsset? _token;
  Object? _error;
  bool _busy = false;

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = findChain(ref.watch(chainConfigsProvider), widget.chainId);
    return AppScaffold(
      title: chainText(context, 'Import token', '导入代币'),
      child: config == null
          ? Text(chainText(context, 'Network is not configured.', '尚未配置此网络。'))
          : ListView(
              children: [
                ChainNetworkLabel(config: config),
                const SizedBox(height: 18),
                WalletCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _address,
                        enabled: !_busy && _token == null,
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: InputDecoration(
                          labelText: chainText(
                            context,
                            'Token contract address',
                            '代币合约地址',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_token == null)
                        FilledButton(
                          onPressed: _busy ? null : _inspect,
                          child: Text(
                            chainText(context, 'Look up token', '查询代币'),
                          ),
                        )
                      else ...[
                        ChainDetail(
                          label: chainText(context, 'Name', '名称'),
                          value: _token!.name,
                        ),
                        ChainDetail(
                          label: chainText(context, 'Symbol', '符号'),
                          value: _token!.symbol,
                        ),
                        ChainDetail(
                          label: chainText(context, 'Decimals', '小数位'),
                          value: '${_token!.decimals}',
                        ),
                        ChainDetail(
                          label: chainText(context, 'Contract', '合约'),
                          value:
                              _token!.contractAddress ?? _address.text.trim(),
                        ),
                        Text(
                          chainText(
                            context,
                            'Token names can be copied. Verify this contract with the issuer. Importing a token does not approve spending.',
                            '代币名称可能被仿冒，请向发行方核实合约。导入代币不会授权支出。',
                          ),
                        ),
                        const SizedBox(height: 18),
                        FilledButton(
                          onPressed: _busy ? null : _save,
                          child: Text(
                            chainText(context, 'Import this token', '导入此代币'),
                          ),
                        ),
                        TextButton(
                          onPressed: _busy
                              ? null
                              : () => setState(() {
                                  _token = null;
                                  _error = null;
                                }),
                          child: Text(
                            chainText(context, 'Change contract', '更换合约'),
                          ),
                        ),
                      ],
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            '$_error',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      if (_busy)
                        const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: LinearProgressIndicator(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _inspect() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (!ref
          .read(chainAdapterProvider(widget.chainId))
          .validateAddress(_address.text.trim())) {
        throw FormatException(
          chainText(context, 'Enter a valid contract address.', '请输入有效的合约地址。'),
        );
      }
      final token = await ref
          .read(tokenImportControllerProvider)
          .inspectToken(widget.chainId, _address.text.trim());
      if (mounted) setState(() => _token = token);
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(tokenImportControllerProvider)
          .saveToken(widget.chainId, _token!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(chainText(context, 'Token imported', '代币已导入')),
          ),
        );
        context.pop();
      }
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
