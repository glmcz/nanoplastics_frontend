import 'package:flutter/material.dart';

import '../screens/digest_settings_screen.dart';
import '../screens/vault_screen.dart';
import '../services/digest_service.dart';
import 'email_sign_in_sheet.dart';

/// The way in to the Vault from anywhere outside it (the tour): register by
/// email code if needed, then land where the user can act. With the digest
/// still off that is Research Preferences; otherwise the Vault itself.
Future<void> openVaultSetup(BuildContext context) async {
  final digest = DigestService();
  if (!await digest.isSignedIn()) {
    if (!context.mounted || !await showEmailSignInSheet(context)) return;
  }
  if (!context.mounted) return;
  if (await _digestIsOff()) {
    if (!context.mounted) return;
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const DigestSettingsScreen()));
  } else {
    if (!context.mounted) return;
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const VaultScreen()));
  }
}

/// After someone registers from inside the Vault, an empty Vault is a dead
/// end; the next step is choosing when their daily paper arrives.
Future<void> continueToDigestIfOff(BuildContext context) async {
  if (!await _digestIsOff() || !context.mounted) return;
  await Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const DigestSettingsScreen()));
}

Future<bool> _digestIsOff() async {
  final prefs = await DigestService().fetchPreferences();
  return prefs == null || !prefs.enabled;
}
