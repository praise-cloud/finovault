import 'package:flutter/material.dart';
import '../../core/format.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/money.dart';
import '../../core/state/preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';
import '../../widgets/vault_mark.dart';
import '../home_shell.dart';

// ---- shared cards ------------------------------------------------------------

class HeroCard extends StatelessWidget {
  const HeroCard({super.key, required this.label, required this.amount, required this.currency});

  final String label;
  final double amount;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: FvSpacing.x4),
      padding: const EdgeInsets.all(FvSpacing.x5),
      decoration: BoxDecoration(
        gradient: FvColors.heroGradient,
        borderRadius: BorderRadius.circular(FvRadius.card),
        boxShadow: const [FvShadows.card],
      ),
      child: Stack(
        children: [
          Positioned(right: -24, top: -24, child: Opacity(opacity: 0.22, child: const VaultMark(size: 130, subdued: true))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white70)),
              const SizedBox(height: 6),
              MoneyText(amount, size: MoneySize.lg, color: Colors.white, currency: currency),
            ],
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.label, this.amount, this.value, this.sub, this.currency = 'MUR'});

  final String label;
  final double? amount;
  final String? value;
  final String? sub;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final Widget valueWidget = amount != null
        ? MoneyText(amount!, size: MoneySize.md, color: context.fvText, currency: currency)
        : Text(value ?? '—', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: context.fvText));
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: context.fvTextSecondary)),
          const SizedBox(height: 4),
          valueWidget,
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(sub!, style: TextStyle(fontSize: 12, color: context.fvTextSecondary)),
          ],
        ],
      ),
    );
  }
}

/// A GlassCard holding two stats side by side (mirrors MetricsRow).
class StatPair extends StatelessWidget {
  const StatPair({super.key, required this.left, required this.right});

  final StatCard left;
  final StatCard right;

  @override
  Widget build(BuildContext context) {
    return FvCard(
      margin: const EdgeInsets.only(bottom: FvSpacing.x4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          left,
          const SizedBox(width: FvSpacing.x4, height: 0),
          Container(width: 1, height: 44, color: context.fvBorder),
          const SizedBox(width: FvSpacing.x4, height: 0),
          right,
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: FvSpacing.x3),
        child: Text(title,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: context.fvText)),
      );
}

// ---- Individual --------------------------------------------------------------

class _PensionTile extends ConsumerWidget {
  const _PensionTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context)!;
    final plan = ref.watch(pensionPlanProvider);
    final projection = ref.watch(pensionProjectionProvider);
    final language = ref.watch(preferencesProvider).language;
    final hasPlan = plan.value != null;

    final current = (plan.value?.currentShortPot ?? 0) + (plan.value?.currentLongPot ?? 0);
    final target = (plan.value?.shortPotTarget ?? 0) + (plan.value?.longPotTarget ?? 0);
    final progress = target <= 0 ? 0.0 : (current / target).clamp(0.0, 1.0);

    return FvCard(
      onTap: () => openPension(context),
      margin: const EdgeInsets.only(bottom: FvSpacing.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.fvSurface,
                  borderRadius: BorderRadius.circular(FvRadius.iconContainer),
                  border: Border.all(color: context.fvCardBorder),
                ),
                child: const Icon(Icons.account_balance_outlined, color: FvColors.primary, size: 20),
              ),
              const SizedBox(width: FvSpacing.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.pension, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      hasPlan
                          ? s.pensionProjected(FvFormat.formatMoney(projection.totalProjected, language: language))
                          : s.pensionStart,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 18),
            ],
          ),
          if (hasPlan) ...[
            const SizedBox(height: FvSpacing.x3),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: context.fvBorder,
              color: FvColors.primary,
              minHeight: 6,
            ),
          ],
        ],
      ),
    );
  }
}

class IndividualHome extends ConsumerWidget {
  const IndividualHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context)!;
    final summary = ref.watch(moneySummaryProvider);
    final goals = ref.watch(goalsProvider);
    final security = ref.watch(securityOverviewProvider);
    final language = ref.watch(preferencesProvider).language;

    final goal = goals.value?.where((g) => !g.completed).firstOrNull ?? goals.value?.firstOrNull;
    final pct = goal != null && goal.targetAmount > 0
        ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeroCard(label: s.totalNetWorth, amount: summary.totalBalance, currency: 'MUR'),
        FvCard(
          margin: const EdgeInsets.only(bottom: FvSpacing.x4),
          child: Column(
            children: [
              Row(
                children: [
                  StatCard(
                    label: s.securityScore,
                    value: security.value == null ? '—' : '${security.value!.score}',
                    sub: FvFormat.formatPercent(pct),
                  ),
                  const SizedBox(width: FvSpacing.x4, height: 0),
                  Container(width: 1, height: 44, color: context.fvBorder),
                  const SizedBox(width: FvSpacing.x4, height: 0),
                  Column(
                    children: [
                      ProgressRing(progress: pct, size: 56, stroke: 6),
                      const SizedBox(height: 4),
                      Text('${((pct * 100).round())}%', style: TextStyle(fontSize: 12, color: context.fvTextSecondary)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        QuickActionsRow(actions: [
          QuickAction(s.qaSend, Icons.send_outlined, () => openTransfer(context)),
          QuickAction(s.qaSave, Icons.savings_outlined, () => openNewGoal(context)),
          QuickAction(s.payBill, Icons.receipt_long_outlined, () => openBills(context)),
          QuickAction(s.insights, Icons.psychology_outlined, () => ref.read(homeTabIndexProvider.notifier).state = 1),
        ]),
        Padding(
          padding: const EdgeInsets.only(bottom: FvSpacing.x3, top: FvSpacing.x2),
          child: Text(s.spendingVsBudget,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: context.fvText)),
        ),
        FvCard(
          margin: const EdgeInsets.only(bottom: FvSpacing.x4),
          child: StatCard(
            label: s.monthlySpending,
            amount: summary.monthExpense,
            currency: 'MUR',
            sub: s.vsMonthlyBudget,
          ),
        ),
        _SectionTitle(s.savingsSection),
        FvCard(
          margin: const EdgeInsets.only(bottom: FvSpacing.x4),
          child: StatCard(
            label: s.rainyDayFund,
            amount: goal?.currentAmount ?? 0,
            currency: 'MUR',
            sub: goal != null
                ? s.goalAmountTarget(FvFormat.formatMoney(goal.targetAmount, language: language))
                : s.startEmergencyGoal,
          ),
        ),
        const _PensionTile(),
        const _LinkAccountCta(),
      ],
    );
  }
}

// ---- Freelancer --------------------------------------------------------------

class FreelancerHome extends ConsumerWidget {
  const FreelancerHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context)!;
    final summary = ref.watch(moneySummaryProvider);
    final goals = ref.watch(goalsProvider);

    final runway = summary.monthExpense > 0
        ? summary.runwayMonths.round().toString()
        : '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeroCard(label: s.incomeThisMonth, amount: summary.monthIncome, currency: 'MUR'),
        StatPair(
          left: StatCard(label: s.unpaidInvoices, value: '${summary.unpaidInvoiceCount}', sub: summary.unpaidInvoiceTotal == 0 ? s.allSettled : FvFormat.formatMoney(summary.unpaidInvoiceTotal)),
          right: StatCard(label: s.taxEstimate, amount: summary.taxEstimate, currency: 'MUR', sub: s.approxTax),
        ),
        StatPair(
          left: StatCard(label: s.runwayLabel, value: runway, sub: s.monthsOfCover),
          right: StatCard(label: s.activeProjects, value: '${goals.value?.length ?? 0}', sub: s.acrossYourVault),
        ),
        QuickActionsRow(actions: [
          QuickAction(s.qaAddInvoice, Icons.add, () => openInvoices(context)),
          QuickAction(s.qaSetAsideTax, Icons.umbrella_outlined, () => openNewGoal(context)),
          QuickAction(s.qaTransfer, Icons.send_outlined, () => openTransfer(context)),
          QuickAction(s.qaCoach, Icons.psychology_outlined, () => ref.read(homeTabIndexProvider.notifier).state = 1),
        ]),
        _SectionTitle(s.recentProjects),
        FvCard(
          margin: const EdgeInsets.only(bottom: FvSpacing.x4),
          child: StatCard(
            label: s.activeGoalsLabel,
            value: '${goals.value?.length ?? 0}',
            sub: s.addProjectHint,
          ),
        ),
        const _LinkAccountCta(),
      ],
    );
  }
}

// ---- Entrepreneur ------------------------------------------------------------

class EntrepreneurHome extends ConsumerWidget {
  const EntrepreneurHome({super.key, this.femaleFounder = false});

  final bool femaleFounder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context)!;
    final summary = ref.watch(moneySummaryProvider);

    final runway = summary.monthExpense > 0
        ? summary.runwayMonths.round().toString()
        : '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeroCard(label: s.combinedWealth, amount: summary.totalBalance, currency: 'MUR'),
        StatPair(
          left: StatCard(label: s.revenueMrr, amount: summary.monthIncome, currency: 'MUR'),
          right: StatCard(label: s.runwayLabel, value: runway, sub: s.monthsOfCover),
        ),
        StatPair(
          left: StatCard(label: s.burnRate, amount: summary.monthExpense, currency: 'MUR', sub: s.perMonth),
          right: StatCard(label: s.savedInGoalsLabel, amount: summary.savedInGoals, currency: 'MUR'),
        ),
        QuickActionsRow(actions: [
          QuickAction(s.qaCashFlow, Icons.trending_up, () => openTransactions(context)),
          QuickAction(s.qaGrants, Icons.business_center_outlined, () {}),
          QuickAction(s.qaTransfer, Icons.send_outlined, () => openTransfer(context)),
          QuickAction(s.qaCoach, Icons.psychology_outlined, () => ref.read(homeTabIndexProvider.notifier).state = 1),
        ]),
        if (femaleFounder) ...[
          _SectionTitle(s.opportunitiesLabel),
          FvCard(
            onTap: () => ref.read(homeTabIndexProvider.notifier).state = 1,
            margin: const EdgeInsets.only(bottom: FvSpacing.x4),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: context.fvSurface,
                    borderRadius: BorderRadius.circular(FvRadius.iconContainer),
                    border: Border.all(color: context.fvCardBorder),
                  ),
                  child: const Icon(Icons.emoji_events_outlined, color: FvColors.primary, size: 20),
                ),
                const SizedBox(width: FvSpacing.x3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.femaleSeedFund, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(s.femaleSeedBlurb, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, size: 18),
              ],
            ),
          ),
        ],
        const _PensionTile(),
        const _LinkAccountCta(),
      ],
    );
  }
}

// ---- SME ---------------------------------------------------------------------

class SMEHome extends ConsumerWidget {
  const SMEHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context)!;
    final summary = ref.watch(moneySummaryProvider);
    final vendors = ref.watch(vendorsProvider);
    final overdue = summary.overdueInvoiceCount;

    final runway = summary.monthExpense > 0
        ? summary.runwayMonths.round()
        : null;

    final attention = <String>[];
    if (overdue > 0) attention.add(s.smeOverdue(overdue));
    if (vendors.value?.isEmpty ?? true) attention.add(s.smeNoVendors);
    if (runway != null && runway < 3) attention.add(s.smeRunwayLow(runway));

    final vendorCount = vendors.value?.length ?? 0;
    final vendorSpend = vendors.value?.fold<double>(0, (a, v) => a + v.totalSpend) ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeroCard(label: s.cashPosition, amount: summary.totalBalance, currency: 'MUR'),
        StatPair(
          left: StatCard(label: s.revenue, amount: summary.monthIncome, currency: 'MUR'),
          right: StatCard(label: s.runwayLabel, value: runway == null ? '—' : '$runway', sub: s.monthsOfCover),
        ),
        StatPair(
          left: StatCard(label: s.burnRate, amount: summary.monthExpense, currency: 'MUR', sub: s.perMonth),
          right: StatCard(label: s.savedInGoalsLabel, amount: summary.savedInGoals, currency: 'MUR'),
        ),
        QuickActionsRow(actions: [
          QuickAction(s.qaPayVendor, Icons.send_outlined, () => openVendors(context)),
          QuickAction(s.qaRecordInvoice, Icons.add, () => openInvoices(context)),
          QuickAction(s.qaCashFlow, Icons.trending_up, () => openTransactions(context)),
          QuickAction(s.qaAdvisor, Icons.psychology_outlined, () => ref.read(homeTabIndexProvider.notifier).state = 1),
        ]),
        Padding(
          padding: const EdgeInsets.only(bottom: FvSpacing.x3, top: FvSpacing.x2),
          child: Text(s.needsAttention,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: context.fvText)),
        ),
        FvCard(
          margin: const EdgeInsets.only(bottom: FvSpacing.x4),
          child: attention.isEmpty
              ? Text(s.allClear, style: TextStyle(fontSize: 14, color: context.fvTextSecondary))
              : Column(
                  children: [
                    for (final item in attention)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: FvSpacing.x2),
                        child: Row(
                          children: [
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: FvColors.warning, shape: BoxShape.circle)),
                            const SizedBox(width: FvSpacing.x3),
                            Expanded(child: Text(item, style: TextStyle(fontSize: 14, color: context.fvText))),
                            const Icon(Icons.chevron_right, size: 16),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: FvSpacing.x3),
          child: Row(
            children: [
              Expanded(child: Text(s.vendors, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: context.fvText))),
              GestureDetector(
                onTap: () => openVendors(context),
                child: Text(s.add, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: FvColors.primary)),
              ),
            ],
          ),
        ),
        FvCard(
          onTap: () => openVendors(context),
          margin: const EdgeInsets.only(bottom: FvSpacing.x4),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: context.fvSurface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: context.fvCardBorder),
                ),
                child: const Icon(Icons.business_center_outlined, size: 18, color: FvColors.primary),
              ),
              const SizedBox(width: FvSpacing.x3),
              Expanded(
                child: Text('$vendorCount · ${FvFormat.formatMoney(vendorSpend)}',
                    style: TextStyle(fontSize: 14, color: context.fvText)),
              ),
              const Icon(Icons.chevron_right, size: 16),
            ],
          ),
        ),
        const _LinkAccountCta(),
      ],
    );
  }
}

class _LinkAccountCta extends StatelessWidget {
  const _LinkAccountCta();

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    return FvCard(
      onTap: () => openAccounts(context),
      margin: const EdgeInsets.only(bottom: FvSpacing.x4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: FvColors.wash,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.fvCardBorder),
            ),
            child: const Icon(Icons.link_outlined, size: 18, color: FvColors.primary),
          ),
          const SizedBox(width: FvSpacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.linkAccount, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.fvText)),
                const SizedBox(height: 2),
                Text(s.seeEverything, style: TextStyle(fontSize: 13, color: context.fvTextSecondary)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 16),
        ],
      ),
    );
  }
}


