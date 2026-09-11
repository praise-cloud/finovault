import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/format.dart';
import '../../core/models.dart';
import '../../core/mock/api.dart';
import '../../core/providers.dart';
import '../../core/state/money.dart';
import '../../core/state/preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final _amount = TextEditingController();
  final _destination = TextEditingController();
  final _payeeNameController = TextEditingController();
  String? _sourceId;
  bool _verifying = false;

  static final _phonePattern = RegExp(r'^[5-7]\d{4,7}$');

  @override
  void dispose() {
    _amount.dispose();
    _destination.dispose();
    _payeeNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider);
    final payees = ref.watch(payeesProvider);
    final language = ref.watch(preferencesProvider).language;

    return ScreenPage(
      title: 'Transfer',
      child: accounts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: EmptyState(
                title: 'Link an account first',
                body: 'You need a linked account to send money.',
              ),
            );
          }
          _sourceId ??= list.first.id;
          final source = list.firstWhere(
            (a) => a.id == _sourceId,
            orElse: () => list.first,
          );
          final raw = double.tryParse(_amount.text.replaceAll(',', '')) ?? 0;
          final fee = raw > 0 ? (raw * 0.015).clamp(20.0, 500.0) : 0.0;
          final total = raw + fee;

          return ListView(
            padding: const EdgeInsets.all(FvSpacing.x5),
            children: [
              FvCard(
                margin: const EdgeInsets.only(bottom: FvSpacing.x4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'From',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _sourceId,
                      isExpanded: true,
                      selectedItemBuilder: (_) => list
                          .map(
                            (a) => Text(
                              '${a.name} (${FvFormat.formatMoney(a.balance, language: language)})',
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                          )
                          .toList(),
                      items: list
                          .map(
                            (a) => DropdownMenuItem(
                              value: a.id,
                              child: Text(
                                '${a.name} (${FvFormat.formatMoney(a.balance, language: language)})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _sourceId = v),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(FvRadius.input),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: FvSpacing.x4,
                          vertical: FvSpacing.x3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              FvTextField(
                label: 'Amount',
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: FvSpacing.x4),
              if (payees.value != null && payees.value!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'To (payee)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: payees.value!
                          .map(
                            (p) => ChoiceChip(
                              label: Text(p.name),
                              selected: _payeeNameController.text == p.name,
                              selectedColor: context.fvWash,
                              onSelected: (_) => setState(() {
                                _payeeNameController.text = p.name;
                                _destination.text = p.destination ?? '';
                              }),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: FvSpacing.x4),
                  ],
                ),
              FvTextField(
                label: 'Payee name',
                controller: _payeeNameController,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: FvSpacing.x4),
              FvTextField(
                label: 'Destination / account',
                controller: _destination,
                hint: 'Phone or IBAN',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: FvSpacing.x4),
              if (raw > 0)
                FvCard(
                  margin: const EdgeInsets.only(bottom: FvSpacing.x4),
                  child: Column(
                    children: [
                      _FeeRow(
                        label: 'Amount',
                        value: FvFormat.formatMoney(raw, language: language),
                      ),
                      _FeeRow(
                        label: 'Fee (1.5%, min 20 / max 500)',
                        value: FvFormat.formatMoney(fee, language: language),
                      ),
                      const Divider(),
                      _FeeRow(
                        label: 'Total',
                        value: FvFormat.formatMoney(total, language: language),
                        bold: true,
                      ),
                    ],
                  ),
                ),
              FvButton(
                label: 'Continue',
                loading: _verifying,
                onPressed:
                    raw <= 0 ||
                        _destination.text.isEmpty ||
                        _payeeNameController.text.isEmpty ||
                        _verifying
                    ? null
                    : () => _continue(context, ref, source.id, raw, fee),
              ),
              const SizedBox(height: FvSpacing.x3),
              FvButton(
                label: 'Pay via bank app',
                variant: FvButtonVariant.secondary,
                onPressed: raw <= 0 || _payeeNameController.text.isEmpty
                    ? null
                    : () => _openBankApp(context, ref, source.id, raw),
              ),
              const SizedBox(height: FvSpacing.x3),
              FvButton(
                label: 'MauCAS QR',
                variant: FvButtonVariant.secondary,
                onPressed: raw <= 0 || _payeeNameController.text.isEmpty
                    ? null
                    : () => _showMauCasQr(context, ref, raw),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Opens the linked bank app to complete the payment externally.
  Future<void> _openBankApp(
    BuildContext context,
    WidgetRef ref,
    String sourceId,
    double amount,
  ) async {
    final api = ref.read(apiProvider);
    final token = ref.read(kvStoreProvider).getString(sessionKey);
    try {
      final link = await api.generatePaymentLink(
        token,
        accountId: sourceId,
        amount: amount,
        recipient: _payeeNameController.text.trim(),
      );
      if (!context.mounted) return;
      final ok = await launchUrl(Uri.parse(link.deepLink));
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the bank app.')),
        );
      }
    } on FvApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  /// Shows a QR code the other party can scan to pull the amount.
  Future<void> _showMauCasQr(
    BuildContext context,
    WidgetRef ref,
    double amount,
  ) async {
    final api = ref.read(apiProvider);
    final token = ref.read(kvStoreProvider).getString(sessionKey);
    try {
      final result = await api.generateMauCasQr(
        token,
        amount: amount,
        recipient: _payeeNameController.text.trim(),
      );
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (dialog) => AlertDialog(
          title: const Text('MauCAS QR'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(data: result.qrData, size: 220),
              const SizedBox(height: FvSpacing.x3),
              Text(
                result.qrData,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: context.fvTextSecondary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialog).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } on FvApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  /// Phone destinations are verified against the registered holder name
  /// before confirmation; IBAN/bank destinations go straight through.
  Future<void> _continue(
    BuildContext context,
    WidgetRef ref,
    String sourceId,
    double amount,
    double fee,
  ) async {
    final s = AppLocalizations.of(context);
    final destination = _destination.text.replaceAll(RegExp(r'\s'), '');

    if (_phonePattern.hasMatch(destination)) {
      setState(() => _verifying = true);
      try {
        final api = ref.read(apiProvider);
        final token = ref.read(kvStoreProvider).getString(sessionKey);
        final check = await api.verifyAccount(
          token,
          institution: 'juice',
          identifier: destination,
          holderName: _payeeNameController.text.trim(),
        );
        if (!context.mounted) return;
        if (!check.verified) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(check.exists ? s.verifyMismatch : s.verifyNotFound),
            ),
          );
          return;
        }
        _confirm(
          context,
          ref,
          sourceId,
          amount,
          fee,
          holderName: check.holderName,
        );
      } on FvApiException catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.message)));
        }
      } finally {
        if (context.mounted) setState(() => _verifying = false);
      }
      return;
    }

    _confirm(context, ref, sourceId, amount, fee);
  }

  void _confirm(
    BuildContext context,
    WidgetRef ref,
    String sourceId,
    double amount,
    double fee, {
    String? holderName,
  }) {
    final s = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Confirm transfer'),
        content: Text(
          holderName == null
              ? 'Send ${FvFormat.formatMoney(amount)} to ${_payeeNameController.text}?'
              : 'Send ${FvFormat.formatMoney(amount)} to ${_payeeNameController.text}?'
                    '\n${s.verifyVerifiedAs(holderName)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialog).pop();
              final api = ref.read(apiProvider);
              final token = ref.read(kvStoreProvider).getString(sessionKey);
              try {
                final transfer = await api.createTransfer(
                  token,
                  sourceAccountId: sourceId,
                  payeeName: _payeeNameController.text,
                  destination: _destination.text,
                  amount: amount,
                  idempotencyKey:
                      '${DateTime.now().microsecondsSinceEpoch}-${_payeeNameController.text}',
                  holderName: holderName,
                );
                ref.invalidate(accountsProvider);
                ref.invalidate(transfersProvider);
                ref.invalidate(transactionsProvider);
                if (context.mounted) {
                  await pushScreen(
                    context,
                    TransferReceiptScreen(transfer: transfer),
                  );
                }
              } on FvApiException catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.message)));
                }
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  const _FeeRow({required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              color: context.fvTextSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            color: bold ? context.fvText : context.fvTextSecondary,
          ),
        ),
      ],
    ),
  );
}

class TransferReceiptScreen extends StatelessWidget {
  const TransferReceiptScreen({super.key, required this.transfer});

  final Transfer transfer;

  @override
  Widget build(BuildContext context) {
    return ScreenPage(
      title: 'Receipt',
      child: ListView(
        padding: const EdgeInsets.all(FvSpacing.x5),
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: context.fvWash,
                child: Icon(Icons.check, color: context.fvSuccess, size: 28),
              ),
              const SizedBox(height: FvSpacing.x3),
              const Text(
                'Transfer complete',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: FvSpacing.x2),
              Text(
                'Ref ${transfer.externalRef}',
                style: TextStyle(fontSize: 13, color: context.fvTextSecondary),
              ),
            ],
          ),
          const SizedBox(height: FvSpacing.x5),
          FvCard(
            child: Column(
              children: [
                _FeeRow(label: 'To', value: transfer.payeeName),
                _FeeRow(label: 'Destination', value: transfer.destination),
                _FeeRow(
                  label: 'Amount',
                  value: FvFormat.formatMoney(transfer.amount),
                ),
                _FeeRow(
                  label: 'Fee',
                  value: FvFormat.formatMoney(transfer.fee),
                ),
                const Divider(),
                _FeeRow(
                  label: 'Total',
                  value: FvFormat.formatMoney(transfer.total),
                  bold: true,
                ),
                _FeeRow(label: 'Status', value: transfer.status.name),
              ],
            ),
          ),
          const SizedBox(height: FvSpacing.x5),
          FvButton(
            label: 'Done',
            variant: FvButtonVariant.success,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
