import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/mock/api.dart';
import '../../core/mock/http_api.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../core/state/auth.dart';
import '../../core/state/biometric.dart';
import '../../core/state/notifications.dart';
import '../../core/state/preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';
import '../../widgets/fv_avatar.dart';
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

    return ListView(
      padding: const EdgeInsets.all(FvSpacing.x5),
      children: [
        FvCard(
          margin: const EdgeInsets.only(bottom: FvSpacing.x4),
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: context.fvText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: context.fvTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              StatusBadge(
                label: 'Free',
                foreground: context.fvPrimary,
                background: context.fvWash,
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
          icon: Icons.account_balance_outlined,
          label: s.linkedAccounts,
          onTap: () => openAccounts(context),
        ),
        _SectionTitle(s.profileSectionSecurity),
        _Row(
          icon: Icons.security_outlined,
          label: s.security,
          onTap: () => openSecurity(context),
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
        if (user?.primaryRole == PrimaryRole.entrepreneur ||
            user?.primaryRole == PrimaryRole.sme)
          _Row(
            icon: Icons.business_outlined,
            label: s.businessProfile,
            onTap: () => _openBusinessProfile(context, ref),
          ),
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
      backgroundColor: context.fvSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheet) => Padding(
        padding: const EdgeInsets.all(FvSpacing.x5),
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
                s.settings,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.fvText,
                ),
              ),
              const SizedBox(height: FvSpacing.x4),
              Text(
                s.language,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
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
              Text(
                s.appearance,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: FvSpacing.x2),
              Consumer(
                builder: (context, ref, _) {
                  final mode = ref.watch(preferencesProvider).themeMode;
                  return Row(
                    children: [
                      _ChoiceChip(
                        selected: mode == ThemeModePref.light,
                        label: s.themeLight,
                        onTap: () => ref
                            .read(preferencesProvider.notifier)
                            .setThemeMode(ThemeModePref.light),
                      ),
                      const SizedBox(width: FvSpacing.x2),
                      _ChoiceChip(
                        selected: mode == ThemeModePref.dark,
                        label: s.themeDark,
                        onTap: () => ref
                            .read(preferencesProvider.notifier)
                            .setThemeMode(ThemeModePref.dark),
                      ),
                      const SizedBox(width: FvSpacing.x2),
                      _ChoiceChip(
                        selected: mode == ThemeModePref.system,
                        label: s.themeSystem,
                        onTap: () => ref
                            .read(preferencesProvider.notifier)
                            .setThemeMode(ThemeModePref.system),
                      ),
                    ],
                  );
                },
              ),
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
                  fontWeight: FontWeight.w600,
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
                          await notif.setEnabled(v);
                          if (v) {
                            await ref
                                .read(notificationServiceProvider)
                                .notifyBillDue(
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
              Text(
                s.backendUrl,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: FvSpacing.x2),
              const _BackendUrlTile(),
              const SizedBox(height: FvSpacing.x4),
            ],
          ),
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

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(s.logoutConfirmTitle),
        content: Text(s.logoutConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialog).pop();
              ref.read(biometricSessionUnlockedProvider.notifier).state = false;
              ref.read(authProvider.notifier).logout();
            },
            child: Text(s.logout, style: TextStyle(color: context.fvError)),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FvSpacing.x1,
        FvSpacing.x1,
        FvSpacing.x1,
        FvSpacing.x2,
      ),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          color: context.fvTextSecondary,
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
    final color = danger ? context.fvError : context.fvText;
    return FvCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: FvSpacing.x3),
      child: Semantics(
        button: true,
        label: label,
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: danger ? context.fvError : context.fvPrimary,
            ),
            const SizedBox(width: FvSpacing.x3),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
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
            Icon(icon, size: 20, color: context.fvPrimary),
            const SizedBox(width: FvSpacing.x3),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
            Switch(
              value: value,
              activeThumbColor: context.fvPrimary,
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
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: Material(
        color: selected ? context.fvWash : context.fvSurface,
        borderRadius: BorderRadius.circular(FvRadius.button),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(FvRadius.button),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(FvRadius.button),
              border: Border.all(
                color: selected ? context.fvPrimary : context.fvBorder,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? context.fvPrimary : context.fvText,
              ),
            ),
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
      final api = HttpFinovaultApi(
        baseUrl: url.isEmpty ? 'http://invalid.invalid' : url,
      );
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
              FvButton(
                label: s.save,
                onPressed: _testing
                    ? null
                    : () async {
                        await ref
                            .read(apiBaseUrlProvider.notifier)
                            .set(_controller.text);
                        ref.invalidate(apiProvider);
                        if (mounted) setState(() => _status = null);
                      },
              ),
              FvButton(
                label: s.testConnection,
                variant: FvButtonVariant.secondary,
                loading: _testing,
                onPressed: _testing ? null : _test,
              ),
              if (_status != null) ...[
                const SizedBox(width: FvSpacing.x3),
                Text(
                  _status!,
                  style: TextStyle(
                    fontSize: 13,
                    color: _status == s.connectionOk
                        ? context.fvSuccess
                        : context.fvError,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
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
