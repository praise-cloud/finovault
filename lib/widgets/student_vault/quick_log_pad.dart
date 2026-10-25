import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/state/student_vault.dart';
import '../../theme/tokens.dart';
import '../fv_notification.dart';

/// Interactive tactile bottom sheet for logging expenses in < 3 seconds.
/// Supports both manual keypad entry and 1-tap quick chips for common student spots
/// like Timo, Cascavelle, Campus Tuck Shop, etc.
class QuickLogPad extends StatefulWidget {
  const QuickLogPad({
    super.key,
    required this.currency,
    required this.merchants,
    required this.onSave,
  });

  final String currency;
  final List<MerchantSpot> merchants;
  final Future<void> Function({
    required String description,
    required String merchantName,
    required double amount,
    required String category,
  }) onSave;

  static Future<void> show(
    BuildContext context, {
    required String currency,
    required List<MerchantSpot> merchants,
    required Future<void> Function({
      required String description,
      required String merchantName,
      required double amount,
      required String category,
    }) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuickLogPad(
        currency: currency,
        merchants: merchants,
        onSave: onSave,
      ),
    );
  }

  @override
  State<QuickLogPad> createState() => _QuickLogPadState();
}

class _QuickLogPadState extends State<QuickLogPad> {
  String _amountStr = '';
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _merchantCtrl = TextEditingController();
  String _selectedCategory = 'Food & Drinks';
  bool _saving = false;

  final List<String> _categories = [
    'Food & Drinks',
    'Shopping & Essentials',
    'Snacks & Study',
    'Transport',
    'Groceries',
    'Other',
  ];

  void _onKeyPress(String key) {
    HapticFeedback.lightImpact();
    setState(() {
      if (key == '⌫') {
        if (_amountStr.isNotEmpty) {
          _amountStr = _amountStr.substring(0, _amountStr.length - 1);
        }
      } else if (key == '.') {
        if (!_amountStr.contains('.') && _amountStr.isNotEmpty) {
          _amountStr += '.';
        }
      } else {
        // Prevent overly long amounts or multiple decimals
        if (_amountStr.length < 7) {
          final parts = _amountStr.split('.');
          if (parts.length > 1 && parts[1].length >= 2) return;
          _amountStr += key;
        }
      }
    });
  }

  void _applyQuickTemplate({
    required String desc,
    required String merchant,
    required double amount,
    required String category,
  }) {
    HapticFeedback.mediumImpact();
    setState(() {
      _descCtrl.text = desc;
      _merchantCtrl.text = merchant;
      _amountStr = amount.toInt().toString();
      _selectedCategory = category;
    });
  }

  Future<void> _handleSave() async {
    final amt = double.tryParse(_amountStr) ?? 0.0;
    if (amt <= 0) {
      FvNotification.show(
        context,
        message: 'Please enter an amount greater than 0',
        type: FvNotificationType.error,
      );
      return;
    }

    final merchant = _merchantCtrl.text.trim().isEmpty ? 'General' : _merchantCtrl.text.trim();
    final desc = _descCtrl.text.trim().isEmpty ? 'Purchase at $merchant' : _descCtrl.text.trim();

    setState(() => _saving = true);
    HapticFeedback.heavyImpact();

    await widget.onSave(
      description: desc,
      merchantName: merchant,
      amount: amt,
      category: _selectedCategory,
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _merchantCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayAmount = _amountStr.isEmpty ? '0' : _amountStr;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: FvColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: FvColors.ink, width: 2.5),
          left: BorderSide(color: FvColors.ink, width: 2.5),
          right: BorderSide(color: FvColors.ink, width: 2.5),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: FvColors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Title Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'LOG EXPENSE',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: FvColors.textSecondary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: FvColors.ink),
                      onPressed: () => Navigator.of(context).pop(),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),

              // Large Tactile Numeral Display
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: FvColors.wash,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: FvColors.ink, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${widget.currency} ',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: FvColors.primary,
                      ),
                    ),
                    Text(
                      displayAmount,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: FvColors.ink,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),

              // 1-Tap Student Quick Chips (Timo, Cascavelle, etc.)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'QUICK SPOTS & PRESETS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: FvColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _QuickChip(
                            label: '🍔 Timo (Rs 150)',
                            onTap: () => _applyQuickTemplate(
                              desc: 'Burger & Fries',
                              merchant: 'Timo',
                              amount: 150,
                              category: 'Food & Drinks',
                            ),
                          ),
                          _QuickChip(
                            label: '🛍️ Cascavelle (Rs 250)',
                            onTap: () => _applyQuickTemplate(
                              desc: 'Shopping & Essentials',
                              merchant: 'Cascavelle',
                              amount: 250,
                              category: 'Shopping & Essentials',
                            ),
                          ),
                          _QuickChip(
                            label: '🥪 Campus Tuck (Rs 85)',
                            onTap: () => _applyQuickTemplate(
                              desc: 'Snacks & Drink',
                              merchant: 'Campus Tuck',
                              amount: 85,
                              category: 'Snacks & Study',
                            ),
                          ),
                          _QuickChip(
                            label: '🚌 Metro (Rs 45)',
                            onTap: () => _applyQuickTemplate(
                              desc: 'Metro Card Fare',
                              merchant: 'Metro Express',
                              amount: 45,
                              category: 'Transport',
                            ),
                          ),
                          _QuickChip(
                            label: '☕ Coffee (Rs 65)',
                            onTap: () => _applyQuickTemplate(
                              desc: 'Coffee & Snack',
                              merchant: 'Timo',
                              amount: 65,
                              category: 'Food & Drinks',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Natural Sentence Inputs: "I bought [What] from [Where]"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: TextField(
                        controller: _descCtrl,
                        decoration: InputDecoration(
                          hintText: 'What did you buy? (e.g. Lunch)',
                          hintStyle: const TextStyle(fontSize: 13, color: FvColors.textSecondary),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: FvColors.ink, width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: FvColors.ink, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: FvColors.primary, width: 2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 5,
                      child: TextField(
                        controller: _merchantCtrl,
                        decoration: InputDecoration(
                          hintText: 'Where? (e.g. Timo)',
                          hintStyle: const TextStyle(fontSize: 13, color: FvColors.textSecondary),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: FvColors.ink, width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: FvColors.ink, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: FvColors.primary, width: 2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Category Selector Pills
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = cat == _selectedCategory;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedCategory = cat);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? FvColors.ink : FvColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: FvColors.ink,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : FvColors.ink,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Tactile Numeric Numpad Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildPadRow(['1', '2', '3']),
                    _buildPadRow(['4', '5', '6']),
                    _buildPadRow(['7', '8', '9']),
                    _buildPadRow(['.', '0', '⌫']),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Large "Vault It! ⚡" CTA Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: _saving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FvColors.ink,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: FvColors.ink, width: 2),
                    ),
                    shadowColor: Colors.transparent,
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bolt_rounded, size: 20, color: Color(0xFFFBBF24)),
                            SizedBox(width: 8),
                            Text(
                              'VAULT IT!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPadRow(List<String> keys) {
    return Row(
      children: keys.map((key) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: InkWell(
              onTap: () => _onKeyPress(key),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: key == '⌫' ? const Color(0xFFFEE2E2) : FvColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: FvColors.border, width: 1.2),
                ),
                child: Text(
                  key,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: key == '⌫' ? FvColors.error : FvColors.ink,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: FvColors.ink, width: 1.2),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: FvColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
