import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/mock/api.dart';
import '../../core/mock/http_api.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../core/state/auth.dart';
import '../../core/state/biometric.dart';
import '../../core/state/notifications.dart';
import '../../core/state/preferences.dart';
import '../../core/state/student_vault.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';
import '../../widgets/fv_avatar.dart';
import '../../widgets/fv_alert_dialog.dart';
import '../../widgets/fv_notification.dart';
import '../../widgets/ui.dart';
import '../home_shell.dart';
import '../profile/change_password_screen.dart';
import '../profile/edit_profile_screen.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final s = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: FvColors.bg,
      appBar: AppBar(
        backgroundColor: FvColors.bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: FvColors.ink,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(FvSpacing.x5),
        children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: FvColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: FvColors.ink, width: 2),
            boxShadow: const [
              BoxShadow(
                color: FvColors.ink,
                offset: Offset(3, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              FvAvatar(
                avatarUrl: user?.avatarUrl,
                fullName: user?.fullName ?? 'A',
                radius: 26,
                onTap: () => pushScreen(context, const EditProfileScreen()),
                showEditBadge: true,
              ),
              const SizedBox(width: FvSpacing.x3),
              Expanded(
                child: GestureDetector(
                  onTap: () => pushScreen(context, const EditProfileScreen()),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? 'Welcome',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: FvColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: FvColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: FvColors.ink, width: 1.2),
                ),
                child: const Text(
                  'STUDENT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: Color(0xFF047857),
                  ),
                ),
              ),
            ],
          ),
        ),
        _SectionTitle(s.profileSectionAccount),
        _Row(
          icon: Icons.person_outline,
          label: s.editProfile,
          onTap: () => pushScreen(context, const EditProfileScreen()),
        ),

        _Row(
          icon: Icons.lock_outline,
          label: s.changePassword,
          onTap: () => pushScreen(context, const ChangePasswordScreen()),
        ),
        _SectionTitle(s.profileSectionPlan),
        _Row(
          icon: Icons.tune_outlined,
          label: s.settingsAndPlan,
          onTap: () => _openSettings(context, ref),
        ),

        const SizedBox(height: FvSpacing.x3),
        _Row(
          icon: Icons.logout_outlined,
          label: s.logout,
          danger: true,
          onTap: () => _confirmLogout(context, ref),
        ),
      ],
      ),
    );
  }

  void _openSettings(BuildContext context, WidgetRef ref) {
    final prefs = ref.read(preferencesProvider);
    final s = AppLocalizations.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheet) => Container(
        height: screenHeight * 0.55,
        decoration: const BoxDecoration(
          color: FvColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: FvColors.ink, width: 2.5),
            left: BorderSide(color: FvColors.ink, width: 2.5),
            right: BorderSide(color: FvColors.ink, width: 2.5),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(FvSpacing.x5, FvSpacing.x4, FvSpacing.x5, FvSpacing.x5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: FvColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: FvSpacing.x3),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  s.settingsAndPlan,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: FvColors.ink,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(sheet).pop(),
                  child: Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                      border: Border.all(color: FvColors.ink, width: 1.2),
                    ),
                    child: const Icon(Icons.close_rounded, size: 16, color: FvColors.ink),
                  ),
                ),
              ],
            ),
            const SizedBox(height: FvSpacing.x3),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.language,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: FvColors.ink,
                      ),
                    ),
                    const SizedBox(height: FvSpacing.x2),
                    Row(
                      children: [
                        _ChoiceChip(
                          selected: prefs.language == 'en',
                          label: 'English',
                          onTap: () => ref
                              .read(preferencesProvider.notifier)
                              .setLanguage('en'),
                        ),
                        const SizedBox(width: FvSpacing.x2),
                        _ChoiceChip(
                          selected: prefs.language == 'fr',
                          label: 'Français',
                          onTap: () => ref
                              .read(preferencesProvider.notifier)
                              .setLanguage('fr'),
                        ),
                      ],
                    ),

                    const SizedBox(height: FvSpacing.x4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Currency',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: FvColors.ink,
                          ),
                        ),
                        Consumer(
                          builder: (context, ref, _) {
                            final cur = ref.watch(preferencesProvider).currency;
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: FvColors.ink, width: 1.2),
                              ),
                              child: Text(
                                'ACTIVE: ' + cur,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                  color: FvColors.ink,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: FvSpacing.x2),
                    const _CurrencyDropdown(),
                    const SizedBox(height: FvSpacing.x4),
                    Consumer(
                      builder: (context, ref, _) {
                        final enabled = ref
                            .watch(preferencesProvider)
                            .biometricEnabled;
                        return _SwitchRow(
                          icon: Icons.fingerprint,
                          label: s.biometricUnlock,
                          value: enabled,
                          onChanged: (v) async {
                            if (v) {
                              final ok = await ref
                                  .read(biometricServiceProvider)
                                  .authenticate();
                              if (!ok) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(s.biometricUnavailable)),
                                  );
                                }
                                return;
                              }
                            }
                            await ref
                                .read(preferencesProvider.notifier)
                                .setBiometricEnabled(v);
                          },
                        );
                      },
                    ),
                    const SizedBox(height: FvSpacing.x4),
                    Text(
                      s.notifications,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: FvColors.ink,
                      ),
                    ),
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
                                if (v) {
                                  await ref.read(notificationServiceProvider).requestPermission();
                                }
                                await notif.setEnabled(v);
                                if (v) {
                                  try {
                                    await ref
                                        .read(notificationServiceProvider)
                                        .notifyBillDue(
                                          'Finovault alerts are on',
                                          DateTime.now().add(const Duration(days: 2)),
                                        );
                                  } catch (_) {}
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

                    const SizedBox(height: FvSpacing.x4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openBusinessProfile(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.fvSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const _BusinessProfileSheet(),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final s = AppLocalizations.of(context);
    final confirmed = await FvAlertDialog.showConfirm(
      context,
      title: s.logoutConfirmTitle,
      message: s.logoutConfirmBody,
      confirmLabel: s.logout.toUpperCase(),
      cancelLabel: s.cancel.toUpperCase(),
      severity: FvAlertSeverity.danger,
    );
    if (confirmed) {
      ref.read(biometricSessionUnlockedProvider.notifier).state = false;
      await ref.read(authProvider.notifier).logout();
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
          color: FvColors.ink,
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: FvColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: danger ? const Color(0xFFEF4444) : FvColors.ink,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: FvColors.ink,
            offset: Offset(2.5, 2.5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Semantics(
            button: true,
            label: label,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: danger ? const Color(0xFFFEE2E2) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: danger ? const Color(0xFFEF4444) : FvColors.ink,
                      width: 1.2,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: danger ? const Color(0xFFEF4444) : FvColors.ink,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: danger ? const Color(0xFFEF4444) : FvColors.ink,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: danger ? const Color(0xFFEF4444) : FvColors.ink,
                ),
              ],
            ),
          ),
          ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: FvColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: FvColors.ink, width: 1.5),
        boxShadow: const [
          BoxShadow(color: FvColors.ink, offset: Offset(2, 2), blurRadius: 0),
        ],
      ),
      child: MergeSemantics(
        child: Row(
          children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: FvColors.ink, width: 1.2),
            ),
            child: Icon(icon, size: 18, color: FvColors.ink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: FvColors.ink,
              ),
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: FvColors.ink,
            activeThumbColor: Colors.white,
            onChanged: onChanged,
          ),
        ],
        ),
      ),
    );
  }
}

class _ChoiceChip extends ConsumerWidget {
  const _ChoiceChip({
    required this.selected,
    required this.label,
    required this.onTap,
    this.expanded = true,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;
  final bool expanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chip = Material(
      color: selected ? FvColors.ink : FvColors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: expanded ? 0 : 16,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: FvColors.ink,
              width: selected ? 2 : 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : FvColors.ink,
            ),
          ),
        ),
      ),
    );

    return expanded ? Expanded(child: chip) : chip;
  }
}

const _employeeOptions = [
  0,
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9,
  10,
  15,
  20,
  30,
  50,
  75,
  100,
  200,
  500,
];
const _revenueOptions = [
  'pre_revenue',
  'under_1m',
  '1m_5m',
  '5m_20m',
  '20m_100m',
  '100m_plus',
];
const _industryOptions = [
  'technology',
  'retail',
  'manufacturing',
  'services',
  'agriculture',
  'hospitality',
  'construction',
  'healthcare',
  'education',
  'finance',
  'transport_logistics',
  'creative_media',
  'real_estate',
  'other',
];
const _termsOptions = [15, 30, 45, 60, 90];

/// Editable business profile bottom sheet for Entrepreneur/SME.
class _BusinessProfileSheet extends ConsumerStatefulWidget {
  const _BusinessProfileSheet();

  @override
  ConsumerState<_BusinessProfileSheet> createState() =>
      _BusinessProfileSheetState();
}

class _BusinessProfileSheetState extends ConsumerState<_BusinessProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  final _monthlyPayrollController = TextEditingController();
  final _avgInvoiceValueController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _keySuppliersController = TextEditingController();
  final _keyClientsController = TextEditingController();

  int? _employeeCount;
  String? _annualRevenueRange;
  String? _industry;
  BusinessStage? _businessStage;
  int? _paymentTermsDays;

  bool get _isSme =>
      (ref.read(currentUserProvider)?.primaryRole ?? PrimaryRole.individual) ==
      PrimaryRole.sme;

  @override
  void initState() {
    super.initState();
    final bp = ref.read(currentUserProvider)?.businessProfile;
    if (bp != null) {
      _employeeCount = bp.employeeCount;
      _annualRevenueRange = bp.annualRevenueRange;
      _industry = bp.industry;
      _businessStage = bp.businessStage;
      _monthlyPayrollController.text = bp.monthlyPayroll?.toString() ?? '';
      _avgInvoiceValueController.text = bp.avgInvoiceValue?.toString() ?? '';
      _paymentTermsDays = bp.paymentTermsDays;
      _taxIdController.text = bp.taxId ?? '';
      _registrationNumberController.text = bp.registrationNumber ?? '';
      _keySuppliersController.text = bp.keySuppliers.join(', ');
      _keyClientsController.text = bp.keyClients.join(', ');
    }
  }

  @override
  void dispose() {
    _monthlyPayrollController.dispose();
    _avgInvoiceValueController.dispose();
    _taxIdController.dispose();
    _registrationNumberController.dispose();
    _keySuppliersController.dispose();
    _keyClientsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final s = AppLocalizations.of(context);
    setState(() => _saving = true);

    final profile = BusinessProfile(
      employeeCount: _employeeCount,
      annualRevenueRange: _annualRevenueRange,
      industry: _industry,
      businessStage: _businessStage,
      taxId: _isSme ? _taxIdController.text.trim() : null,
      registrationNumber: _isSme
          ? _registrationNumberController.text.trim()
          : null,
      monthlyPayroll: _monthlyPayrollController.text.isEmpty
          ? null
          : double.tryParse(_monthlyPayrollController.text.replaceAll(',', '')),
      avgInvoiceValue: _avgInvoiceValueController.text.isEmpty
          ? null
          : double.tryParse(
              _avgInvoiceValueController.text.replaceAll(',', ''),
            ),
      paymentTermsDays: _paymentTermsDays,
      keySuppliers: _splitList(_keySuppliersController.text),
      keyClients: _splitList(_keyClientsController.text),
    );

    if (_isSme && !profile.isSmeComplete) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.businessDetailsSmeRequired),
          backgroundColor: FvColors.error,
        ),
      );
      return;
    }

    try {
      final token = ref.read(kvStoreProvider).getString(sessionKey);
      final updated = await ref
          .read(apiProvider)
          .saveBusinessProfile(token, profile);
      ref.read(authProvider.notifier).setUser(updated);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(s.profileSaved)));
      }
    } on FvApiException catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: FvColors.error),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.connectionFailed),
            backgroundColor: FvColors.error,
          ),
        );
      }
    }
  }

  List<String> _splitList(String raw) =>
      raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: FvSpacing.x5,
          right: FvSpacing.x5,
          top: FvSpacing.x4,
          bottom: MediaQuery.of(context).viewInsets.bottom + FvSpacing.x5,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.fvBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: FvSpacing.x4),
              Text(
                s.businessProfile,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.fvText,
                ),
              ),
              const SizedBox(height: FvSpacing.x4),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label(s.employeeCount),
                    DropdownButtonFormField<int>(
                      initialValue: _employeeCount,
                      decoration: _inputDecoration(s.employeeCount),
                      items: _employeeOptions
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e == 0 ? s.employeeCountZero : '$e'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _employeeCount = v),
                      validator: (v) =>
                          v == null ? s.employeeCountRequired : null,
                    ),
                    const SizedBox(height: FvSpacing.x4),
                    _Label(s.annualRevenue),
                    DropdownButtonFormField<String>(
                      initialValue: _annualRevenueRange,
                      decoration: _inputDecoration(s.annualRevenue),
                      items: _revenueOptions
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(_revenueLabel(s, e)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _annualRevenueRange = v),
                      validator: (v) =>
                          v == null ? s.annualRevenueRequired : null,
                    ),
                    const SizedBox(height: FvSpacing.x4),
                    _Label(s.industry),
                    DropdownButtonFormField<String>(
                      initialValue: _industry,
                      decoration: _inputDecoration(s.industry),
                      items: _industryOptions
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(_industryLabel(s, e)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _industry = v),
                      validator: (v) => v == null ? s.industryRequired : null,
                    ),
                    const SizedBox(height: FvSpacing.x4),
                    _Label(s.businessStage),
                    DropdownButtonFormField<BusinessStage>(
                      initialValue: _businessStage,
                      decoration: _inputDecoration(s.businessStage),
                      items: BusinessStage.values
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.label),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _businessStage = v),
                      validator: (v) =>
                          v == null ? s.businessStageRequired : null,
                    ),
                    const SizedBox(height: FvSpacing.x4),
                    _Label(s.monthlyPayroll),
                    FvTextField(
                      label: s.monthlyPayroll,
                      controller: _monthlyPayrollController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      hint: s.monthlyPayrollHint,
                    ),
                    if (_isSme) ...[
                      const SizedBox(height: FvSpacing.x4),
                      Text(
                        s.smeDetailsSection,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: context.fvText,
                        ),
                      ),
                      const SizedBox(height: FvSpacing.x3),
                      _Label(s.taxId),
                      FvTextField(
                        label: s.taxId,
                        controller: _taxIdController,
                        hint: s.taxIdHint,
                      ),
                      const SizedBox(height: FvSpacing.x4),
                      _Label(s.registrationNumber),
                      FvTextField(
                        label: s.registrationNumber,
                        controller: _registrationNumberController,
                        hint: s.registrationNumberHint,
                      ),
                      const SizedBox(height: FvSpacing.x4),
                      _Label(s.avgInvoiceValue),
                      FvTextField(
                        label: s.avgInvoiceValue,
                        controller: _avgInvoiceValueController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        hint: s.avgInvoiceValueHint,
                      ),
                      const SizedBox(height: FvSpacing.x4),
                      _Label(s.paymentTerms),
                      DropdownButtonFormField<int>(
                        initialValue: _paymentTermsDays,
                        decoration: _inputDecoration(s.paymentTerms),
                        items: _termsOptions
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text('$e ${s.days}'),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _paymentTermsDays = v),
                      ),
                      const SizedBox(height: FvSpacing.x4),
                      _Label(s.keySuppliers),
                      FvTextField(
                        label: s.keySuppliers,
                        controller: _keySuppliersController,
                        hint: s.keySuppliersHint,
                      ),
                      const SizedBox(height: FvSpacing.x4),
                      _Label(s.keyClients),
                      FvTextField(
                        label: s.keyClients,
                        controller: _keyClientsController,
                        hint: s.keyClientsHint,
                      ),
                    ],
                    const SizedBox(height: FvSpacing.x5),
                    SizedBox(
                      width: double.infinity,
                      child: FvButton(
                        label: s.save,
                        loading: _saving,
                        onPressed: _saving ? null : _save,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    hintText: label,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(FvRadius.input),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: FvSpacing.x4,
      vertical: FvSpacing.x3,
    ),
  );

  String _revenueLabel(AppLocalizations s, String key) => switch (key) {
    'pre_revenue' => s.revenuePreRevenue,
    'under_1m' => s.revenueUnder1m,
    '1m_5m' => s.revenue1m5m,
    '5m_20m' => s.revenue5m20m,
    '20m_100m' => s.revenue20m100m,
    '100m_plus' => s.revenue100mPlus,
    _ => key,
  };

  String _industryLabel(AppLocalizations s, String key) => switch (key) {
    'technology' => s.industryTechnology,
    'retail' => s.industryRetail,
    'manufacturing' => s.industryManufacturing,
    'services' => s.industryServices,
    'agriculture' => s.industryAgriculture,
    'hospitality' => s.industryHospitality,
    'construction' => s.industryConstruction,
    'healthcare' => s.industryHealthcare,
    'education' => s.industryEducation,
    'finance' => s.industryFinance,
    'transport_logistics' => s.industryTransportLogistics,
    'creative_media' => s.industryCreativeMedia,
    'real_estate' => s.industryRealEstate,
    'other' => s.industryOther,
    _ => key,
  };
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: FvSpacing.x2),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: context.fvText,
      ),
    ),
  );
}

class CurrencyOption {
  final String code;
  final String symbol;
  final String name;

  const CurrencyOption({
    required this.code,
    required this.symbol,
    required this.name,
  });
}

const appCurrencies = [
  CurrencyOption(code: 'USD', symbol: r'$', name: 'US Dollar'),
  CurrencyOption(code: 'EUR', symbol: '€', name: 'Euro'),
  CurrencyOption(code: 'GBP', symbol: '£', name: 'British Pound'),
  CurrencyOption(code: 'NGN', symbol: '₦', name: 'Nigerian Naira'),
  CurrencyOption(code: 'MUR', symbol: 'Rs', name: 'Mauritian Rupee'),
  CurrencyOption(code: 'ZAR', symbol: 'R', name: 'South African Rand'),
  CurrencyOption(code: 'KES', symbol: 'KSh', name: 'Kenyan Shilling'),
  CurrencyOption(code: 'GHS', symbol: 'GH₵', name: 'Ghanaian Cedi'),
  CurrencyOption(code: 'CAD', symbol: r'$', name: 'Canadian Dollar'),
  CurrencyOption(code: 'AUD', symbol: r'$', name: 'Australian Dollar'),
  CurrencyOption(code: 'INR', symbol: '₹', name: 'Indian Rupee'),
  CurrencyOption(code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
  CurrencyOption(code: 'CNY', symbol: '¥', name: 'Chinese Yuan'),
  CurrencyOption(code: 'AED', symbol: 'AED', name: 'UAE Dirham'),
  CurrencyOption(code: 'EGP', symbol: 'E£', name: 'Egyptian Pound'),
  CurrencyOption(code: 'RWF', symbol: 'FRw', name: 'Rwandan Franc'),
  CurrencyOption(code: 'TZS', symbol: 'TSh', name: 'Tanzanian Shilling'),
  CurrencyOption(code: 'UGX', symbol: 'USh', name: 'Ugandan Shilling'),
  CurrencyOption(code: 'XOF', symbol: 'CFA', name: 'West African CFA'),
  CurrencyOption(code: 'XAF', symbol: 'FCFA', name: 'Central African CFA'),
];

class _CurrencyDropdown extends ConsumerWidget {
  const _CurrencyDropdown();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCurrency = ref.watch(preferencesProvider).currency;
    final selectedOption = appCurrencies.firstWhere(
      (c) => c.code.toUpperCase() == currentCurrency.toUpperCase(),
      orElse: () => appCurrencies.first,
    );

    return Container(
      decoration: BoxDecoration(
        color: FvColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: FvColors.ink, width: 2),
        boxShadow: const [
          BoxShadow(
            color: FvColors.ink,
            offset: Offset(2.5, 2.5),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedOption.code,
          isExpanded: true,
          menuMaxHeight: 280,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: FvColors.ink,
            size: 24,
          ),
          dropdownColor: FvColors.surface,
          borderRadius: BorderRadius.circular(14),
          elevation: 4,
          items: appCurrencies.map((c) {
            return DropdownMenuItem<String>(
              value: c.code,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: FvColors.ink, width: 1.2),
                    ),
                    child: Text(
                      c.symbol,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: FvColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    c.code,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: FvColors.ink,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '•  ${c.name}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: FvColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (newCode) {
            if (newCode != null && newCode != currentCurrency) {
              HapticFeedback.selectionClick();
              ref.read(preferencesProvider.notifier).setCurrency(newCode);
              ref.read(studentVaultProvider.notifier).setCurrency(newCode);
              FvNotification.show(
                context,
                message: 'Currency updated to ' + newCode,
                type: FvNotificationType.success,
              );
            }
          },
        ),
      ),
    );
  }
}
