import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/auth.dart';
import '../../core/state/preferences.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';
import '../home_shell.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

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
        _Row(icon: Icons.security_outlined, label: 'Security', onTap: () => openSecurity(context)),
        _Row(icon: Icons.account_balance_outlined, label: 'Linked accounts', onTap: () => openAccounts(context)),
        _Row(icon: Icons.tune_outlined, label: 'Settings & plan', onTap: () => _openSettings(context, ref)),
        const SizedBox(height: FvSpacing.x3),
        _Row(
          icon: Icons.logout_outlined,
          label: 'Log out',
          danger: true,
          onTap: () => _confirmLogout(context, ref),
        ),
      ],
    );
  }

  void _openSettings(BuildContext context, WidgetRef ref) {
    final prefs = ref.read(preferencesProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.fvIsDark ? FvColors.bgDark : FvColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (sheet) => Padding(
        padding: const EdgeInsets.all(FvSpacing.x5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: context.fvBorder, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: FvSpacing.x4),
            Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.fvText)),
            const SizedBox(height: FvSpacing.x4),
            const Text('Language', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: FvSpacing.x2),
            Row(
              children: [
                _ChoiceChip(selected: prefs.language == 'en', label: 'English', onTap: () => ref.read(preferencesProvider.notifier).setLanguage('en')),
                const SizedBox(width: FvSpacing.x2),
                _ChoiceChip(selected: prefs.language == 'fr', label: 'Français', onTap: () => ref.read(preferencesProvider.notifier).setLanguage('fr')),
              ],
            ),
            const SizedBox(height: FvSpacing.x4),
            const Text('Appearance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: FvSpacing.x2),
            Consumer(
              builder: (context, ref, _) {
                final mode = ref.watch(preferencesProvider).themeMode;
                return Row(
                  children: [
                    _ChoiceChip(selected: mode == ThemeModePref.light, label: 'Light', onTap: () => ref.read(preferencesProvider.notifier).setThemeMode(ThemeModePref.light)),
                    const SizedBox(width: FvSpacing.x2),
                    _ChoiceChip(selected: mode == ThemeModePref.dark, label: 'Dark', onTap: () => ref.read(preferencesProvider.notifier).setThemeMode(ThemeModePref.dark)),
                    const SizedBox(width: FvSpacing.x2),
                    _ChoiceChip(selected: mode == ThemeModePref.system, label: 'System', onTap: () => ref.read(preferencesProvider.notifier).setThemeMode(ThemeModePref.system)),
                  ],
                );
              },
            ),
            const SizedBox(height: FvSpacing.x4),
            FvCard(
              child: Row(
                children: [
                  const Icon(Icons.fingerprint, size: 20, color: FvColors.primary),
                  const SizedBox(width: FvSpacing.x3),
                  const Expanded(child: Text('Biometric unlock', style: TextStyle(fontSize: 14))),
                  const StatusBadge(label: 'Soon', foreground: FvColors.textSecondary, background: FvColors.wash),
                ],
              ),
            ),
            const SizedBox(height: FvSpacing.x4),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to access your vault.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialog).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(dialog).pop();
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('Log out', style: TextStyle(color: FvColors.error)),
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
      child: Row(
        children: [
          Icon(icon, size: 20, color: danger ? FvColors.error : FvColors.primary),
          const SizedBox(width: FvSpacing.x3),
          Expanded(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color))),
          const Icon(Icons.chevron_right, size: 18),
        ],
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


