import 'package:flutter/material.dart';

import '../../core/format.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/state/auth.dart';
import '../../core/state/money.dart';
import '../../core/state/preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';
import '../../widgets/vault_mark.dart';
import '../home_shell.dart';

/// Unified "Grow" surface (docs 5.1): total wealth, savings goals,
/// and the pension builder status card.
class VaultTab extends ConsumerWidget {
  const VaultTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    final goals = ref.watch(goalsProvider);
    final summary = ref.watch(moneySummaryProvider);
    final plan = ref.watch(pensionPlanProvider);
    final projection = ref.watch(pensionProjectionProvider);

    final pensionValue =
        (plan.value?.currentShortPot ?? 0) + (plan.value?.currentLongPot ?? 0);
    final totalWealth = summary.savedInGoals + pensionValue;

    return ListView(
      padding: const EdgeInsets.all(FvSpacing.x5),
      children: [
        _WealthCard(
          amount: totalWealth,
          savedInGoals: summary.savedInGoals,
          pensionValue: pensionValue,
        ),
        const SizedBox(height: FvSpacing.x4),
        Row(
          children: [
            Expanded(
              child: FvButton(
                label: s.createGoal,
                onPressed: () => openNewGoal(context),
                variant: FvButtonVariant.success,
                expanded: true,
              ),
            ),
            const SizedBox(width: FvSpacing.x3),
            Expanded(
              child: FvButton(
                label: s.startPension,
                variant: FvButtonVariant.secondary,
                onPressed: () => openPension(context),
                expanded: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: FvSpacing.x4),
        SectionHeader(
          title: s.vaultSectionTitle,
          actionLabel: s.allGoals,
          onAction: () => openGoals(context),
        ),
        if (goals.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (goals.hasError)
          EmptyState(title: s.couldNotLoadGoals, body: s.pleaseRetry)
        else if ((goals.value ?? []).isEmpty)
          EmptyState(
            title: s.noGoalsYet,
            body: s.goalsEmptyBody,
            ctaLabel: s.createAGoal,
            onCta: () => openNewGoal(context),
          )
        else ...[
          for (final g in (goals.value!).take(4)) _GoalRow(goal: g),
        ],
        const SizedBox(height: FvSpacing.x3),
        plan.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
          data: (p) => p == null
              ? _PensionEmptyCard()
              : _PensionStatusCard(
                  plan: p,
                  totalProjected: projection.totalProjected,
                ),
        ),
        const SizedBox(height: FvSpacing.x3),
      ],
    );
  }
}

/// Hero: "Total wealth" = savings-in-goals + pension pot, with a
/// two-part breakdown under it (docs 5.1 "Total saved + pension value").
class _WealthCard extends ConsumerWidget {
  const _WealthCard({
    required this.amount,
    required this.savedInGoals,
    required this.pensionValue,
  });

  final double amount;
  final double savedInGoals;
  final double pensionValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    final role =
        ref.watch(currentUserProvider)?.primaryRole ?? PrimaryRole.individual;
    final accent = FvColors.roleAccent(role);
    return Container(
      padding: const EdgeInsets.all(FvSpacing.x5),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(FvRadius.card),
        border: Border.all(color: context.fvCardBorder, width: FvBorders.width),
        boxShadow: context.fvBrutal,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: -24,
            child: Opacity(
              opacity: 0.16,
              child: const VaultMark(size: 130, subdued: true),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: FvColors.ink,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    s.vaultWealthTitle.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              MoneyText(
                amount,
                size: MoneySize.lg,
                color: Colors.white,
                currency: 'MUR',
              ),
              const SizedBox(height: FvSpacing.x4),
              Row(
                children: [
                  Expanded(
                    child: _Breakdown(
                      label: s.vaultInGoals,
                      value: savedInGoals,
                    ),
                  ),
                  Container(width: 1, height: 34, color: Colors.white24),
                  Expanded(
                    child: _Breakdown(
                      label: s.vaultInPension,
                      value: pensionValue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Breakdown extends StatelessWidget {
  const _Breakdown({required this.label, required this.value});
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 2),
          MoneyText(
            value,
            size: MoneySize.sm,
            color: Colors.white,
            currency: 'MUR',
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _GoalRow extends ConsumerWidget {
  const _GoalRow({required this.goal});

  final SavingsGoal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    final language = ref.watch(preferencesProvider).language;
    final pct = goal.targetAmount > 0
        ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;

    return FvCard(
      onTap: () => openGoals(context),
      margin: const EdgeInsets.only(bottom: FvSpacing.x3),
      child: Row(
        children: [
          ProgressRing(
            progress: pct,
            size: 48,
            stroke: 5,
            child: Text(
              '${(pct * 100).round()}%',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: FvSpacing.x4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.fvText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  goal.completed
                      ? s.completed
                      : '${FvFormat.formatMoney(goal.currentAmount, language: language)} of ${FvFormat.formatMoney(goal.targetAmount, language: language)}',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: context.fvTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (goal.completed)
            StatusBadge(
              label: 'Done',
              foreground: context.fvSuccess,
              background: context.fvWash,
            ),
        ],
      ),
    );
  }
}

/// Pension status card: projection headline, pot split ring, plan summary.
class _PensionStatusCard extends ConsumerWidget {
  const _PensionStatusCard({required this.plan, required this.totalProjected});

  final PensionPlan plan;
  final double totalProjected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    final language = ref.watch(preferencesProvider).language;
    final potTotal = (plan.currentShortPot + plan.currentLongPot);
    final shortShare = potTotal > 0
        ? (plan.currentShortPot / potTotal).clamp(0.0, 1.0)
        : 0.0;

    return FvCard(
      accent: FvColors.primary,
      onTap: () => openPension(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.pension.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: context.fvTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.vaultPensionProjectedAt(
                        FvFormat.formatMoney(
                          totalProjected,
                          language: language,
                        ),
                        plan.retirementAge,
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${s.shortTermPot} · ${FvFormat.formatMoney(plan.currentShortPot, language: language)}  /  ${s.longTermPot} · ${FvFormat.formatMoney(plan.currentLongPot, language: language)}',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: context.fvTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              ProgressRing(
                progress: 1,
                size: 64,
                stroke: 6,
                child: Text(
                  '${(shortShare * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FvSpacing.x4),
          Row(
            children: [
              if (plan.autoDebit)
                StatusBadge(
                  label: 'Auto',
                  foreground: context.fvSuccess,
                  background: context.fvWash,
                )
              else
                StatusBadge(
                  label: 'Manual',
                  foreground: context.fvTextSecondary,
                  background: context.fvWash,
                ),
              const Spacer(),
              Text(
                s.vaultManagePension,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: context.fvPrimary,
                ),
              ),
              const SizedBox(width: 2),
              Icon(Icons.chevron_right, size: 16, color: context.fvPrimary),
            ],
          ),
        ],
      ),
    );
  }
}

class _PensionEmptyCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    return FvCard(
      accent: FvColors.primary,
      onTap: () => openPension(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.pension,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            s.vaultNoPensionBody,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: context.fvTextSecondary,
            ),
          ),
          const SizedBox(height: FvSpacing.x3),
          FvButton(
            label: s.startPension,
            variant: FvButtonVariant.secondary,
            onPressed: () => openPension(context),
          ),
        ],
      ),
    );
  }
}
