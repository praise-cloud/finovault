import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/mock/api.dart';
import '../../core/mock/http_api.dart';
import '../../core/providers.dart';
import '../../core/state/auth.dart';
import '../../core/state/biometric.dart';
import '../../core/state/notifications.dart';
import '../../core/state/preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';
import '../home_shell.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final s = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(FvSpacing.x5),
      children: [
        FvCard(
          margin: const EdgeInsets.only(bottom: FvSpacing.x4),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: FvColors.wash,
                child: Text(
                  (user?.fullName ?? 'A').split(' ').map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: FvColors.primary),
                ),
              ),
              const SizedBox(width: FvSpacing.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.fullName ?? 'Welcome', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.fvText)),
                    const SizedBox(height: 2),
                    Text(user?.email ?? '', style: TextStyle(fontSize: 13, color: context.fvTextSecondary)),
                  ],
                ),
              ),
              StatusBadge(label: 'Free', foreground: FvColors.primary, background: FvColors.wash),
            ],
          ),
        ),
        _Row(icon: Icons.security_outlined, label: s.security, onTap: () => openSecurity(context)),
        _Row(icon: Icons.account_balance_outlined, label: s.linkedAccounts, onTap: () => openAccounts(context)),
        _Row(icon: Icons.tune_outlined, label: s.settingsAndPlan, onTap: () => _openSettings(context, ref)),
        const SizedBox(height: FvSpacing.x3),
        _Row(
          icon: Icons.logout_outlined,
          label: s.logout,
          danger: true,
          onTap: () => _confirmLogout(context, ref),
        ),
      ],
    );
  }

  void _openSettings(BuildContext context, WidgetRef ref) {
    final prefs = ref.read(preferencesProvider);
    final s = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.fvIsDark ? FvColors.bgDark : FvColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (sheet) => Padding(
        padding: const EdgeInsets.all(FvSpacing.x5),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: context.fvBorder, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: FvSpacing.x4),
              Text(s.settings, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.fvText)),
              const SizedBox(height: FvSpacing.x4),
              Text(s.language, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: FvSpacing.x2),
            Row(
              children: [
                _ChoiceChip(selected: prefs.language == 'en', label: 'English', onTap: () => ref.read(preferencesProvider.notifier).setLanguage('en')),
                const SizedBox(width: FvSpacing.x2),
                _ChoiceChip(selected: prefs.language == 'fr', label: 'Français', onTap: () => ref.read(preferencesProvider.notifier).setLanguage('fr')),
              ],
            ),
            const SizedBox(height: FvSpacing.x4),
            Text(s.appearance, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: FvSpacing.x2),
            Consumer(
              builder: (context, ref, _) {
                final mode = ref.watch(preferencesProvider).themeMode;
                return Row(
                  children: [
                    _ChoiceChip(selected: mode == ThemeModePref.light, label: s.themeLight, onTap: () => ref.read(preferencesProvider.notifier).setThemeMode(ThemeModePref.light)),
                    const SizedBox(width: FvSpacing.x2),
                    _ChoiceChip(selected: mode == ThemeModePref.dark, label: s.themeDark, onTap: () => ref.read(preferencesProvider.notifier).setThemeMode(ThemeModePref.dark)),
                    const SizedBox(width: FvSpacing.x2),
                    _ChoiceChip(selected: mode == ThemeModePref.system, label: s.themeSystem, onTap: () => ref.read(preferencesProvider.notifier).setThemeMode(ThemeModePref.system)),
                  ],
                );
              },
            ),
            const SizedBox(height: FvSpacing.x4),
            Consumer(
              builder: (context, ref, _) {
                final enabled = ref.watch(preferencesProvider).biometricEnabled;
                return _SwitchRow(
                  icon: Icons.fingerprint,
                  label: s.biometricUnlock,
                  value: enabled,
                  onChanged: (v) async {
                    if (v) {
                      final ok = await ref.read(biometricServiceProvider).authenticate();
                      if (!ok) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(s.biometricUnavailable)));
                        }
                        return;
                      }
                    }
                    await ref.read(preferencesProvider.notifier).setBiometricEnabled(v);
                  },
                );
              },
            ),
            const SizedBox(height: FvSpacing.x4),
            Text(s.notifications, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: FvSpacing.x2),
            Consumer(
              builder: (context, ref, _) {
                final n = ref.watch(notificationSettingsProvider);
                final notif = ref.read(notificationSettingsProvider.notifier);
                return Column(
                  children: [
                    _SwitchRow(
                      icon: Icons.notifications,
                      label: s.notifications,
                      value: n.enabled,
                      onChanged: (v) async {
                        await notif.setEnabled(v);
                        if (v) {
                          await ref.read(notificationServiceProvider).notifyBillDue(
                                'Finovault alerts are on',
                                DateTime.now().add(const Duration(days: 2)),
                              );
                        }
                      },
                    ),
                    const SizedBox(height: FvSpacing.x3),
                    _SwitchRow(
                      icon: Icons.receipt_long,
                      label: s.billReminders,
                      value: n.billReminders,
                      onChanged: (v) => notif.setBillReminders(v),
                    ),
                    const SizedBox(height: FvSpacing.x3),
                    _SwitchRow(
                      icon: Icons.account_balance_wallet,
                      label: s.lowBalanceAlert,
                      value: n.lowBalance,
                      onChanged: (v) => notif.setLowBalance(v),
                    ),
                  ],
                );
              },
            ),
            Text(s.backendUrl, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: FvSpacing.x2),
            const _BackendUrlTile(),
            const SizedBox(height: FvSpacing.x4),
          ],
        ),
      ),
    ),
  );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(s.logoutConfirmTitle),
        content: Text(s.logoutConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialog).pop(), child: Text(s.cancel)),
          TextButton(
            onPressed: () {
              Navigator.of(dialog).pop();
              ref.read(biometricSessionUnlockedProvider.notifier).state = false;
              ref.read(authProvider.notifier).logout();
            },
            child: Text(s.logout, style: const TextStyle(color: FvColors.error)),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.onTap, this.danger = false});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? FvColors.error : context.fvText;
    return FvCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: FvSpacing.x3),
      child: Semantics(
        button: true,
        label: label,
        child: Row(
          children: [
            Icon(icon, size: 20, color: danger ? FvColors.error : FvColors.primary),
            const SizedBox(width: FvSpacing.x3),
            Expanded(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color))),
            const ExcludeSemantics(child: Icon(Icons.chevron_right, size: 18)),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return FvCard(
      child: MergeSemantics(
        child: Row(
          children: [
            Icon(icon, size: 20, color: FvColors.primary),
            const SizedBox(width: FvSpacing.x3),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
            Switch(value: value, activeThumbColor: FvColors.primary, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class _ChoiceChip extends ConsumerWidget {
  const _ChoiceChip({required this.selected, required this.label, required this.onTap});

  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: Material(
        color: selected ? FvColors.wash : context.fvSurface,
        borderRadius: BorderRadius.circular(FvRadius.button),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(FvRadius.button),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(FvRadius.button),
              border: Border.all(color: selected ? FvColors.primary : context.fvBorder, width: selected ? 1.5 : 1),
            ),
            child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? FvColors.primary : context.fvText)),
          ),
        ),
      ),
    );
  }
}

class _BackendUrlTile extends ConsumerStatefulWidget {
  const _BackendUrlTile();

  @override
  ConsumerState<_BackendUrlTile> createState() => _BackendUrlTileState();
}

class _BackendUrlTileState extends ConsumerState<_BackendUrlTile> {
  final _controller = TextEditingController();
  bool _testing = false;
  String? _status;

  @override
  void initState() {
    super.initState();
    _controller.text = ref.read(apiBaseUrlProvider) ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _test() async {
    setState(() => _testing = true);
    final s = AppLocalizations.of(context);
    final url = _controller.text.trim();
    try {
      final api = HttpFinovaultApi(baseUrl: url.isEmpty ? 'http://invalid.invalid' : url);
      await api.getSession(null);
      if (mounted) setState(() => _status = s.connectionOk);
    } on FvApiException {
      if (mounted) setState(() => _status = s.connectionFailed);
    } catch (_) {
      if (mounted) setState(() => _status = s.connectionFailed);
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return FvCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: s.backendUrl,
              hintText: s.backendUrlHint,
              isDense: true,
              border: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: FvSpacing.x2),
          Wrap(
            spacing: FvSpacing.x3,
            runSpacing: FvSpacing.x2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton(
                onPressed: _testing
                    ? null
                    : () async {
                        await ref.read(apiBaseUrlProvider.notifier).set(_controller.text);
                        ref.invalidate(apiProvider);
                        if (mounted) setState(() => _status = null);
                      },
                child: Text(s.save),
              ),
              OutlinedButton(
                onPressed: _testing ? null : _test,
                child: _testing
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, semanticsLabel: 'Testing connection'),
                      )
                    : Text(s.testConnection),
              ),
              if (_status != null) ...[
                const SizedBox(width: FvSpacing.x3),
                Text(_status!,
                    style: TextStyle(fontSize: 13, color: _status == s.connectionOk ? FvColors.success : FvColors.error)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}


