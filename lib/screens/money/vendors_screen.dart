import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/providers.dart';
import '../../core/state/money.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';

class VendorsScreen extends ConsumerStatefulWidget {
  const VendorsScreen({super.key});

  @override
  ConsumerState<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends ConsumerState<VendorsScreen> {
  @override
  Widget build(BuildContext context) {
    final vendors = ref.watch(vendorsProvider);

    return ScreenPage(
      title: 'Vendors',
      actions: [IconButton(icon: const Icon(Icons.add, color: FvColors.primary), onPressed: _add)],
      child: vendors.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load: $e')),
        data: (list) => list.isEmpty
            ? const Center(
                child: EmptyState(title: 'No vendors yet', body: 'Add the businesses you pay regularly to track reliability and spend.'),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(FvSpacing.x5),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: FvSpacing.x3),
                itemBuilder: (_, i) {
                  final v = list[i];
                  return FvCard(
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(color: FvColors.wash, borderRadius: BorderRadius.circular(FvRadius.iconContainer)),
                          child: const Icon(Icons.business_center_outlined, size: 20, color: FvColors.primary),
                        ),
                        const SizedBox(width: FvSpacing.x3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(v.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.fvText)),
                              const SizedBox(height: 2),
                              Text('Reliability ${v.reliabilityScore}/100 · ${FvFormat.formatMoney(v.totalSpend)}', style: TextStyle(fontSize: 12.5, color: context.fvTextSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _add() {
    final name = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.fvIsDark ? FvColors.bgDark : FvColors.surface,
      builder: (sheet) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheet).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(FvSpacing.x5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: Text('Add vendor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
              const SizedBox(height: FvSpacing.x4),
              FvTextField(label: 'Vendor name', controller: name, hint: 'Print Hub Ltd'),
              const SizedBox(height: FvSpacing.x5),
              FvButton(
                label: 'Add vendor',
                onPressed: () async {
                  final api = ref.read(apiProvider);
                  final token = ref.read(kvStoreProvider).getString(sessionKey);
                  if (name.text.isEmpty) return;
                  await api.createVendor(token, name: name.text);
                  ref.invalidate(vendorsProvider);
                  if (sheet.mounted) Navigator.of(sheet).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
