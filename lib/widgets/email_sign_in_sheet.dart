import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../services/digest_service.dart';
import '../services/settings_manager.dart';
import '../utils/app_sizing.dart';
import '../utils/app_spacing.dart';
import '../utils/app_typography.dart';

/// Confirms the user's email with a six-digit code so the server knows whose
/// Vault and digest a request is for. Resolves to true once signed in.
Future<bool> showEmailSignInSheet(BuildContext context) async {
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.cardBackground,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizing.of(context).radiusLg)),
    ),
    builder: (_) => const EmailSignInSheet(),
  );
  return ok ?? false;
}

/// Shows [child] once the user has confirmed their email, and an invitation to
/// do so before that.
class SignInGate extends StatefulWidget {
  final Widget Function() child;

  /// Lets the screen load what it could not fetch before sign-in.
  final VoidCallback? onSignedIn;
  const SignInGate({super.key, required this.child, this.onSignedIn});

  @override
  State<SignInGate> createState() => _SignInGateState();
}

class _SignInGateState extends State<SignInGate> {
  late Future<bool> _signedIn = DigestService().isSignedIn();

  Future<void> _signIn() async {
    if (await showEmailSignInSheet(context) && mounted) {
      widget.onSignedIn?.call();
      setState(() {
        _signedIn = Future.value(true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _signedIn,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.neonCyan));
        }
        if (snapshot.data == true) return widget.child();

        final l10n = AppLocalizations.of(context)!;
        final spacing = AppSpacing.of(context);
        final sizing = AppSizing.of(context);
        final typography = AppTypography.of(context);
        return Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(spacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mark_email_read_outlined,
                    color: AppColors.neonCyan, size: sizing.iconXl),
                SizedBox(height: spacing.md),
                Text(
                  l10n.accountGateTitle,
                  textAlign: TextAlign.center,
                  style: typography.title.copyWith(color: AppColors.textMain),
                ),
                SizedBox(height: spacing.sm),
                Text(
                  l10n.accountGateBody,
                  textAlign: TextAlign.center,
                  style: typography.body.copyWith(color: AppColors.textMuted),
                ),
                SizedBox(height: spacing.lg),
                _PrimaryButton(label: l10n.accountGateButton, onTap: _signIn),
              ],
            ),
          ),
        );
      },
    );
  }
}

class EmailSignInSheet extends StatefulWidget {
  const EmailSignInSheet({super.key});

  @override
  State<EmailSignInSheet> createState() => _EmailSignInSheetState();
}

class _EmailSignInSheetState extends State<EmailSignInSheet> {
  late final _email = TextEditingController(text: SettingsManager().email);
  final _code = TextEditingController();
  bool _codeSent = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await DigestService().requestCode(_email.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      switch (result) {
        case CodeRequestResult.sent:
          _codeSent = true;
        case CodeRequestResult.tooSoon:
          // A code is already on its way; let them enter it.
          _codeSent = true;
          _error = l10n.accountErrorTooSoon;
        case CodeRequestResult.invalidEmail:
          _error = l10n.accountErrorInvalidEmail;
        case CodeRequestResult.failed:
          _error = l10n.accountErrorNetwork;
      }
    });
  }

  Future<void> _confirm() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await DigestService().verifyCode(_email.text, _code.text);
    if (!mounted) return;
    if (result == SignInResult.signedIn) {
      Navigator.of(context).maybePop(true);
      return;
    }
    setState(() {
      _busy = false;
      _error = switch (result) {
        SignInResult.wrongCode => l10n.accountErrorWrongCode,
        SignInResult.locked => l10n.accountErrorLocked,
        _ => l10n.accountErrorNetwork,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final typography = AppTypography.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: spacing.lg,
        right: spacing.lg,
        top: spacing.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + spacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.accountSignInTitle,
              style: typography.title.copyWith(color: AppColors.textMain),
            ),
            SizedBox(height: spacing.sm),
            Text(
              _codeSent
                  ? l10n.accountCodeSentTo(_email.text.trim())
                  : l10n.accountSignInBody,
              style: typography.body.copyWith(color: AppColors.textMuted),
            ),
            SizedBox(height: spacing.md),
            if (!_codeSent)
              _Field(
                controller: _email,
                label: l10n.accountEmailLabel,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                onSubmitted: (_) => _busy ? null : _send(),
              )
            else
              _Field(
                controller: _code,
                label: l10n.accountCodeLabel,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                onSubmitted: (_) => _busy ? null : _confirm(),
              ),
            if (_error != null) ...[
              SizedBox(height: spacing.sm),
              Semantics(
                liveRegion: true,
                child: Text(
                  _error!,
                  style:
                      typography.bodySm.copyWith(color: AppColors.neonCrimson),
                ),
              ),
            ],
            SizedBox(height: spacing.md),
            _PrimaryButton(
              label: _codeSent ? l10n.accountConfirm : l10n.accountSendCode,
              busy: _busy,
              onTap: _codeSent ? _confirm : _send,
            ),
            if (_codeSent) ...[
              SizedBox(height: spacing.sm),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _busy ? null : _send,
                    child: Text(l10n.accountResendCode,
                        style: const TextStyle(color: AppColors.neonCyan)),
                  ),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                              _codeSent = false;
                              _code.clear();
                              _error = null;
                            }),
                    child: Text(l10n.accountChangeEmail,
                        style: const TextStyle(color: AppColors.textMuted)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final Iterable<String> autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String> onSubmitted;

  const _Field({
    required this.controller,
    required this.label,
    required this.keyboardType,
    required this.autofillHints,
    required this.onSubmitted,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final sizing = AppSizing.of(context);
    return TextField(
      controller: controller,
      autofocus: true,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      inputFormatters: inputFormatters,
      onSubmitted: onSubmitted,
      style: const TextStyle(color: AppColors.textMain),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMuted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sizing.radiusMd),
          borderSide:
              BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sizing.radiusMd),
          borderSide: const BorderSide(color: AppColors.neonCyan),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool busy;
  const _PrimaryButton(
      {required this.label, required this.onTap, this.busy = false});

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);
    return Semantics(
      button: true,
      enabled: !busy,
      child: Material(
        color: AppColors.neonCyan.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(sizing.radiusMd),
        child: InkWell(
          onTap: busy ? null : onTap,
          borderRadius: BorderRadius.circular(sizing.radiusMd),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: sizing.minTouchTarget),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: spacing.lg, vertical: spacing.sm),
              child: Center(
                widthFactor: 1,
                child: busy
                    ? SizedBox(
                        width: sizing.iconSm,
                        height: sizing.iconSm,
                        child: const CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.neonCyan),
                      )
                    : Text(
                        label,
                        textAlign: TextAlign.center,
                        style: typography.label.copyWith(
                          color: AppColors.neonCyan,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
