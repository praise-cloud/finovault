import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/banking/connector.dart';
import '../../core/mock/api.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../core/state/auth.dart';
import '../../core/state/money.dart';
import '../../core/state/onboarding.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';

/// Onboarding screen for linking bank / mobile-money accounts.
///
/// Flow per institution:
///  1. If privacy policy not accepted → privacy bottom sheet
///  2. Account number entry bottom sheet
///  3. `linkBankAccount` RPC → success with imported count
class LinkAccountsScreen extends ConsumerStatefulWidget {
  const LinkAccountsScreen({super.key});

  @override
  ConsumerState<LinkAccountsScreen> createState() => _LinkAccountsScreenState();
}

class _LinkAccountsScreenState extends ConsumerState<LinkAccountsScreen> {
  final _bankLinked = ValueNotifier<bool>(false);
  final _momoLinked = ValueNotifier<bool>(false);
  final _bankImported = ValueNotifier<int>(0);
  final _momoImported = ValueNotifier<int>(0);
  bool _finishing = false;

  @override
  void dispose() {
    _bankLinked.dispose();
    _momoLinked.dispose();
    _bankImported.dispose();
    _momoImported.dispose();
    super.dispose();
  }

  Future<void> _onLinkTap({
    required String institution,
    required String displayName,
    required ValueNotifier<bool> linkedNotifier,
    required ValueNotifier<int> importedNotifier,
    String? bankCode,
  }) async {
    final api = ref.read(apiProvider);
    final token = ref.read(kvStoreProvider).getString(sessionKey);
    final auth = ref.read(authProvider);
    final isNg = (auth.user?.country == 'NG') ||
        (auth.user?.preferredCurrency == 'NGN');

    // 1. Privacy policy gate — only if user hasn't accepted yet.
    final profile = await api.getSession(token);
    if (profile != null && !profile.hasAcceptedPrivacyPolicy) {
      if (!mounted) return;
      final accepted = await _showPrivacySheet();
      if (!accepted) return;
    }

    // 2. Account number + holder name entry (live NUBAN resolution in Nigeria).
    if (!mounted) return;
    final cert = await _showAccountNumberSheet(
      institution: institution,
      displayName: displayName,
      isNg: isNg,
      initialBankCode: bankCode,
      verify: (inst, code, number, holderName) async {
        return api.verifyAccount(
          token,
          institution: inst,
          identifier: number,
          holderName: holderName,
          bankCode: code,
        );
      },
    );
    if (cert == null) return;

    // 3. Link.
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).linkingLoading)),
    );
    try {
      final result = await api.linkBankAccount(
        token,
        institution: cert.institution,
        accountNumber: cert.number,
        holderName: cert.holderName,
      );
      ref.invalidate(accountsProvider);
      linkedNotifier.value = true;
      importedNotifier.value = result.imported;
    } on FvApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  // ── Bottom sheets ──────────────────────────────────────────────────────

  Future<bool> _showPrivacySheet() async {
    final s = AppLocalizations.of(context);
    bool accepted = false;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.fvSurface,
      // ponytail: FvRadius has no sheet token — 16 matches card/input
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _PrivacySheet(
        s: s,
        onAccept: () async {
          final api = ref.read(apiProvider);
          final token = ref.read(kvStoreProvider).getString(sessionKey);
          await api.acceptPrivacyPolicy(token);
          accepted = true;
          if (ctx.mounted) Navigator.pop(ctx);
        },
      ),
    );
    return accepted;
  }

  Future<({String institution, String number, String holderName, String? bankCode})?>
      _showAccountNumberSheet({
    required String institution,
    required String displayName,
    required bool isNg,
    String? initialBankCode,
    required Future<AccountVerification> Function(
      String institution,
      String? bankCode,
      String number,
      String holderName,
    ) verify,
  }) async {
    final s = AppLocalizations.of(context);
    ({String institution, String number, String holderName, String? bankCode})? result;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.fvSurface,
      // ponytail: same 16px radius for both bottom sheets
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _AccountNumberSheet(
        s: s,
        institution: institution,
        displayName: displayName,
        isNg: isNg,
        initialBankCode: initialBankCode,
        verify: verify,
        onSubmit: (inst, number, holderName, bankCode) {
          result = (
            institution: inst,
            number: number,
            holderName: holderName,
            bankCode: bankCode,
          );
          if (ctx.mounted) Navigator.pop(ctx);
        },
      ),
    );
    return result;
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);

    final auth = ref.watch(authProvider);
    final isNg =
        (auth.user?.country == 'NG') ||
        (auth.user?.preferredCurrency == 'NGN');

    return Scaffold(
      body: Container(
        decoration: context.fvOnboardingDecoration,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(FvSpacing.x6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                OnboardingHeader(
                  onBack: () => ref.read(onboardingProvider.notifier).back(),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(top: FvSpacing.x8),
                    children: <Widget>[
                      Text(
                        s.linkAccounts,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: context.fvText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.linkSubtitle,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: context.fvTextSecondary,
                        ),
                      ),
                      const SizedBox(height: FvSpacing.x6),
                      _LinkCard(
                        icon: Icons.account_balance_outlined,
                        title: s.bankAccount,
                        subtitle: isNg
                            ? 'GTBank, Access, Zenith, First Bank, Kuda'
                            : 'MCB, SBM, Bank One, Maubank',
                        institution: isNg ? 'GTBank' : 'MCB',
                        typeLabel: s.linkAccountTypeBank,
                        linkedNotifier: _bankLinked,
                        importedNotifier: _bankImported,
                        onTap: () => _onLinkTap(
                          institution: isNg ? 'GTBank' : 'MCB',
                          displayName: s.bankAccount,
                          linkedNotifier: _bankLinked,
                          importedNotifier: _bankImported,
                          bankCode: isNg ? '058' : null,
                        ),
                      ),
                      const SizedBox(height: FvSpacing.x3),
                      _LinkCard(
                        icon: Icons.smartphone_outlined,
                        title: isNg ? 'Fintech & Mobile Wallet' : s.mobileMoney,
                        subtitle: isNg
                            ? 'OPay, PalmPay, Moniepoint'
                            : 'Juice, my.t money, Emtel Money',
                        institution: isNg ? 'OPay' : 'Juice',
                        typeLabel: s.linkAccountTypeMobile,
                        linkedNotifier: _momoLinked,
                        importedNotifier: _momoImported,
                        onTap: () => _onLinkTap(
                          institution: isNg ? 'OPay' : 'Juice',
                          displayName:
                              isNg ? 'Fintech Wallet' : s.mobileMoney,
                          linkedNotifier: _momoLinked,
                          importedNotifier: _momoImported,
                          bankCode: isNg ? '999992' : null,
                        ),
                      ),
                    ],
                  ),
                ),
                FvButton(
                  label: s.finish,
                  variant: FvButtonVariant.success,
                  onPressed: _finishing ? null : _finish,
                  loading: _finishing,
                ),
                const SizedBox(height: FvSpacing.x3),
                Center(
                  child: TextButton(
                    onPressed: _finishing ? null : _finish,
                    child: Text(
                      s.linkSkip,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: context.fvTextSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _finish() async {
    setState(() => _finishing = true);
    await ref.read(onboardingProvider.notifier).complete();
  }
}

// ── Privacy Policy Bottom Sheet ────────────────────────────────────────────────

class _PrivacySheet extends StatefulWidget {
  const _PrivacySheet({required this.s, required this.onAccept});
  final AppLocalizations s;
  final Future<void> Function() onAccept;

  @override
  State<_PrivacySheet> createState() => _PrivacySheetState();
}

class _PrivacySheetState extends State<_PrivacySheet> {
  bool _checked = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: FvSpacing.x6,
        right: FvSpacing.x6,
        top: FvSpacing.x6,
        bottom: MediaQuery.of(context).viewInsets.bottom + FvSpacing.x6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.fvBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: FvSpacing.x4),
          Text(
            widget.s.linkPrivacyTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: context.fvText,
            ),
          ),
          const SizedBox(height: FvSpacing.x3),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.35,
            ),
            child: SingleChildScrollView(
              child: Text(
                widget.s.linkPrivacyBody,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: context.fvTextSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: FvSpacing.x4),
          Row(
            children: <Widget>[
              Checkbox(
                value: _checked,
                onChanged: _loading
                    ? null
                    : (v) => setState(() => _checked = v ?? false),
                activeColor: FvColors.primary,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _loading
                      ? null
                      : () => setState(() => _checked = !_checked),
                  child: Text(
                    widget.s.linkPrivacyAccept,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: context.fvText,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FvSpacing.x3),
          FvButton(
            label: widget.s.linkPrivacyButton,
            onPressed: _checked && !_loading ? () => _accept() : null,
            loading: _loading,
          ),
        ],
      ),
    );
  }

  Future<void> _accept() async {
    setState(() => _loading = true);
    await widget.onAccept();
    if (mounted) setState(() => _loading = false);
  }
}

// ── Account Number Bottom Sheet ────────────────────────────────────────────────

class _AccountNumberSheet extends ConsumerStatefulWidget {
  const _AccountNumberSheet({
    required this.s,
    required this.institution,
    required this.displayName,
    required this.isNg,
    required this.verify,
    required this.onSubmit,
    this.initialBankCode,
  });

  final AppLocalizations s;
  final String institution;
  final String displayName;
  final bool isNg;
  final String? initialBankCode;
  final Future<AccountVerification> Function(
    String institution,
    String? bankCode,
    String number,
    String holderName,
  ) verify;
  final void Function(
    String institution,
    String number,
    String holderName,
    String? bankCode,
  ) onSubmit;

  @override
  ConsumerState<_AccountNumberSheet> createState() => _AccountNumberSheetState();
}

class _AccountNumberSheetState extends ConsumerState<_AccountNumberSheet> {
  final _controller = TextEditingController();
  final _holder = TextEditingController();
  String? _error;
  String? _holderError;
  bool _verifying = false;
  bool _resolving = false;
  String? _resolvedName;
  String? _resolveError;
  String? _lastResolvedNumber;

  late String _currentInstitution;
  String? _currentBankCode;
  late bool _isBank;
  List<Institution> _allBanks = const [];

  static final _bankInstitutions = [
    'MCB', 'SBM', 'Bank One', 'Maubank',
    'GTBank', 'Access Bank', 'Zenith Bank', 'First Bank', 'UBA', 'Kuda Bank', 'Moniepoint',
  ];
  static final _bankPattern = RegExp(r'^\d{8,16}$');
  static final _mobilePattern = RegExp(r'^[5-7]\d{4,7}$');
  static final _nigerianNubanPattern = RegExp(r'^\d{10}$');
  static final _nigerianWalletPattern = RegExp(r'^(\+?234|0)?[789][01]\d{8}$|^\d{10,11}$');

  static final Map<String, String> _cbnCodeMap = {
    'gtbank': '058',
    'access': '044',
    'zenith': '057',
    'first bank': '011',
    'firstbank': '011',
    'uba': '033',
    'kuda': '50211',
    'moniepoint': '50515',
    'opay': '999992',
    'palmpay': '999991',
    'stanbic': '221',
    'fidelity': '070',
    'sterling': '232',
    'union': '032',
    'wema': '035',
    'fcmb': '214',
    'ecobank': '050',
  };

  static String? _lookupCbnCode(String name) {
    final lower = name.toLowerCase();
    for (final entry in _cbnCodeMap.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _currentInstitution = widget.institution;
    _currentBankCode = widget.initialBankCode ?? _lookupCbnCode(widget.institution);
    _isBank = _bankInstitutions.contains(_currentInstitution) ||
        (!_currentInstitution.toLowerCase().contains('pay') &&
            !_currentInstitution.toLowerCase().contains('money') &&
            !_currentInstitution.toLowerCase().contains('juice'));

    if (widget.isNg) {
      _controller.addListener(_onAccountInputChanged);
      _loadBanks();
    }
  }

  @override
  void dispose() {
    if (widget.isNg) {
      _controller.removeListener(_onAccountInputChanged);
    }
    _controller.dispose();
    _holder.dispose();
    super.dispose();
  }

  Future<void> _loadBanks() async {
    try {
      final connector = ref.read(bankConnectorProvider);
      final banks = await connector.institutions(country: 'NG');
      if (mounted) {
        setState(() {
          _allBanks = banks;
          if (_currentBankCode == null) {
            final match = banks.firstWhere(
              (b) => b.name.toLowerCase() == _currentInstitution.toLowerCase(),
              orElse: () => banks.first,
            );
            _currentBankCode = match.code;
          }
        });
      }
    } catch (_) {}
  }

  void _onAccountInputChanged() {
    if (!widget.isNg) return;
    final text = _controller.text.trim();
    if (text.length == 10 && text != _lastResolvedNumber) {
      _resolveNuban(text);
    } else if (text.length < 10) {
      if (_resolvedName != null || _resolveError != null) {
        setState(() {
          _resolvedName = null;
          _resolveError = null;
        });
      }
    }
  }

  Future<void> _resolveNuban(String number) async {
    _lastResolvedNumber = number;
    setState(() {
      _resolving = true;
      _resolveError = null;
      _resolvedName = null;
    });

    try {
      final check = await widget.verify(
        _currentInstitution,
        _currentBankCode,
        number,
        '', // Empty holderName triggers auto-resolution
      );
      if (!mounted) return;
      if (check.exists && check.holderName != null && check.holderName!.isNotEmpty) {
        setState(() {
          _resolvedName = check.holderName;
          _holder.text = check.holderName!;
          _holderError = null;
          _error = null;
          _resolving = false;
        });
      } else {
        setState(() {
          _resolveError = 'Could not resolve account with $_currentInstitution. Please check the 10-digit number.';
          _resolving = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _resolveError = 'Verification unavailable: ${e.toString()}';
        _resolving = false;
      });
    }
  }

  String? _validate(String value) {
    final s = widget.s;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return s.linkAccountValidationEmpty;
    if (widget.isNg) {
      if (_isBank && !_nigerianNubanPattern.hasMatch(trimmed)) {
        return 'Nigerian bank account number (NUBAN) must be 10 digits.';
      }
      if (!_isBank && !_nigerianWalletPattern.hasMatch(trimmed)) {
        return 'Nigerian wallet number must be 10–11 digits.';
      }
      return null;
    }
    if (_isBank && !_bankPattern.hasMatch(trimmed)) {
      return s.linkAccountValidationBank;
    }
    if (!_isBank && !_mobilePattern.hasMatch(trimmed)) {
      return s.linkAccountValidationMobile;
    }
    return null;
  }

  Future<void> _submit() async {
    final s = widget.s;
    final error = _validate(_controller.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }

    final trimmedNum = _controller.text.trim();
    String holder = _holder.text.trim();

    // In Nigeria, if name hasn't auto-resolved yet, resolve it now
    if (widget.isNg && _resolvedName == null) {
      setState(() => _verifying = true);
      try {
        final check = await widget.verify(
          _currentInstitution,
          _currentBankCode,
          trimmedNum,
          holder,
        );
        if (check.exists && check.holderName != null && check.holderName!.isNotEmpty) {
          holder = check.holderName!;
          _holder.text = holder;
          _resolvedName = holder;
        } else if (!check.verified) {
          if (!mounted) return;
          setState(() {
            _verifying = false;
            _holderError = check.exists ? s.verifyMismatch : s.verifyNotFound;
          });
          return;
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _verifying = false;
          _holderError = e.toString();
        });
        return;
      }
    }

    if (holder.isEmpty) {
      setState(() {
        _holderError = s.linkHolderEmpty;
        _verifying = false;
      });
      return;
    }

    // For Mauritius accounts, check KYC verification
    if (!widget.isNg) {
      setState(() {
        _error = null;
        _holderError = null;
        _verifying = true;
      });
      try {
        final check = await widget.verify(
          _currentInstitution,
          _currentBankCode,
          trimmedNum,
          holder,
        );
        if (!mounted) return;
        if (!check.verified) {
          setState(() {
            _holderError = check.exists ? s.verifyMismatch : s.verifyNotFound;
            _verifying = false;
          });
          return;
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _holderError = e.toString();
          _verifying = false;
        });
        return;
      }
    }

    widget.onSubmit(
      _currentInstitution,
      trimmedNum,
      holder,
      _currentBankCode,
    );
  }

  void _openBankPicker() {
    showModalBottomSheet<Institution>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.fvSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _BankPickerSheet(
        banks: _allBanks,
        selectedCode: _currentBankCode,
        selectedName: _currentInstitution,
        onSelect: (inst) => Navigator.pop(ctx, inst),
      ),
    ).then((picked) {
      if (picked != null && mounted) {
        setState(() {
          _currentInstitution = picked.name;
          _currentBankCode = picked.code;
          _isBank = picked.type == AccountType.bank;
          _lastResolvedNumber = null;
        });
        if (_controller.text.trim().length == 10) {
          _resolveNuban(_controller.text.trim());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;

    return Padding(
      padding: EdgeInsets.only(
        left: FvSpacing.x6,
        right: FvSpacing.x6,
        top: FvSpacing.x6,
        bottom: MediaQuery.of(context).viewInsets.bottom + FvSpacing.x6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.fvBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: FvSpacing.x4),
          Text(
            widget.s.linkAccountTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: context.fvText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.s.linkAccountSubtitle,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.4,
              color: context.fvTextSecondary,
            ),
          ),
          const SizedBox(height: FvSpacing.x4),
          // Institution selection
          if (widget.isNg)
            InkWell(
              onTap: _openBankPicker,
              borderRadius: BorderRadius.circular(FvRadius.card),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: context.fvWash,
                  borderRadius: BorderRadius.circular(FvRadius.card),
                  border: Border.all(color: FvColors.primaryBorder),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isBank ? Icons.account_balance_outlined : Icons.smartphone_outlined,
                      color: context.fvPrimary,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'INSTITUTION & CBN CODE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: context.fvTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _currentBankCode != null
                                ? '$_currentInstitution (Code: $_currentBankCode)'
                                : _currentInstitution,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: context.fvText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: context.fvSurface,
                        borderRadius: BorderRadius.circular(FvRadius.pill),
                        border: Border.all(color: context.fvBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Change',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: context.fvPrimary,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Icon(Icons.keyboard_arrow_down, size: 14, color: context.fvPrimary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.fvWash,
                borderRadius: BorderRadius.circular(FvRadius.pill),
                border: Border.all(color: FvColors.primaryBorder),
              ),
              child: Text(
                '${_isBank ? s.linkAccountTypeBank : s.linkAccountTypeMobile}  •  $_currentInstitution',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: context.fvPrimary,
                ),
              ),
            ),
          const SizedBox(height: FvSpacing.x4),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: widget.isNg ? 'Account Number (10 digits)' : null,
              hintText: widget.isNg ? 'e.g. 0123456789' : s.linkAccountHint,
              errorText: _error,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(FvRadius.input),
                borderSide: BorderSide(color: context.fvBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(FvRadius.input),
                borderSide: BorderSide(color: context.fvBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(FvRadius.input),
                borderSide: BorderSide(color: context.fvPrimary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(FvRadius.input),
                borderSide: BorderSide(color: context.fvError),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            onSubmitted: (_) => _submit(),
          ),
          if (_resolving)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Resolving account name with CBN directory...',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.fvTextSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          if (_resolvedName != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: context.fvWash,
                  borderRadius: BorderRadius.circular(FvRadius.card),
                  border: Border.all(color: FvColors.primary.withOpacity(0.35)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: FvColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ACCOUNT VERIFIED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: context.fvPrimary,
                            ),
                          ),
                          Text(
                            _resolvedName!,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: context.fvText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_resolveError != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: context.fvError, size: 15),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _resolveError!,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.fvError,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: FvSpacing.x3),
          TextField(
            controller: _holder,
            autofocus: false,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: s.linkHolderName,
              hintText: s.linkHolderHint,
              errorText: _holderError,
              suffixIcon: _resolvedName != null
                  ? const Icon(Icons.verified, color: FvColors.primary, size: 20)
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(FvRadius.input),
                borderSide: BorderSide(color: context.fvBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(FvRadius.input),
                borderSide: BorderSide(color: context.fvBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(FvRadius.input),
                borderSide: BorderSide(color: context.fvPrimary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(FvRadius.input),
                borderSide: BorderSide(color: context.fvError),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            onChanged: (_) {
              if (_holderError != null) setState(() => _holderError = null);
            },
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: FvSpacing.x5),
          FvButton(
            label: s.linkAccount,
            onPressed: (_verifying || _resolving) ? null : _submit,
            loading: _verifying,
          ),
          const SizedBox(height: FvSpacing.x3),
        ],
      ),
    );
  }
}

// ── Searchable Bank Picker Bottom Sheet ────────────────────────────────────────

class _BankPickerSheet extends StatefulWidget {
  const _BankPickerSheet({
    required this.banks,
    required this.selectedCode,
    required this.selectedName,
    required this.onSelect,
  });

  final List<Institution> banks;
  final String? selectedCode;
  final String selectedName;
  final ValueChanged<Institution> onSelect;

  @override
  State<_BankPickerSheet> createState() => _BankPickerSheetState();
}

class _BankPickerSheetState extends State<_BankPickerSheet> {
  final _searchCtrl = TextEditingController();
  late List<Institution> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = widget.banks;
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filtered = widget.banks;
      } else {
        _filtered = widget.banks.where((b) {
          final matchesName = b.name.toLowerCase().contains(query);
          final matchesCode = b.code != null && b.code!.toLowerCase().contains(query);
          final matchesBlurb = b.blurb != null && b.blurb!.toLowerCase().contains(query);
          return matchesName || matchesCode || matchesBlurb;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      padding: EdgeInsets.only(
        left: FvSpacing.x5,
        right: FvSpacing.x5,
        top: FvSpacing.x5,
        bottom: MediaQuery.of(context).viewInsets.bottom + FvSpacing.x5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.fvBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: FvSpacing.x3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Bank or Wallet',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: context.fvText,
                ),
              ),
              Text(
                '${widget.banks.length} institutions',
                style: TextStyle(
                  fontSize: 12,
                  color: context.fvTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: FvSpacing.x3),
          TextField(
            controller: _searchCtrl,
            autofocus: false,
            decoration: InputDecoration(
              hintText: 'Search by bank name or code (e.g. Zenith, 057)...',
              prefixIcon: const Icon(Icons.search, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(FvRadius.input),
                borderSide: BorderSide(color: context.fvBorder),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
          const SizedBox(height: FvSpacing.x3),
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text(
                      'No matching institution found.',
                      style: TextStyle(color: context.fvTextSecondary),
                    ),
                  )
                : ListView.separated(
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: context.fvBorder.withOpacity(0.5),
                    ),
                    itemBuilder: (ctx, i) {
                      final bank = _filtered[i];
                      final isSelected = (bank.code != null && bank.code == widget.selectedCode) ||
                          bank.name.toLowerCase() == widget.selectedName.toLowerCase();
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        leading: Icon(
                          bank.type == AccountType.bank
                              ? Icons.account_balance_outlined
                              : Icons.smartphone_outlined,
                          color: isSelected ? context.fvPrimary : context.fvTextSecondary,
                          size: 22,
                        ),
                        title: Text(
                          bank.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? context.fvPrimary : context.fvText,
                          ),
                        ),
                        subtitle: bank.code != null
                            ? Text(
                                'CBN Code: ${bank.code}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.fvTextSecondary,
                                ),
                              )
                            : null,
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: context.fvPrimary, size: 18)
                            : null,
                        onTap: () => widget.onSelect(bank),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Institution Link Card ──────────────────────────────────────────────────────

class _LinkCard extends StatelessWidget {
  const _LinkCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.institution,
    required this.typeLabel,
    required this.linkedNotifier,
    required this.importedNotifier,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String institution;
  final String typeLabel;
  final ValueNotifier<bool> linkedNotifier;
  final ValueNotifier<int> importedNotifier;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return ValueListenableBuilder<bool>(
      valueListenable: linkedNotifier,
      builder: (context, linked, _) {
        return ValueListenableBuilder<int>(
          valueListenable: importedNotifier,
          builder: (context, imported, _) {
            return FvCard(
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: linked ? FvColors.successBg : context.fvWash,
                      borderRadius: BorderRadius.circular(
                        FvRadius.iconContainer,
                      ),
                    ),
                    child: Icon(
                      linked ? Icons.check_circle_outline : icon,
                      size: 20,
                      color: linked ? context.fvSuccess : context.fvPrimary,
                    ),
                  ),
                  const SizedBox(width: FvSpacing.x3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: context.fvText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          linked
                              ? '$imported ${s.linkSuccessBody(imported).replaceAll(RegExp(r'\d+ '), '')}'
                              : '$typeLabel  •  $subtitle',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: linked
                                ? context.fvSuccess
                                : context.fvTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: FvSpacing.x2),
                  if (linked)
                    StatusBadge(
                      label: s.linked,
                      foreground: context.fvSuccess,
                      background: context.fvWash,
                    )
                  else
                    FvButton(
                      label: s.linkAccount,
                      onPressed: onTap,
                      variant: FvButtonVariant.success,
                      expanded: false,
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
