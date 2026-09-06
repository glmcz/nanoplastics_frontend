import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../services/digest_service.dart';
import '../services/push_notification_service.dart';
import '../services/service_locator.dart';
import '../utils/app_spacing.dart';
import '../utils/app_sizing.dart';
import '../utils/platform_adaptive.dart';

class DigestSettingsScreen extends StatefulWidget {
  const DigestSettingsScreen({super.key});

  @override
  State<DigestSettingsScreen> createState() => _DigestSettingsScreenState();
}

class _DigestSettingsScreenState extends State<DigestSettingsScreen> {
  final _svc = DigestService();

  late List<String> _keywords;
  bool _digestEnabled = true;
  int _digestHour = 9;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _keywords = List.from(_svc.getKeywords());
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await _svc.fetchPreferences();
    if (prefs != null && mounted) {
      setState(() {
        _digestEnabled = prefs.enabled;
        _digestHour = prefs.digestHour;
      });
    }
  }

  void _requestMoreKeywords() {
    final email = ServiceLocator().settingsManager.email;
    final supportEmail = AppLocalizations.of(context)!.leaderboardContactEmail;
    final subject =
        Uri.encodeComponent('Nanoplastics Digest - Keyword Request');
    final body = Uri.encodeComponent(
        'User email: $email\nCurrent keywords: ${_keywords.join(', ')}\n\nRequested new keyword(s): ');
    PlatformAdaptive.launchExternalUri(
        Uri.parse('mailto:$supportEmail?subject=$subject&body=$body'));
  }

  Future<void> _save() async {
    if (ServiceLocator().settingsManager.email.isEmpty) {
      setState(
          () => _error = AppLocalizations.of(context)!.profileEmailRequired);
      return;
    }

    setState(() => _saving = true);
    final ok = await _svc.updatePreferences(
      enabled: _digestEnabled,
      digestHour: _digestHour,
      keywords: _keywords,
    );
    if (mounted) {
      setState(() => _saving = false);
      if (ok) {
        PushNotificationService().init();
        if (mounted) Navigator.maybePop(context);
      } else {
        setState(
            () => _error = AppLocalizations.of(context)!.digestSettingsError);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, spacing, sizing),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Toggle
                    _GlassCard(
                      child: SwitchListTile(
                        title: Text(
                            AppLocalizations.of(context)!
                                .digestSettingsDailyDigest,
                            style: const TextStyle(
                                color: AppColors.textMain, fontSize: 14)),
                        subtitle: Text(
                            AppLocalizations.of(context)!
                                .digestSettingsDailyDigestHint,
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 12)),
                        value: _digestEnabled,
                        activeThumbColor: AppColors.neonCyan,
                        onChanged: (v) => setState(() => _digestEnabled = v),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(height: spacing.md),

                    // Digest time
                    _GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!
                                .digestSettingsNotificationTime,
                            style: const TextStyle(
                              color: AppColors.textMain,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: spacing.sm),
                          Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  value: _digestHour.toDouble(),
                                  min: 0,
                                  max: 23,
                                  divisions: 23,
                                  activeColor: AppColors.neonCyan,
                                  onChanged: (v) =>
                                      setState(() => _digestHour = v.toInt()),
                                ),
                              ),
                              SizedBox(width: spacing.sm),
                              Text(
                                '${_digestHour.toString().padLeft(2, '0')}:00 UTC',
                                style: const TextStyle(
                                  color: AppColors.neonCyan,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: spacing.md),

                    // Keywords section label
                    Text(
                      AppLocalizations.of(context)!.digestSettingsKeywords,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: spacing.sm),

                    _GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Existing chips
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: _keywords
                                .map((kw) => _KeywordChip(label: kw))
                                .toList(),
                          ),
                          SizedBox(height: spacing.md),

                          // Request more keywords via email
                          Semantics(
                            button: true,
                            label: AppLocalizations.of(context)!
                                .digestSettingsKeywordRequestMore,
                            child: InkWell(
                              onTap: _requestMoreKeywords,
                              borderRadius: BorderRadius.circular(6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.email_outlined,
                                      color: AppColors.neonCyan, size: 16),
                                  SizedBox(width: spacing.xs),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .digestSettingsKeywordRequestMore,
                                    style: const TextStyle(
                                      color: AppColors.neonCyan,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          if (_error != null) ...[
                            SizedBox(height: spacing.xs),
                            Text(_error!,
                                style: const TextStyle(
                                    color: AppColors.neonCrimson,
                                    fontSize: 11)),
                          ],
                        ],
                      ),
                    ),

                    SizedBox(height: spacing.xl),

                    // Save button
                    Semantics(
                      button: true,
                      label: AppLocalizations.of(context)!.digestSettingsSave,
                      child: InkWell(
                        onTap: _saving ? null : _save,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: spacing.md),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color:
                                    AppColors.neonCyan.withValues(alpha: 0.6)),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.neonCyan.withValues(alpha: 0.1),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: _saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.neonCyan,
                                    ),
                                  )
                                : Text(
                                    AppLocalizations.of(context)!
                                        .categoryDetailBrainstormSave,
                                    style: const TextStyle(
                                      color: AppColors.neonCyan,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, AppSpacing spacing, AppSizing sizing) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: spacing.md, vertical: spacing.sm),
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withValues(alpha: 0.9),
            border: Border(
              bottom:
                  BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.15)),
            ),
          ),
          child: Row(
            children: [
              Semantics(
                button: true,
                label: AppLocalizations.of(context)!.settingsBack,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: AppColors.neonCyan, size: 20),
                  onPressed: () => Navigator.maybePop(context),
                  padding: EdgeInsets.zero,
                ),
              ),
              SizedBox(width: spacing.sm),
              Text(
                AppLocalizations.of(context)!.digestSettingsTitle,
                style: const TextStyle(
                  color: AppColors.textMain,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _KeywordChip extends StatelessWidget {
  final String label;

  const _KeywordChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.neonCyan.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: const TextStyle(
              color: AppColors.neonCyan,
              fontSize: 12,
              fontWeight: FontWeight.w500)),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: child,
    );
  }
}
