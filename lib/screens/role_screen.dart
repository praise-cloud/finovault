import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models.dart';
import '../core/state/onboarding.dart';
import '../l10n/app_localizations.dart';
import '../theme/tokens.dart';
import '../widgets/ui.dart';

/// Onboarding step 2 — the Individual vs SME (vs Freelancer/Entrepreneur)
/// choice that drives every downstream screen (goals, dashboard, modules).
class RoleScreen extends ConsumerStatefulWidget {
  const RoleScreen({super.key});

  @override
  ConsumerState<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends ConsumerState<RoleScreen> {
  PrimaryRole? _selected;
  bool _femaleFounder = false;

  @override
  void initState() {
    super.initState();
    final saved = ref.read(onboardingProvider);
    if (saved.step == OnboardingStep.role) {
      _selected = saved.role;
      _femaleFounder = saved.scheme == RoleScheme.femaleFounder;
    }
  }

  void _continue() {
    final role = _selected;
    if (role == null) return;
    ref.read(onboardingProvider.notifier).selectRole(role, femaleFounder: _femaleFounder);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Scaffold(
      body: Container(
        decoration: context.fvOnboardingDecoration,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(FvSpacing.x6, FvSpacing.x4, FvSpacing.x6, 0),
                child: OnboardingHeader(
                  onBack: () => ref.read(onboardingProvider.notifier).back(),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(FvSpacing.x6, FvSpacing.x8, FvSpacing.x6, FvSpacing.x6),
                  children: [
                    Text(
                      s.howWillYouUse,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: FvColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.pickManageMoney,
                      style: const TextStyle(fontSize: 15, height: 1.5, color: FvColors.primary),
                    ),
                    const SizedBox(height: 24),
                    for (final role in PrimaryRole.values) ...[
                      _RoleCard(
                        s: s,
                        role: role,
                        selected: _selected == role,
                        onTap: () => setState(() => _selected = role),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (_selected == PrimaryRole.entrepreneur)
                      _FemaleFounderCard(
                        checked: _femaleFounder,
                        onChanged: (v) => setState(() => _femaleFounder = v),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selected == null ? null : _continue,
                        child: Text(s.continueCta),
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
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.s, required this.role, required this.selected, required this.onTap});

  final AppLocalizations s;
  final PrimaryRole role;
  final bool selected;
  final VoidCallback onTap;

  String get _label => switch (role) {
        PrimaryRole.individual => s.roleIndividual,
        PrimaryRole.freelancer => s.roleFreelancer,
        PrimaryRole.entrepreneur => s.roleEntrepreneur,
        PrimaryRole.sme => s.roleSme,
      };

  String get _description => switch (role) {
        PrimaryRole.individual => s.roleIndividualDesc,
        PrimaryRole.freelancer => s.roleFreelancerDesc,
        PrimaryRole.entrepreneur => s.roleEntrepreneurDesc,
        PrimaryRole.sme => s.roleSmeDesc,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: selected ? FvColors.wash : (isDark ? FvColors.surfaceDark : FvColors.surface),
      borderRadius: BorderRadius.circular(FvRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FvRadius.card),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(FvRadius.card),
            border: Border.all(
              color: selected ? FvColors.primary : (isDark ? FvColors.primaryBorderDark : FvColors.primaryBorder),
              width: selected ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.all(FvSpacing.x4),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: selected ? FvColors.primary : FvColors.wash,
                  borderRadius: BorderRadius.circular(FvRadius.iconContainer),
                ),
                child: Icon(
                  role.icon,
                  size: 20,
                  color: selected ? Colors.white : FvColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: FvColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _description,
                      style: const TextStyle(fontSize: 13, color: FvColors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? FvColors.primary : Colors.transparent,
                  border: Border.all(
                    color: selected ? FvColors.primary : (isDark ? FvColors.borderDark : FvColors.border),
                  ),
                ),
                child: selected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FemaleFounderCard extends StatelessWidget {
  const _FemaleFounderCard({required this.checked, required this.onChanged});

  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FvColors.wash,
      borderRadius: BorderRadius.circular(FvRadius.button),
      child: InkWell(
        onTap: () => onChanged(!checked),
        borderRadius: BorderRadius.circular(FvRadius.button),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(FvRadius.button),
            border: Border.all(color: FvColors.primaryBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: FvSpacing.x4, vertical: FvSpacing.x3),
          child: Row(
            children: [
              Checkbox(
                value: checked,
                onChanged: (v) => onChanged(v ?? false),
                activeColor: FvColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).femaleFounderPath,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: FvColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}