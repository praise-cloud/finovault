import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/mock/api.dart';
import '../../core/providers.dart';
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
  }) async {
    final api = ref.read(apiProvider);
    final token = ref.read(kvStoreProvider).getString(sessionKey);

    // 1. Privacy policy gate — only if user hasn't accepted yet.
    final profile = await api.getSession(token);
    if (profile != null && !profile.hasAcceptedPrivacyPolicy) {
      if (!mounted) return;
      final accepted = await _showPrivacySheet();
      if (!accepted) return;
    }

    // 2. Account number + holder name entry (holder verified client-side).
    if (!mounted) return;
    final s = AppLocalizations.of(context);
    final cert = await _showAccountNumberSheet(
      institution: institution,
      displayName: displayName,
      verify: (number, holderName) async {
        try {
          final check = await api.verifyAccount(
            token,
            institution: institution,
            identifier: number,
            holderName: holderName,
          );
          if (!check.verified) {
            return check.exists ? s.verifyMismatch : s.verifyNotFound;
          }
          return null;
        } on FvApiException catch (e) {
          return e.message;
        }
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
        institution: institution,
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

  Future<({String number, String holderName})?> _showAccountNumberSheet({
    required String institution,
    required String displayName,
    required Future<String?> Function(String number, String holderName) verify,
  }) async {
    final s = AppLocalizations.of(context);
    ({String number, String holderName})? result;
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
        verify: verify,
        onSubmit: (number, holderName) {
          result = (number: number, holderName: holderName);
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
                        subtitle: 'MCB, SBM, Bank One, Maubank',
                        institution: 'MCB',
                        typeLabel: s.linkAccountTypeBank,
                        linkedNotifier: _bankLinked,
                        importedNotifier: _bankImported,
                        onTap: () => _onLinkTap(
                          institution: 'MCB',
                          displayName: s.bankAccount,
                          linkedNotifier: _bankLinked,
                          importedNotifier: _bankImported,
                        ),
                      ),
                      const SizedBox(height: FvSpacing.x3),
                      _LinkCard(
                        icon: Icons.smartphone_outlined,
                        title: s.mobileMoney,
                        subtitle: 'Juice, my.t money, Emtel Money',
                        institution: 'Juice',
                        typeLabel: s.linkAccountTypeMobile,
                        linkedNotifier: _momoLinked,
                        importedNotifier: _momoImported,
                        onTap: () => _onLinkTap(
                          institution: 'Juice',
                          displayName: s.mobileMoney,
                          linkedNotifier: _momoLinked,
                          importedNotifier: _momoImported,
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

class _AccountNumberSheet extends StatefulWidget {
  const _AccountNumberSheet({
    required this.s,
    required this.institution,
    required this.displayName,
    required this.verify,
    required this.onSubmit,
  });

  final AppLocalizations s;
  final String institution;
  final String displayName;
  final Future<String?> Function(String number, String holderName) verify;
  final void Function(String number, String holderName) onSubmit;

  @override
  State<_AccountNumberSheet> createState() => _AccountNumberSheetState();
}

class _AccountNumberSheetState extends State<_AccountNumberSheet> {
  final _controller = TextEditingController();
  final _holder = TextEditingController();
  String? _error;
  String? _holderError;
  bool _verifying = false;
  bool _isBank = false;

  static final _bankInstitutions = ['MCB', 'SBM', 'Bank One', 'Maubank'];
  static final _bankPattern = RegExp(r'^\d{8,16}$');
  static final _mobilePattern = RegExp(r'^[5-7]\d{4,7}$');

  @override
  void initState() {
    super.initState();
    _isBank = _bankInstitutions.contains(widget.institution);
  }

  @override
  void dispose() {
    _controller.dispose();
    _holder.dispose();
    super.dispose();
  }

  String? _validate(String value) {
    final s = widget.s;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return s.linkAccountValidationEmpty;
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
    final holder = _holder.text.trim();
    if (holder.isEmpty) {
      setState(() => _holderError = s.linkHolderEmpty);
      return;
    }
    setState(() {
      _error = null;
      _holderError = null;
      _verifying = true;
    });
    final verifyError = await widget.verify(_controller.text.trim(), holder);
    if (!mounted) return;
    if (verifyError != null) {
      setState(() {
        _holderError = verifyError;
        _verifying = false;
      });
      return;
    }
    widget.onSubmit(_controller.text.trim(), holder);
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
          // Institution chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: context.fvWash,
              borderRadius: BorderRadius.circular(FvRadius.pill),
              border: Border.all(color: FvColors.primaryBorder),
            ),
            child: Text(
              '${_isBank ? s.linkAccountTypeBank : s.linkAccountTypeMobile}  •  ${widget.institution}',
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
              hintText: s.linkAccountHint,
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
          const SizedBox(height: FvSpacing.x3),
          TextField(
            controller: _holder,
            autofocus: false,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: s.linkHolderName,
              hintText: s.linkHolderHint,
              errorText: _holderError,
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
            onPressed: _verifying ? null : _submit,
            loading: _verifying,
          ),
          const SizedBox(height: FvSpacing.x3),
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
