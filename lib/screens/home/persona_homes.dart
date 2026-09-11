import 'package:flutter/material.dart';

import '../../core/format.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/money.dart';
import '../../core/state/auth.dart';
import '../../core/models.dart';
import '../../core/state/preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';
import '../../widgets/vault_mark.dart';
import '../home_shell.dart';

// ---- shared cards ------------------------------------------------------------

class HeroCard extends ConsumerWidget {
  const HeroCard({
    super.key,
    required this.label,
    required this.amount,
    required this.currency,
    this.caption,
  });

  final String label;
  final double amount;
  final String currency;
  final String? caption;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role =
        ref.watch(currentUserProvider)?.primaryRole ?? PrimaryRole.individual;
    final accent = FvColors.roleAccent(role);
    return Container(
      margin: const EdgeInsets.only(bottom: FvSpacing.x4),
      padding: const EdgeInsets.all(FvSpacing.x5),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(FvRadius.card),
        border: Border.all(color: FvColors.ink, width: FvBorders.width),
        boxShadow: const [FvShadows.brutal],
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
                    label.toUpperCase(),
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
                currency: currency,
              ),
              if (caption != null) ...[
                const SizedBox(height: 4),
                Text(
                  caption!.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: Colors.white70,
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

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    this.amount,
    this.value,
    this.sub,
    this.currency = 'MUR',
  });

  final String label;
  final double? amount;
  final String? value;
  final String? sub;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final Widget valueWidget = amount != null
        ? MoneyText(
            amount!,
            size: MoneySize.md,
            color: context.fvText,
            currency: currency,
          )
        : Text(
            value ?? '—',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: context.fvText,
            ),
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: context.fvTextSecondary),
        ),
        const SizedBox(height: 4),
        valueWidget,
        if (sub != null) ...[
          const SizedBox(height: 2),
          Text(
            sub!,
            style: TextStyle(fontSize: 12, color: context.fvTextSecondary),
          ),
        ],
      ],
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
          Expanded(child: left),
          const SizedBox(width: FvSpacing.x4, height: 0),
          Container(width: 1, height: 44, color: context.fvBorder),
          const SizedBox(width: FvSpacing.x4, height: 0),
          Expanded(child: right),
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
    child: Text(
      title,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: context.fvText,
      ),
    ),
  );
}

// ---- Business metric cards (Entrepreneur/SME) ----------------------------------

/// Reusable metric card for business KPIs with trend and status
class BusinessMetricCard extends ConsumerWidget {
  const BusinessMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.trend,
    this.trendUp = true,
    this.status,
    this.onTap,
  });

  final String label;
  final String value;
  final String? trend;
  final bool trendUp;
  final String? status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FvCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: FvSpacing.x3),
      child: Padding(
        padding: const EdgeInsets.all(FvSpacing.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.fvTextSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: context.fvText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trend != null) ...[
                  const SizedBox(width: FvSpacing.x3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trendUp ? Icons.trending_up : Icons.trending_down,
                        size: 14,
                        color: trendUp ? context.fvSuccess : context.fvError,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trend!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: trendUp ? context.fvSuccess : context.fvError,
                        ),
                      ),
                    ],
                  ),
                ],
                const Spacer(),
                if (status != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: context.fvWash,
                      borderRadius: BorderRadius.circular(FvRadius.badge),
                      border: Border.all(color: context.fvBorder),
                    ),
                    child: Text(
                      status!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: context.fvText,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Cash flow forecast card for SME
class CashFlowForecastCard extends ConsumerWidget {
  const CashFlowForecastCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    final summary = ref.watch(moneySummaryProvider);
    final user = ref.watch(currentUserProvider);
    final bp = user?.businessProfile;
    final monthlyPayroll = bp?.monthlyPayroll ?? 0;
    final runway = summary.monthExpense > 0 ? summary.runwayMonths : null;

    return FvCard(
      margin: const EdgeInsets.only(bottom: FvSpacing.x4),
      child: Padding(
        padding: const EdgeInsets.all(FvSpacing.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  s.cashFlowForecast,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.fvText,
                  ),
                ),
                const Spacer(),
                if (runway != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: runway < 3
                          ? FvColors.errorBg
                          : (runway < 6
                                ? FvColors.warningBg
                                : FvColors.successBg),
                      borderRadius: BorderRadius.circular(FvRadius.badge),
                    ),
                    child: Text(
                      '${runway.toStringAsFixed(1)} ${s.monthsOfCover}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: runway < 3
                            ? context.fvError
                            : (runway < 6
                                  ? context.fvWarning
                                  : context.fvSuccess),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: FvSpacing.x3),
            Row(
              children: [
                Expanded(
                  child: _ForecastItem(
                    label: s.currentCash,
                    value: FvFormat.formatMoney(summary.totalBalance),
                    icon: Icons.account_balance_wallet,
                    color: context.fvPrimary,
                  ),
                ),
                Expanded(
                  child: _ForecastItem(
                    label: s.monthlyBurn,
                    value: FvFormat.formatMoney(summary.monthExpense),
                    icon: Icons.local_fire_department,
                    color: context.fvError,
                  ),
                ),
                Expanded(
                  child: _ForecastItem(
                    label: s.payrollCost,
                    value: FvFormat.formatMoney(monthlyPayroll),
                    icon: Icons.people,
                    color: context.fvWarning,
                  ),
                ),
                Expanded(
                  child: _ForecastItem(
                    label: s.netFlow,
                    value: FvFormat.formatMoney(
                      summary.monthIncome - summary.monthExpense,
                    ),
                    icon: summary.monthIncome >= summary.monthExpense
                        ? Icons.trending_up
                        : Icons.trending_down,
                    color: summary.monthIncome >= summary.monthExpense
                        ? context.fvSuccess
                        : context.fvError,
                  ),
                ),
              ],
            ),
            if (bp?.annualRevenueRange != null) ...[
              const SizedBox(height: FvSpacing.x3),
              Text(
                '${s.annualRevenueRange}: ${_revenueRangeLabel(s, bp!.annualRevenueRange!)}',
                style: TextStyle(fontSize: 12, color: context.fvTextSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _revenueRangeLabel(AppLocalizations s, String range) {
    return switch (range) {
      'pre_revenue' => s.revenuePreRevenue,
      'under_1m' => s.revenueUnder1m,
      '1m_5m' => s.revenue1m5m,
      '5m_20m' => s.revenue5m20m,
      '20m_100m' => s.revenue20m100m,
      '100m_plus' => s.revenue100mPlus,
      _ => range,
    };
  }
}

class _ForecastItem extends StatelessWidget {
  const _ForecastItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 18, color: color),
      const SizedBox(height: 2),
      Flexible(
        child: Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: context.fvText,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      const SizedBox(height: 1),
      Flexible(
        child: Text(
          label,
          style: TextStyle(fontSize: 9, color: context.fvTextSecondary),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    ],
  );
}

/// Vendor Pareto card for SME
class VendorParetoCard extends ConsumerWidget {
  const VendorParetoCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    final vendors = ref.watch(vendorsProvider);

    return FvCard(
      margin: const EdgeInsets.only(bottom: FvSpacing.x4),
      onTap: () => openVendors(context),
      child: Padding(
        padding: const EdgeInsets.all(FvSpacing.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  s.vendorConcentration,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.fvText,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: context.fvTextSecondary,
                ),
              ],
            ),
            const SizedBox(height: FvSpacing.x3),
            vendors.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Text('Error: $e', style: TextStyle(color: context.fvError)),
              data: (list) {
                if (list.isEmpty) {
                  return Text(
                    s.smeNoVendors,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.fvTextSecondary,
                    ),
                  );
                }
                final sorted = [...list]
                  ..sort((a, b) => b.totalSpend.compareTo(a.totalSpend));
                final totalSpend = sorted.fold<double>(
                  0,
                  (a, v) => a + v.totalSpend,
                );
                final top20Count = (sorted.length * 0.2).ceil().clamp(
                  1,
                  sorted.length,
                );
                final top20Spend = sorted
                    .take(top20Count)
                    .fold<double>(0, (a, v) => a + v.totalSpend);
                final pct = totalSpend > 0
                    ? (top20Spend / totalSpend * 100).round()
                    : 0;

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _ParetoStat(
                            label: s.topVendors(top20Count),
                            value: '$pct%',
                            sub: s.ofTotalSpend,
                          ),
                        ),
                        Expanded(
                          child: _ParetoStat(
                            label: s.totalVendorSpend,
                            value: FvFormat.formatMoney(totalSpend),
                            sub: s.acrossVendors(list.length),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: FvSpacing.x3),
                    LinearProgressIndicator(
                      value: pct / 100,
                      backgroundColor: context.fvBorder,
                      color: pct > 80 ? FvColors.warning : FvColors.primary,
                      minHeight: 6,
                    ),
                    const SizedBox(height: FvSpacing.x2),
                    Text(
                      pct > 80
                          ? s.vendorConcentrationHigh
                          : s.vendorConcentrationHealthy,
                      style: TextStyle(
                        fontSize: 11,
                        color: pct > 80 ? context.fvWarning : context.fvSuccess,
                      ),
                    ),
                    const SizedBox(height: FvSpacing.x3),
                    Text(
                      s.topVendors(top20Count),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.fvText,
                      ),
                    ),
                    const SizedBox(height: FvSpacing.x2),
                    ...sorted
                        .take(top20Count)
                        .map(
                          (v) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    v.name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.fvText,
                                    ),
                                  ),
                                ),
                                Text(
                                  FvFormat.formatMoney(v.totalSpend),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: context.fvText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ParetoStat extends StatelessWidget {
  const _ParetoStat({
    required this.label,
    required this.value,
    required this.sub,
  });
  final String label;
  final String value;
  final String sub;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(fontSize: 11, color: context.fvTextSecondary),
      ),
      const SizedBox(height: 2),
      Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: context.fvText,
        ),
      ),
      const SizedBox(height: 2),
      Text(sub, style: TextStyle(fontSize: 10, color: context.fvTextSecondary)),
    ],
  );
}

/// Compliance calendar card for SME
class ComplianceCalendarCard extends ConsumerWidget {
  const ComplianceCalendarCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);
    final bp = user?.businessProfile;

    // Mock upcoming compliance items based on business profile
    final items = <ComplianceItem>[
      ComplianceItem(s.vatFiling, '2026-09-15', ComplianceType.tax),
      ComplianceItem(s.annualReturns, '2026-10-31', ComplianceType.regulatory),
      if (bp?.employeeCount != null && bp!.employeeCount! > 0)
        ComplianceItem(s.payrollFiling, '2026-09-20', ComplianceType.payroll),
      if (bp?.taxId != null && bp!.taxId!.isNotEmpty)
        ComplianceItem(s.taxClearance, '2026-12-31', ComplianceType.tax),
    ];

    return FvCard(
      margin: const EdgeInsets.only(bottom: FvSpacing.x4),
      onTap: () => openSecurity(context),
      child: Padding(
        padding: const EdgeInsets.all(FvSpacing.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  s.complianceCalendar,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.fvText,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: context.fvTextSecondary,
                ),
              ],
            ),
            const SizedBox(height: FvSpacing.x3),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: FvSpacing.x2),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: item.type == ComplianceType.tax
                            ? context.fvError
                            : (item.type == ComplianceType.payroll
                                  ? context.fvWarning
                                  : context.fvPrimary),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: FvSpacing.x3),
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(fontSize: 13, color: context.fvText),
                      ),
                    ),
                    Text(
                      item.daysUntil <= 7
                          ? '⚠ ${item.daysUntil}d'
                          : '${item.daysUntil}d',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: item.daysUntil <= 7
                            ? context.fvError
                            : context.fvTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ComplianceItem {
  const ComplianceItem(this.label, this.date, this.type);
  final String label;
  final String date;
  final ComplianceType type;

  int get daysUntil => DateTime.parse(date).difference(DateTime.now()).inDays;
}

enum ComplianceType { tax, payroll, regulatory }

/// Payroll efficiency card for SME
class PayrollEfficiencyCard extends ConsumerWidget {
  const PayrollEfficiencyCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    final summary = ref.watch(moneySummaryProvider);
    final user = ref.watch(currentUserProvider);
    final bp = user?.businessProfile;
    final monthlyPayroll = bp?.monthlyPayroll ?? 0;
    final employeeCount = bp?.employeeCount ?? 0;

    final payrollPct = summary.monthIncome > 0
        ? (monthlyPayroll / summary.monthIncome * 100).round()
        : 0;
    final revenuePerEmp = employeeCount > 0
        ? summary.monthIncome / employeeCount
        : 0;

    return FvCard(
      margin: const EdgeInsets.only(bottom: FvSpacing.x4),
      child: Padding(
        padding: const EdgeInsets.all(FvSpacing.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.payrollEfficiency,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.fvText,
              ),
            ),
            const SizedBox(height: FvSpacing.x3),
            Row(
              children: [
                Expanded(
                  child: _PayrollStat(
                    label: s.payrollPctOfRevenue,
                    value: '$payrollPct%',
                    status: payrollPct <= 30
                        ? s.healthy
                        : (payrollPct <= 50 ? s.watch : s.high),
                    statusColor: payrollPct <= 30
                        ? context.fvSuccess
                        : (payrollPct <= 50
                              ? context.fvWarning
                              : context.fvError),
                  ),
                ),
                Expanded(
                  child: _PayrollStat(
                    label: s.revenuePerEmployee,
                    value: FvFormat.formatMoney(revenuePerEmp),
                    status: revenuePerEmp > 500000
                        ? s.strong
                        : (revenuePerEmp > 200000 ? s.ok : s.low),
                    statusColor: revenuePerEmp > 500000
                        ? context.fvSuccess
                        : (revenuePerEmp > 200000
                              ? context.fvWarning
                              : context.fvError),
                  ),
                ),
              ],
            ),
            const SizedBox(height: FvSpacing.x3),
            LinearProgressIndicator(
              value: (payrollPct / 100).clamp(0.0, 1.0),
              backgroundColor: context.fvBorder,
              color: payrollPct <= 30
                  ? FvColors.success
                  : (payrollPct <= 50 ? FvColors.warning : FvColors.error),
              minHeight: 6,
            ),
            const SizedBox(height: 4),
            Text(
              '${s.benchmark} ≤ 30%',
              style: TextStyle(fontSize: 10, color: context.fvTextSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayrollStat extends StatelessWidget {
  const _PayrollStat({
    required this.label,
    required this.value,
    required this.status,
    required this.statusColor,
  });
  final String label;
  final String value;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(fontSize: 11, color: context.fvTextSecondary),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: context.fvText,
        ),
      ),
      const SizedBox(height: 2),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(FvRadius.badge),
        ),
        child: Text(
          status,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: statusColor,
          ),
        ),
      ),
    ],
  );
}

/// MRR/ARR card for Entrepreneur
class MrrArrCard extends ConsumerWidget {
  const MrrArrCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    final summary = ref.watch(moneySummaryProvider);
    final user = ref.watch(currentUserProvider);
    final bp = user?.businessProfile;
    final arr = summary.monthIncome * 12;

    return BusinessMetricCard(
      label: s.arr,
      value: FvFormat.formatMoney(arr),
      trend: '+12% MoM',
      trendUp: true,
      status: bp?.businessStage?.label ?? s.growth,
      onTap: () => openTransactions(context),
    );
  }
}

/// Burn multiple card for Entrepreneur
class BurnMultipleCard extends ConsumerWidget {
  const BurnMultipleCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    final summary = ref.watch(moneySummaryProvider);

    final burnMultiple = summary.monthIncome > 0
        ? summary.monthExpense / summary.monthIncome
        : 0;
    final runway = summary.monthExpense > 0 ? summary.runwayMonths : 0;

    return BusinessMetricCard(
      label: s.burnMultiple,
      value: burnMultiple.toStringAsFixed(1),
      trend: burnMultiple <= 2 ? s.efficient : s.high,
      trendUp: burnMultiple <= 2,
      status: runway > 18 ? s.healthy : (runway > 12 ? s.ok : s.critical),
      onTap: () => openTransactions(context),
    );
  }
}

/// Fundraising tracker card for Entrepreneur
class FundraisingTrackerCard extends ConsumerWidget {
  const FundraisingTrackerCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);
    final bp = user?.businessProfile;

    return FvCard(
      margin: const EdgeInsets.only(bottom: FvSpacing.x4),
      onTap: () => openGoals(context),
      child: Padding(
        padding: const EdgeInsets.all(FvSpacing.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  s.fundraisingTracker,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.fvText,
                  ),
                ),
                const Spacer(),
                if (bp?.businessStage == BusinessStage.startup ||
                    bp?.businessStage == BusinessStage.idea)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: FvColors.warningBg,
                      borderRadius: BorderRadius.circular(FvRadius.badge),
                    ),
                    child: Text(
                      s.preSeed,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: context.fvWarning,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: FvSpacing.x3),
            Row(
              children: [
                Expanded(
                  child: _FundraiseStat(
                    label: s.cashOnHand,
                    value: FvFormat.formatMoney(
                      ref.watch(moneySummaryProvider).totalBalance,
                    ),
                  ),
                ),
                Expanded(
                  child: _FundraiseStat(
                    label: s.monthlyBurn,
                    value: FvFormat.formatMoney(
                      ref.watch(moneySummaryProvider).monthExpense,
                    ),
                  ),
                ),
                Expanded(
                  child: _FundraiseStat(
                    label: s.runwayMonths,
                    value:
                        '${ref.watch(moneySummaryProvider).runwayMonths.toStringAsFixed(1)} ${s.months}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: FvSpacing.x3),
            Text(
              s.fundraisingTip,
              style: TextStyle(fontSize: 11, color: context.fvTextSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _FundraiseStat extends StatelessWidget {
  const _FundraiseStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(fontSize: 11, color: context.fvTextSecondary),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: context.fvText,
        ),
      ),
    ],
  );
}

/// Grant opportunity card for Female Founder
class GrantOpportunityCard extends ConsumerWidget {
  const GrantOpportunityCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);

    return FvCard(
      margin: const EdgeInsets.only(bottom: FvSpacing.x4),
      onTap: () => ref.read(homeTabIndexProvider.notifier).state = 1,
      child: Padding(
        padding: const EdgeInsets.all(FvSpacing.x4),
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
                  child: Icon(
                    Icons.emoji_events_outlined,
                    color: context.fvPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: FvSpacing.x3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.femaleSeedFund,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.femaleSeedBlurb,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, size: 18),
              ],
            ),
            const SizedBox(height: FvSpacing.x3),
            Text(
              s.grantDeadlines,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.fvText,
              ),
            ),
            const SizedBox(height: FvSpacing.x2),
            ..._grants.map(
              (g) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: FvColors.primary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: FvSpacing.x3),
                    Expanded(
                      child: Text(
                        g.name,
                        style: TextStyle(fontSize: 12, color: context.fvText),
                      ),
                    ),
                    Text(
                      g.deadline,
                      style: TextStyle(
                        fontSize: 11,
                        color: context.fvTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Grant {
  const _Grant(this.name, this.deadline);
  final String name;
  final String deadline;
}

final _grants = [
  _Grant('Female Innovators Seed Fund', 'Oct 15, 2026'),
  _Grant('SheWins Africa', 'Nov 30, 2026'),
  _Grant('MRA Women Entrepreneur Grant', 'Dec 31, 2026'),
  _Grant('AfDB AFAWA', 'Rolling'),
];

// ---- Individual --------------------------------------------------------------

class _PensionTile extends ConsumerWidget {
  const _PensionTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    final plan = ref.watch(pensionPlanProvider);
    final projection = ref.watch(pensionProjectionProvider);
    final language = ref.watch(preferencesProvider).language;
    final hasPlan = plan.value != null;

    final current =
        (plan.value?.currentShortPot ?? 0) + (plan.value?.currentLongPot ?? 0);
    final target =
        (plan.value?.shortPotTarget ?? 0) + (plan.value?.longPotTarget ?? 0);
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
                child: Icon(
                  Icons.account_balance_outlined,
                  color: context.fvPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: FvSpacing.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.pension,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasPlan
                          ? s.pensionProjected(
                              FvFormat.formatMoney(
                                projection.totalProjected,
                                language: language,
                              ),
                            )
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
    final s = AppLocalizations.of(context);
    final summary = ref.watch(moneySummaryProvider);
    final goals = ref.watch(goalsProvider);
    final security = ref.watch(securityOverviewProvider);
    final language = ref.watch(preferencesProvider).language;

    final goal =
        goals.value?.where((g) => !g.completed).firstOrNull ??
        goals.value?.firstOrNull;
    final pct = goal != null && goal.targetAmount > 0
        ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeroCard(
          label: s.totalNetWorth,
          amount: summary.totalBalance,
          currency: 'MUR',
        ),
        FvCard(
          margin: const EdgeInsets.only(bottom: FvSpacing.x4),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: s.securityScore,
                      value: security.value == null
                          ? '—'
                          : '${security.value!.score}',
                      sub: FvFormat.formatPercent(pct),
                    ),
                  ),
                  const SizedBox(width: FvSpacing.x4, height: 0),
                  Container(width: 1, height: 44, color: context.fvBorder),
                  const SizedBox(width: FvSpacing.x4, height: 0),
                  Column(
                    children: [
                      ProgressRing(progress: pct, size: 56, stroke: 6),
                      const SizedBox(height: 4),
                      Text(
                        '${((pct * 100).round())}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.fvTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        QuickActionsRow(
          actions: [
            QuickAction(
              s.qaSend,
              Icons.send_outlined,
              () => openTransfer(context),
            ),
            QuickAction(
              s.qaSave,
              Icons.savings_outlined,
              () => openNewGoal(context),
            ),
            QuickAction(
              s.payBill,
              Icons.receipt_long_outlined,
              () => openBills(context),
            ),
            QuickAction(
              s.insights,
              Icons.psychology_outlined,
              () => ref.read(homeTabIndexProvider.notifier).state = 1,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(
            bottom: FvSpacing.x3,
            top: FvSpacing.x2,
          ),
          child: Text(
            s.spendingVsBudget,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: context.fvText,
            ),
          ),
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
                ? s.goalAmountTarget(
                    FvFormat.formatMoney(goal.targetAmount, language: language),
                  )
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
    final s = AppLocalizations.of(context);
    final summary = ref.watch(moneySummaryProvider);
    final goals = ref.watch(goalsProvider);

    final runway = summary.monthExpense > 0
        ? summary.runwayMonths.round().toString()
        : '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeroCard(
          label: s.incomeThisMonth,
          amount: summary.monthIncome,
          currency: 'MUR',
        ),
        StatPair(
          left: StatCard(
            label: s.unpaidInvoices,
            value: '${summary.unpaidInvoiceCount}',
            sub: summary.unpaidInvoiceTotal == 0
                ? s.allSettled
                : FvFormat.formatMoney(summary.unpaidInvoiceTotal),
          ),
          right: StatCard(
            label: s.taxEstimate,
            amount: summary.taxEstimate,
            currency: 'MUR',
            sub: s.approxTax,
          ),
        ),
        StatPair(
          left: StatCard(
            label: s.runwayLabel,
            value: runway,
            sub: s.monthsOfCover,
          ),
          right: StatCard(
            label: s.activeProjects,
            value: '${goals.value?.length ?? 0}',
            sub: s.acrossYourVault,
          ),
        ),
        QuickActionsRow(
          actions: [
            QuickAction(s.qaAddInvoice, Icons.add, () => openInvoices(context)),
            QuickAction(
              s.qaSetAsideTax,
              Icons.umbrella_outlined,
              () => openNewGoal(context),
            ),
            QuickAction(
              s.qaTransfer,
              Icons.send_outlined,
              () => openTransfer(context),
            ),
            QuickAction(
              s.qaCoach,
              Icons.psychology_outlined,
              () => ref.read(homeTabIndexProvider.notifier).state = 1,
            ),
          ],
        ),
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
    final s = AppLocalizations.of(context);
    final summary = ref.watch(moneySummaryProvider);

    final runway = summary.monthExpense > 0
        ? summary.runwayMonths.round().toString()
        : '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeroCard(
          label: s.combinedWealth,
          amount: summary.totalBalance,
          currency: 'MUR',
        ),
        StatPair(
          left: StatCard(
            label: s.revenueMrr,
            amount: summary.monthIncome,
            currency: 'MUR',
          ),
          right: StatCard(
            label: s.runwayLabel,
            value: runway,
            sub: s.monthsOfCover,
          ),
        ),
        StatPair(
          left: StatCard(
            label: s.burnRate,
            amount: summary.monthExpense,
            currency: 'MUR',
            sub: s.perMonth,
          ),
          right: StatCard(
            label: s.savedInGoalsLabel,
            amount: summary.savedInGoals,
            currency: 'MUR',
          ),
        ),
        QuickActionsRow(
          actions: [
            QuickAction(
              s.qaCashFlow,
              Icons.trending_up,
              () => openTransactions(context),
            ),
            QuickAction(s.qaGrants, Icons.business_center_outlined, () {}),
            QuickAction(
              s.qaTransfer,
              Icons.send_outlined,
              () => openTransfer(context),
            ),
            QuickAction(
              s.qaCoach,
              Icons.psychology_outlined,
              () => ref.read(homeTabIndexProvider.notifier).state = 1,
            ),
          ],
        ),
        _SectionTitle(s.businessMetrics),
        const MrrArrCard(),
        const BurnMultipleCard(),
        const FundraisingTrackerCard(),
        if (femaleFounder) ...[
          _SectionTitle(s.opportunitiesLabel),
          const GrantOpportunityCard(),
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
    final s = AppLocalizations.of(context);
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
    final vendorSpend =
        vendors.value?.fold<double>(0, (a, v) => a + v.totalSpend) ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeroCard(
          label: s.cashPosition,
          amount: summary.totalBalance,
          currency: 'MUR',
        ),
        StatPair(
          left: StatCard(
            label: s.revenue,
            amount: summary.monthIncome,
            currency: 'MUR',
          ),
          right: StatCard(
            label: s.runwayLabel,
            value: runway == null ? '—' : '$runway',
            sub: s.monthsOfCover,
          ),
        ),
        StatPair(
          left: StatCard(
            label: s.burnRate,
            amount: summary.monthExpense,
            currency: 'MUR',
            sub: s.perMonth,
          ),
          right: StatCard(
            label: s.savedInGoalsLabel,
            amount: summary.savedInGoals,
            currency: 'MUR',
          ),
        ),
        QuickActionsRow(
          actions: [
            QuickAction(
              s.qaPayVendor,
              Icons.send_outlined,
              () => openVendors(context),
            ),
            QuickAction(
              s.qaRecordInvoice,
              Icons.add,
              () => openInvoices(context),
            ),
            QuickAction(
              s.qaCashFlow,
              Icons.trending_up,
              () => openTransactions(context),
            ),
            QuickAction(
              s.qaAdvisor,
              Icons.psychology_outlined,
              () => ref.read(homeTabIndexProvider.notifier).state = 1,
            ),
          ],
        ),
        _SectionTitle(s.businessMetrics),
        const CashFlowForecastCard(),
        const VendorParetoCard(),
        const ComplianceCalendarCard(),
        const PayrollEfficiencyCard(),
        Padding(
          padding: const EdgeInsets.only(
            bottom: FvSpacing.x3,
            top: FvSpacing.x2,
          ),
          child: Text(
            s.needsAttention,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: context.fvText,
            ),
          ),
        ),
        FvCard(
          margin: const EdgeInsets.only(bottom: FvSpacing.x4),
          child: attention.isEmpty
              ? Text(
                  s.allClear,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.fvTextSecondary,
                  ),
                )
              : Column(
                  children: [
                    for (final item in attention)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: FvSpacing.x2,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: context.fvWarning,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: FvSpacing.x3),
                            Expanded(
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.fvText,
                                ),
                              ),
                            ),
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
              Expanded(
                child: Text(
                  s.vendors,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: context.fvText,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => openVendors(context),
                child: Text(
                  s.add,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.fvPrimary,
                  ),
                ),
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
                child: Icon(
                  Icons.business_center_outlined,
                  size: 18,
                  color: context.fvPrimary,
                ),
              ),
              const SizedBox(width: FvSpacing.x3),
              Expanded(
                child: Text(
                  '$vendorCount · ${FvFormat.formatMoney(vendorSpend)}',
                  style: TextStyle(fontSize: 14, color: context.fvText),
                ),
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
    final s = AppLocalizations.of(context);
    return FvCard(
      onTap: () => openAccounts(context),
      margin: const EdgeInsets.only(bottom: FvSpacing.x4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: context.fvWash,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.fvCardBorder),
            ),
            child: Icon(
              Icons.link_outlined,
              size: 18,
              color: context.fvPrimary,
            ),
          ),
          const SizedBox(width: FvSpacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.linkAccount,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.fvText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s.seeEverything,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.fvTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 16),
        ],
      ),
    );
  }
}
