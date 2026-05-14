import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/error_alert_dialog.dart';

class ContactFeedbackPage extends ConsumerStatefulWidget {
  const ContactFeedbackPage({super.key});

  static const routeName = 'contactFeedback';
  static const routePath = '/settings/contact-feedback';

  @override
  ConsumerState<ContactFeedbackPage> createState() =>
      _ContactFeedbackPageState();
}

class _ContactFeedbackPageState extends ConsumerState<ContactFeedbackPage> {
  static final _emailPattern = RegExp(
    r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$',
    caseSensitive: false,
  );

  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Feedback',
      child: ListView(
        children: [
          WalletCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tell us what went wrong',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Send your question or issue directly to Benny Wallet support.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                _FieldLabel(label: 'Email (optional)'),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  enabled: !_submitting,
                  decoration: _inputDecoration(
                    hintText: 'you@example.com',
                  ),
                ),
                const SizedBox(height: 16),
                _FieldLabel(label: 'Message'),
                const SizedBox(height: 8),
                TextField(
                  controller: _messageController,
                  enabled: !_submitting,
                  maxLength: 2000,
                  minLines: 6,
                  maxLines: 10,
                  textInputAction: TextInputAction.newline,
                  decoration: _inputDecoration(
                    hintText: 'Describe the issue you are seeing.',
                  ),
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: _submitting ? 'Sending...' : 'Send',
                  onPressed: _submitting ? null : _submit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: const Color(0xFFF7F1E7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: Color(0xFFA46708), width: 1.5),
      ),
      counterStyle: const TextStyle(
        color: Color(0xFF8A7D6A),
      ),
    );
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      await showErrorAlertDialog(
        context,
        title: 'Message Required',
        message: 'Enter your feedback before sending.',
      );
      return;
    }

    if (message.length > 2000) {
      await showErrorAlertDialog(
        context,
        title: 'Message Too Long',
        message: 'Keep your feedback within 2000 characters.',
      );
      return;
    }

    if (email.isNotEmpty && !_emailPattern.hasMatch(email)) {
      await showErrorAlertDialog(
        context,
        title: 'Invalid Email',
        message: 'Enter a valid email address or leave it empty.',
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      await ref.read(backendApiClientProvider).submitContactRequest(
            email: '',
            message: _buildContactPayloadMessage(
              email: email,
              message: message,
            ),
          );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your message has been sent.')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }
      await showErrorAlertDialog(
        context,
        title: 'Send Failed',
        message: _normalizeContactErrorMessage(error.toString()),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
    );
  }
}

String _buildContactPayloadMessage({
  required String email,
  required String message,
}) {
  if (email.isEmpty) {
    return message;
  }

  return 'Contact email: $email\n\n$message';
}

String _normalizeContactErrorMessage(String value) {
  const fallback = 'Unable to send your message right now. Please try again shortly.';
  final normalized = value.trim();
  if (normalized.startsWith('Exception: ')) {
    return _normalizeContactErrorMessage(
      normalized.substring('Exception: '.length),
    );
  }

  final lower = normalized.toLowerCase();
  if (lower == 'failed to fetch' ||
      lower.contains('networkerror') ||
      lower.contains('network error') ||
      lower.contains('load failed')) {
    return fallback;
  }

  return normalized.isEmpty ? fallback : normalized;
}
