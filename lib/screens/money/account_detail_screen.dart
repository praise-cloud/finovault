import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../core/state/auth.dart';
import '../../core/state/money.dart';
import '../../theme/tokens.dart';
import '../../widgets/components.dart';
import '../../widgets/ui.dart';

class AccountDetailScreen extends ConsumerStatefulWidget {
  const AccountDetailScreen({super.key, required this.accountId});

  final String accountId;

  @override
  ConsumerState<AccountDetailScreen> createState() =>
      _AccountDetailScreenState();
}

class _AccountDetailScreenState extends ConsumerState<AccountDetailScreen> {
  final _q = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider);
    final all = ref.watch(transactionsProvider);
    final role =
        ref.watch(currentUserProvider)?.primaryRole ?? PrimaryRole.individual;
    final accent = FvColors.roleAccent(role);
    final s = AppLocalizations.of(context);

    final account = accounts.whenOrNull(
      data: (list) => list.where((a) => a.id == widget.accountId).firstOrNull,
    );

    final txns =
        all.whenOrNull(
          data: (list) =>
              list.where((t) => t.accountId == widget.accountId).toList(),
        ) ??
        [];
    final q = _q.text.toLowerCase();
    final shown = q.isEmpty
        ? txns
        : txns
              .where(
                (t) => (t.merchantName ?? t.category).toLowerCase().contains(q),
              )
              .toList();

    return ScreenPage(
      title: account?.name ?? s.accounts,
      actions: [
        if (account != null)
          IconButton(
            icon: Icon(Icons.delete_outline, size: 18, color: context.fvError),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final token = ref.read(kvStoreProvider).getString(sessionKey);
              await ref.read(apiProvider).unlinkAccount(token, account.id);
              ref.invalidate(accountsProvider);
              if (mounted) navigator.pop();
            },
          ),
      ],
      child: accounts.when(
        loading: () =>
            const Center(child: FvShimmer(height: 120, radius: FvRadius.card)),
        error: (e, _) => Center(child: Text('Could not load: $e')),
        data: (_) {
          if (account == null) return Center(child: Text(s.accountNotFound));
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: FvSpacing.x4),
                padding: const EdgeInsets.all(FvSpacing.x5),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(FvRadius.card),
                  border: Border.all(
                    color: context.fvCardBorder,
                    width: FvBorders.width,
                  ),
                  boxShadow: context.fvBrutal,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(width: 9, height: 9, color: FvColors.ink),
                        const SizedBox(width: 8),
                        Text(
                          (account.institution ?? account.type.name)
                              .toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    MoneyText(
                      account.balance,
                      size: MoneySize.xl,
                      color: Colors.white,
                      currency: 'MUR',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${account.name} · ${account.type.name.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              SectionHeader(title: s.balanceTrend),
              FvCard(
                margin: const EdgeInsets.only(bottom: FvSpacing.x4),
                child: SizedBox(
                  height: 160,
                  child: txns.length < 2
                      ? Center(
                          child: Text(
                            s.notEnoughHistory,
                            style: TextStyle(
                              fontSize: 13,
                              color: context.fvTextSecondary,
                            ),
                          ),
                        )
                      : _trend(accent, account, txns),
                ),
              ),
              SectionHeader(title: s.transactions),
              Padding(
                padding: const EdgeInsets.only(bottom: FvSpacing.x3),
                child: TextField(
                  controller: _q,
                  onChanged: (_) => setState(() {}),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.fvText,
                  ),
                  decoration: InputDecoration(
                    hintText: s.searchHint,
                    hintStyle: TextStyle(color: context.fvTextSecondary),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 18,
                      color: context.fvText,
                    ),
                    filled: true,
                    fillColor: context.fvSurface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: FvSpacing.x4,
                      vertical: FvSpacing.x3,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(FvRadius.input),
                      borderSide: BorderSide(
                        color: context.fvCardBorder,
                        width: FvBorders.width,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(FvRadius.input),
                      borderSide: BorderSide(
                        color: context.fvCardBorder,
                        width: FvBorders.width,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(FvRadius.input),
                      borderSide: BorderSide(
                        color: context.fvPrimary,
                        width: FvBorders.width,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: shown.isEmpty
                    ? Center(
                        child: EmptyState(
                          title: s.noTransactionsTitle,
                          body: s.noTransactionsBody,
                        ),
                      )
                    : ListView.separated(
                        itemCount: shown.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: FvSpacing.x2),
                        itemBuilder: (_, i) => FvTransactionRow(txn: shown[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _trend(Color accent, Account account, List<Transaction> txns) {
    final asc = [...txns]..sort((a, b) => a.date.compareTo(b.date));
    final effects = asc
        .map(
          (t) => t.direction == TransactionDirection.inn ? t.amount : -t.amount,
        )
        .toList();
    final start = account.balance - effects.fold<double>(0, (s, e) => s + e);
    double bal = start;
    final spots = <FlSpot>[FlSpot(0, start)];
    for (var i = 0; i < asc.length; i++) {
      bal += effects[i];
      spots.add(FlSpot((i + 1).toDouble(), bal));
    }
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: accent,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: accent.withValues(alpha: 0.12),
            ),
          ),
        ],
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
      ),
    );
  }
}
