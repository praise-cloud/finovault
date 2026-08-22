import 'package:flutter/material.dart';
import '../../core/format.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/money.dart';
import '../../core/state/preferences.dart';
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

class IndividualHome extends ConsumerWidget {
  const IndividualHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        HeroCard(label: 'Total net worth', amount: summary.totalBalance, currency: 'MUR'),
        FvCard(
          margin: const EdgeInsets.only(bottom: FvSpacing.x4),
          child: Column(
            children: [
              Row(
                children: [
                  StatCard(
                    label: 'Security score',
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
          QuickAction('Send', Icons.send_outlined, () => openTransfer(context)),
          QuickAction('Save', Icons.savings_outlined, () => openNewGoal(context)),
          QuickAction('Pay Bill', Icons.receipt_long_outlined, () => openBills(context)),
          QuickAction('Insights', Icons.psychology_outlined, () => ref.read(homeTabIndexProvider.notifier).state = 1),
        ]),
        Padding(
          padding: const EdgeInsets.only(bottom: FvSpacing.x3, top: FvSpacing.x2),
          child: Text('Spending vs budget',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: context.fvText)),
        ),
        FvCard(
          margin: const EdgeInsets.only(bottom: FvSpacing.x4),
          child: StatCard(
            label: 'Monthly spending',
            amount: summary.monthExpense,
            currency: 'MUR',
            sub: 'vs your monthly budget',
          ),
        ),
        const _SectionTitle('Savings'),
        FvCard(
          margin: const EdgeInsets.only(bottom: FvSpacing.x4),
          child: StatCard(
            label: 'Rainy-day fund',
            amount: goal?.currentAmount ?? 0,
            currency: 'MUR',
            sub: goal != null
                ? 'of ${FvFormat.formatMoney(goal.targetAmount, language: language)} goal'
                : 'Start an emergency goal',
          ),
        ),
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
    final summary = ref.watch(moneySummaryProvider);
    final goals = ref.watch(goalsProvider);

    final runway = summary.monthExpense > 0
        ? summary.runwayMonths.round().toString()
        : '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeroCard(label: 'Income this month', amount: summary.monthIncome, currency: 'MUR'),
        StatPair(
          left: StatCard(label: 'Unpaid invoices', value: '${summary.unpaidInvoiceCount}', sub: summary.unpaidInvoiceTotal == 0 ? 'all settled' : FvFormat.formatMoney(summary.unpaidInvoiceTotal)),
          right: StatCard(label: 'Tax estimate', amount: summary.taxEstimate, currency: 'MUR', sub: '≈ 15% of income'),
        ),
        StatPair(
          left: StatCard(label: 'Runway', value: runway, sub: 'months of cover'),
          right: StatCard(label: 'Active projects', value: '${goals.value?.length ?? 0}', sub: 'across your vault'),
        ),
        QuickActionsRow(actions: [
          QuickAction('Add invoice', Icons.add, () => openInvoices(context)),
          QuickAction('Set aside tax', Icons.umbrella_outlined, () => openNewGoal(context)),
          QuickAction('Transfer', Icons.send_outlined, () => openTransfer(context)),
          QuickAction('Coach', Icons.psychology_outlined, () => ref.read(homeTabIndexProvider.notifier).state = 1),
        ]),
        const _SectionTitle('Recent projects'),
        FvCard(
          margin: const EdgeInsets.only(bottom: FvSpacing.x4),
          child: StatCard(
            label: 'Active goals',
            value: '${goals.value?.length ?? 0}',
            sub: 'Add a project or goal to track it here',
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
    final summary = ref.watch(moneySummaryProvider);

    final runway = summary.monthExpense > 0
        ? summary.runwayMonths.round().toString()
        : '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeroCard(label: 'Combined wealth', amount: summary.totalBalance, currency: 'MUR'),
        StatPair(
          left: StatCard(label: 'Revenue / MRR', amount: summary.monthIncome, currency: 'MUR'),
          right: StatCard(label: 'Runway', value: runway, sub: 'months of cover'),
        ),
        StatPair(
          left: StatCard(label: 'Burn rate', amount: summary.monthExpense, currency: 'MUR', sub: 'per month'),
          right: StatCard(label: 'Saved in goals', amount: summary.savedInGoals, currency: 'MUR'),
        ),
        QuickActionsRow(actions: [
          QuickAction('Cash flow', Icons.trending_up, () => openTransactions(context)),
          QuickAction('Grants', Icons.business_center_outlined, () {}),
          QuickAction('Transfer', Icons.send_outlined, () => openTransfer(context)),
          QuickAction('Coach', Icons.psychology_outlined, () => ref.read(homeTabIndexProvider.notifier).state = 1),
        ]),
        if (femaleFounder) ...[
          const _SectionTitle('Opportunities'),
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
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Female Innovators Seed Fund', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      SizedBox(height: 2),
                      Text('Curated for women-led ventures', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, size: 18),
              ],
            ),
          ),
        ],
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
    final summary = ref.watch(moneySummaryProvider);
    final vendors = ref.watch(vendorsProvider);
    final overdue = summary.overdueInvoiceCount;

    final runway = summary.monthExpense > 0
        ? summary.runwayMonths.round()
        : null;

    final attention = <String>[];
    if (overdue > 0) attention.add('$overdue overdue invoice${overdue > 1 ? 's' : ''} need attention');
    if (vendors.value?.isEmpty ?? true) attention.add('No vendors linked yet');
    if (runway != null && runway < 3) attention.add('Runway is low — $runway months left');

    final vendorCount = vendors.value?.length ?? 0;
    final vendorSpend = vendors.value?.fold<double>(0, (s, v) => s + v.totalSpend) ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeroCard(label: 'Cash position', amount: summary.totalBalance, currency: 'MUR'),
        StatPair(
          left: StatCard(label: 'Revenue', amount: summary.monthIncome, currency: 'MUR'),
          right: StatCard(label: 'Runway', value: runway == null ? '—' : '$runway', sub: 'months of cover'),
        ),
        StatPair(
          left: StatCard(label: 'Burn rate', amount: summary.monthExpense, currency: 'MUR', sub: 'per month'),
          right: StatCard(label: 'Saved in goals', amount: summary.savedInGoals, currency: 'MUR'),
        ),
        QuickActionsRow(actions: [
          QuickAction('Pay vendor', Icons.send_outlined, () => openVendors(context)),
          QuickAction('Record invoice', Icons.add, () => openInvoices(context)),
          QuickAction('Cash flow', Icons.trending_up, () => openTransactions(context)),
          QuickAction('Advisor', Icons.psychology_outlined, () => ref.read(homeTabIndexProvider.notifier).state = 1),
        ]),
        Padding(
          padding: const EdgeInsets.only(bottom: FvSpacing.x3, top: FvSpacing.x2),
          child: Text('Needs attention',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: context.fvText)),
        ),
        FvCard(
          margin: const EdgeInsets.only(bottom: FvSpacing.x4),
          child: attention.isEmpty
              ? Text('All clear — nothing needs your attention.', style: TextStyle(fontSize: 14, color: context.fvTextSecondary))
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
              Expanded(child: Text('Vendors', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: context.fvText))),
              GestureDetector(
                onTap: () => openVendors(context),
                child: const Text('Add', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: FvColors.primary)),
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
  Widget build(BuildContext context) => FvCard(
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
                  Text('Link an account', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.fvText)),
                  const SizedBox(height: 2),
                  Text('See everything in one place', style: TextStyle(fontSize: 13, color: context.fvTextSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 16),
          ],
        ),
      );
}


