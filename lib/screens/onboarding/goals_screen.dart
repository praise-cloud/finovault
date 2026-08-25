import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/state/auth.dart';
import '../../core/state/onboarding.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';
import '../../widgets/vault_mark.dart';
import '../auth/signup_screen.dart';

const _roleGoals = <PrimaryRole, List<String>>{
  PrimaryRole.individual: ['emergency', 'retirement', 'debt', 'home', 'education'],
  PrimaryRole.freelancer: ['emergency', 'tax_shield', 'retirement', 'equipment', 'home'],
  PrimaryRole.entrepreneur: ['emergency', 'business', 'retirement', 'tax_shield', 'home'],
  PrimaryRole.sme: ['business', 'cash_buffer', 'equipment', 'tax_shield'],
};

String goalLabel(AppLocalizations s, String key) => switch (key) {
      'emergency' => s.goalEmergency,
      'retirement' => s.goalRetirement,
      'debt' => s.goalDebt,
      'home' => s.goalHome,
      'education' => s.goalEducation,
      'tax_shield' => s.goalTaxShield,
      'equipment' => s.goalEquipment,
      'business' => s.goalBusiness,
      'cash_buffer' => s.goalCashBuffer,
      _ => key,
    };

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  final _selected = <String>{};
  RiskTolerance? _risk;

  @override
  void initState() {
    super.initState();
    final saved = ref.read(onboardingProvider);
    _selected.addAll(saved.financialGoals);
    _risk = saved.riskTolerance;
  }

  Future<void> _continue() async {
    final auth = ref.read(authProvider);
    if (!auth.isAuthenticated) {
      await pushScreen(context, const SignupScreen());
      return;
    }
    await ref
        .read(onboardingProvider.notifier)
        .setGoals(_selected.toList(), _risk);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    final onboarding = ref.watch(onboardingProvider);
    final role = onboarding.role ?? PrimaryRole.individual;
    final options = _roleGoals[role] ?? _roleGoals[PrimaryRole.individual]!;

    return Scaffold(
      body: Container(
        decoration: context.fvOnboardingDecoration,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(FvSpacing.x6, FvSpacing.x4, FvSpacing.x6, 0),
                child: Row(
                  children: [
                    const VaultMark(size: 28),
                    const SizedBox(width: 10),
                    Text('Finovault',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700, color: FvColors.primary)),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(FvSpacing.x6, FvSpacing.x8, FvSpacing.x6, FvSpacing.x6),
                  children: [
                    Text(s.whatWorkingTowards,
                        style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.4, color: FvColors.primary)),
                    const SizedBox(height: 8),
                    Text(s.goalsSubtitle,
                        style: TextStyle(fontSize: 15, height: 1.5, color: context.fvTextSecondary)),
                    const SizedBox(height: FvSpacing.x5),
                    Wrap(
                      spacing: FvSpacing.x2,
                      runSpacing: FvSpacing.x2,
                      children: [
                        for (final key in options)
                          _GoalChip(
                            label: goalLabel(s, key),
                            selected: _selected.contains(key),
                            onTap: () => setState(() =>
                                _selected.contains(key) ? _selected.remove(key) : _selected.add(key)),
                          ),
                      ],
                    ),
                    const SizedBox(height: FvSpacing.x6),
                    Text(s.riskHeading,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: FvColors.primary)),
                    const SizedBox(height: FvSpacing.x3),
                    for (final risk in RiskTolerance.values)
                      Padding(
                        padding: const EdgeInsets.only(bottom: FvSpacing.x2),
                        child: _RiskRow(
                          label: switch (risk) {
                            RiskTolerance.low => s.riskLow,
                            RiskTolerance.moderate => s.riskModerate,
                            RiskTolerance.high => s.riskHigh,
                          },
                          selected: _risk == risk,
                          onTap: () => setState(() => _risk = risk),
                        ),
                      ),
                    const SizedBox(height: FvSpacing.x5),
                    FvButton(label: s.continueCta, onPressed: _continue),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalChip extends StatelessWidget {
  const _GoalChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? FvColors.wash : context.fvSurface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: FvSpacing.x4, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? FvColors.primary : context.fvBorder, width: selected ? 1.5 : 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                const Icon(Icons.check, size: 14, color: FvColors.primary),
                const SizedBox(width: 6),
              ],
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: FvColors.primary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RiskRow extends StatelessWidget {
  const _RiskRow({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.fvSurface,
      borderRadius: BorderRadius.circular(FvRadius.button),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FvRadius.button),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: FvSpacing.x4, vertical: FvSpacing.x3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(FvRadius.button),
            border: Border.all(color: selected ? FvColors.primary : context.fvCardBorder, width: selected ? 1.5 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? FvColors.primary : Colors.transparent,
                  border: Border.all(color: selected ? FvColors.primary : context.fvBorder),
                ),
                child: selected ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
              ),
              const SizedBox(width: FvSpacing.x3),
              Expanded(child: Text(label, style: TextStyle(fontSize: 14, color: FvColors.primary))),
            ],
          ),
        ),
      ),
    );
  }
}
