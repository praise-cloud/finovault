import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/providers.dart';
import '../../core/state/money.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';

class PensionSetupScreen extends ConsumerStatefulWidget {
  const PensionSetupScreen({super.key});

  @override
  ConsumerState<PensionSetupScreen> createState() => _PensionSetupScreenState();
}

class _PensionSetupScreenState extends ConsumerState<PensionSetupScreen> {
  final _shortTarget = TextEditingController();
  final _longTarget = TextEditingController();
  final _amount = TextEditingController();
  final _return = TextEditingController();
  final _inflation = TextEditingController();
  final _age = TextEditingController();
  final _retire = TextEditingController();
  PensionFrequency _frequency = PensionFrequency.monthly;
  bool _autoDebit = true;

  @override
  void initState() {
    super.initState();
    final plan = ref.read(pensionPlanProvider).value;
    if (plan != null) {
      _shortTarget.text = plan.shortPotTarget.round().toString();
      _longTarget.text = plan.longPotTarget.round().toString();
      _amount.text = plan.contributionAmount.round().toString();
      _return.text = plan.assumedReturnPct.toStringAsFixed(0);
      _inflation.text = plan.inflationPct.toStringAsFixed(0);
      _age.text = plan.currentAge.toString();
      _retire.text = plan.retirementAge.toString();
      _frequency = plan.frequency;
      _autoDebit = plan.autoDebit;
    } else {
      _return.text = '7';
      _inflation.text = '4';
      _age.text = '30';
      _retire.text = '65';
    }
  }

  @override
  void dispose() {
    _shortTarget.dispose();
    _longTarget.dispose();
    _amount.dispose();
    _return.dispose();
    _inflation.dispose();
    _age.dispose();
    _retire.dispose();
    super.dispose();
  }

  double _num(TextEditingController c, [double fallback = 0]) =>
      double.tryParse(c.text.replaceAll(',', '')) ?? fallback;

  @override
  Widget build(BuildContext context) {
    final isEdit = ref.watch(pensionPlanProvider).value != null;
    return ScreenPage(
      title: isEdit ? 'Edit pension' : 'Set up pension',
      child: ListView(
        padding: const EdgeInsets.all(FvSpacing.x5),
        children: [
          const Text('Short-term pot', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          FvTextField(label: 'Target (MUR)', controller: _shortTarget, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          const SizedBox(height: FvSpacing.x4),
          const Text('Long-term pot', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          FvTextField(label: 'Target (MUR)', controller: _longTarget, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          const SizedBox(height: FvSpacing.x4),
          FvTextField(label: 'Contribution per period (MUR)', controller: _amount, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          const SizedBox(height: FvSpacing.x4),
          const Text('Frequency', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          DropdownButtonFormField<PensionFrequency>(
            initialValue: _frequency,
            items: PensionFrequency.values
                .map((f) => DropdownMenuItem(value: f, child: Text(f.name[0].toUpperCase() + f.name.substring(1))))
                .toList(),
            onChanged: (v) => setState(() => _frequency = v!),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(FvRadius.input)),
              contentPadding: const EdgeInsets.symmetric(horizontal: FvSpacing.x4, vertical: FvSpacing.x3),
            ),
          ),
          const SizedBox(height: FvSpacing.x4),
          Row(
            children: [
              Expanded(child: FvTextField(label: 'Return %', controller: _return, keyboardType: const TextInputType.numberWithOptions(decimal: true))),
              const SizedBox(width: FvSpacing.x3),
              Expanded(child: FvTextField(label: 'Inflation %', controller: _inflation, keyboardType: const TextInputType.numberWithOptions(decimal: true))),
            ],
          ),
          const SizedBox(height: FvSpacing.x4),
          Row(
            children: [
              Expanded(child: FvTextField(label: 'Current age', controller: _age, keyboardType: TextInputType.number)),
              const SizedBox(width: FvSpacing.x3),
              Expanded(child: FvTextField(label: 'Retirement age', controller: _retire, keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: FvSpacing.x4),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Auto-debit contributions'),
            value: _autoDebit,
            activeThumbColor: FvColors.primary,
            onChanged: (v) => setState(() => _autoDebit = v),
          ),
          const SizedBox(height: FvSpacing.x5),
          FvButton(
            label: isEdit ? 'Save changes' : 'Create plan',
            onPressed: () async {
              final api = ref.read(apiProvider);
              final token = ref.read(kvStoreProvider).getString(sessionKey);
              final plan = await api.upsertPensionPlan(
                token,
                shortPotTarget: _num(_shortTarget),
                longPotTarget: _num(_longTarget),
                frequency: _frequency,
                contributionAmount: _num(_amount),
                currentShortPot: ref.read(pensionPlanProvider).value?.currentShortPot ?? 0,
                currentLongPot: ref.read(pensionPlanProvider).value?.currentLongPot ?? 0,
                assumedReturnPct: _num(_return, 7),
                inflationPct: _num(_inflation, 4),
                currentAge: _num(_age, 30).round(),
                retirementAge: _num(_retire, 65).round(),
                autoDebit: _autoDebit,
              );
              ref.invalidate(pensionPlanProvider);
              ref.invalidate(pensionProjectionProvider);
              if (context.mounted) {
                Navigator.of(context).pop(plan);
              }
            },
          ),
        ],
      ),
    );
  }
}
