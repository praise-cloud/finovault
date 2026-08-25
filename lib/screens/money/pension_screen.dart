import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/format.dart';
import '../../core/state/money.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';
import 'pension_setup_screen.dart';

class PensionScreen extends ConsumerStatefulWidget {
  const PensionScreen({super.key});

  @override
  ConsumerState<PensionScreen> createState() => _PensionScreenState();
}

class _PensionScreenState extends ConsumerState<PensionScreen> {
  void _contribute(BuildContext context) {
    final plan = ref.read(pensionPlanProvider).value;
    if (plan == null) return;
    final accounts = ref.read(accountsProvider).value ?? [];
    if (accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link an account first to contribute.')));
      return;
    }

    String pot = 'short';
    final amount = TextEditingController();
    String source = accounts.first.id;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.fvIsDark ? FvColors.bgDark : FvColors.surface,
      builder: (sheet) => StatefulBuilder(
        builder: (ctx, set) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheet).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(FvSpacing.x5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text('Contribute', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: FvSpacing.x4),
                const Text('Pot', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'short', label: Text('Short-term')),
                    ButtonSegment(value: 'long', label: Text('Long-term')),
                  ],
                  selected: {pot},
                  onSelectionChanged: (v) => set(() => pot = v.first),
                ),
                const SizedBox(height: FvSpacing.x4),
                FvTextField(
                  label: 'Amount',
                  controller: amount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: FvSpacing.x4),
                DropdownButtonFormField<String>(
                  initialValue: source,
                  items: accounts
                      .map((a) => DropdownMenuItem(value: a.id, child: Text('${a.name} (${FvFormat.formatMoney(a.balance)})')))
                      .toList(),
                  onChanged: (v) => source = v!,
                  decoration: InputDecoration(
                    labelText: 'From account',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(FvRadius.input)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: FvSpacing.x4, vertical: FvSpacing.x3),
                  ),
                ),
                const SizedBox(height: FvSpacing.x5),
                FvButton(
                  label: 'Contribute',
                  onPressed: () async {
                    final value = double.tryParse(amount.text.replaceAll(',', '')) ?? 0;
                    if (value <= 0) return;
                    final api = ref.read(apiProvider);
                    final token = ref.read(kvStoreProvider).getString(sessionKey);
                    await api.contributePension(token, pot: pot, amount: value, sourceAccountId: source);
                    ref.invalidate(pensionPlanProvider);
                    ref.invalidate(pensionContributionsProvider);
                    ref.invalidate(accountsProvider);
                    if (sheet.mounted) Navigator.of(sheet).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plan = ref.watch(pensionPlanProvider);
    final projection = ref.watch(pensionProjectionProvider);
    final contributions = ref.watch(pensionContributionsProvider);

    return ScreenPage(
      title: AppLocalizations.of(context)!.pension,
      actions: [
        if (plan.value != null)
          IconButton(icon: const Icon(Icons.edit_outlined, color: FvColors.primary), onPressed: () => pushScreen(context, const PensionSetupScreen()))
      ],
      child: plan.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load: $e')),
        data: (p) => p == null
            ? EmptyState(
                title: 'No pension plan yet',
                body: 'Start a flexible micro-pension and split savings into a short-term and a long-term pot.',
                ctaLabel: 'Set up pension',
                onCta: () => pushScreen(context, const PensionSetupScreen()),
              )
            : ListView(
                padding: const EdgeInsets.all(FvSpacing.x5),
                children: [
                  FvCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Projected at retirement', style: TextStyle(fontSize: 13, color: FvColors.textSecondary)),
                        const SizedBox(height: 4),
                        MoneyText(projection.totalProjected, size: MoneySize.xl, currency: 'MUR'),
                        const SizedBox(height: 2),
                        Text('in ${projection.yearsToRetirement} years (today’s money)',
                            style: const TextStyle(fontSize: 13, color: FvColors.textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: FvSpacing.x4),
                  Row(
                    children: [
                      Expanded(child: _PotCard(title: 'Short-term pot', current: p.currentShortPot, target: p.shortPotTarget)),
                      const SizedBox(width: FvSpacing.x3),
                      Expanded(child: _PotCard(title: 'Long-term pot', current: p.currentLongPot, target: p.longPotTarget)),
                    ],
                  ),
                  const SizedBox(height: FvSpacing.x4),
                  FvCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Row(label: 'Contribution', value: '${p.frequency.name} · ${FvFormat.formatMoney(p.contributionAmount)}'),
                        _Row(label: 'Assumed return', value: '${p.assumedReturnPct.toStringAsFixed(0)}%'),
                        _Row(label: 'Inflation', value: '${p.inflationPct.toStringAsFixed(0)}%'),
                        _Row(label: 'Auto-debit', value: p.autoDebit ? 'On' : 'Off'),
                      ],
                    ),
                  ),
                  const SizedBox(height: FvSpacing.x5),
                  FvButton(label: 'Contribute', onPressed: () => _contribute(context)),
                  const SizedBox(height: FvSpacing.x5),
                  const Text('Recent contributions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: FvSpacing.x3),
                  contributions.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Could not load: $e'),
                    data: (list) => list.isEmpty
                        ? const Text('No contributions yet.', style: TextStyle(color: FvColors.textSecondary))
                        : Column(
                            children: [
                              for (final c in list.take(8))
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(c.pot == 'short' ? Icons.hourglass_bottom : Icons.account_balance, color: FvColors.primary),
                                  title: Text('${c.pot == 'short' ? 'Short-term' : 'Long-term'} pot'),
                                  subtitle: Text(FvFormat.formatDate(c.date)),
                                  trailing: MoneyText(c.amount, currency: 'MUR'),
                                ),
                            ],
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text(label, style: const TextStyle(color: FvColors.textSecondary))),
            const SizedBox(width: 8),
            Flexible(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      );
}

class _PotCard extends StatelessWidget {
  const _PotCard({required this.title, required this.current, required this.target});
  final String title;
  final double current;
  final double target;

  @override
  Widget build(BuildContext context) {
    final progress = target <= 0 ? 0.0 : (current / target).clamp(0.0, 1.0);
    return FvCard(
      child: Column(
        children: [
          ProgressRing(progress: progress, size: 64, child: Text('${(progress * 100).round()}%')),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12, color: FvColors.textSecondary)),
          const SizedBox(height: 2),
          MoneyText(current, size: MoneySize.sm, currency: 'MUR'),
        ],
      ),
    );
  }
}

