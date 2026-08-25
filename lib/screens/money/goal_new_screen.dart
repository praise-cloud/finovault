import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/providers.dart';
import '../../core/state/money.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';

class GoalNewScreen extends ConsumerStatefulWidget {
  const GoalNewScreen({super.key});

  @override
  ConsumerState<GoalNewScreen> createState() => _GoalNewScreenState();
}

class _GoalNewScreenState extends ConsumerState<GoalNewScreen> {
  final _name = TextEditingController();
  final _target = TextEditingController();
  GoalType _type = GoalType.general;

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenPage(
      title: 'New goal',
      child: ListView(
        padding: const EdgeInsets.all(FvSpacing.x5),
        children: [
          FvTextField(label: 'Goal name', controller: _name, hint: 'Emergency Fund'),
          const SizedBox(height: FvSpacing.x4),
          FvTextField(label: 'Target amount', controller: _target, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          const SizedBox(height: FvSpacing.x4),
          const Text('Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          DropdownButtonFormField<GoalType>(
            initialValue: _type,
            items: GoalType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
            onChanged: (v) => setState(() => _type = v!),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(FvRadius.input)),
              contentPadding: const EdgeInsets.symmetric(horizontal: FvSpacing.x4, vertical: FvSpacing.x3),
            ),
          ),
          const SizedBox(height: FvSpacing.x6),
          FvButton(
            label: 'Create goal',
            onPressed: () async {
              final api = ref.read(apiProvider);
              final token = ref.read(kvStoreProvider).getString(sessionKey);
              final target = double.tryParse(_target.text.replaceAll(',', '')) ?? 0;
              if (_name.text.isEmpty || target <= 0) return;
              await api.createGoal(token, name: _name.text, type: _type, targetAmount: target);
              ref.invalidate(goalsProvider);
              if (mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
