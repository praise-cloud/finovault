import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models.dart';
import '../../theme/tokens.dart';

/// Interactive Neo-Brutalist bottom sheet for editing an existing logged expense.
/// Allows changing the amount, description, merchant/spot, category, and date.
class EditExpenseModal extends StatefulWidget {
  const EditExpenseModal({
    super.key,
    required this.transaction,
    required this.currency,
    required this.onSave,
    this.onDelete,
  });

  final Transaction transaction;
  final String currency;
  final Future<void> Function({
    required String id,
    String? description,
    String? merchantName,
    double? amount,
    String? category,
    DateTime? date,
  }) onSave;
  final Future<void> Function(String id)? onDelete;

  static Future<void> show(
    BuildContext context, {
    required Transaction transaction,
    required String currency,
    required Future<void> Function({
      required String id,
      String? description,
      String? merchantName,
      double? amount,
      String? category,
      DateTime? date,
    }) onSave,
    Future<void> Function(String id)? onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditExpenseModal(
        transaction: transaction,
        currency: currency,
        onSave: onSave,
        onDelete: onDelete,
      ),
    );
  }

  @override
  State<EditExpenseModal> createState() => _EditExpenseModalState();
}

class _EditExpenseModalState extends State<EditExpenseModal> {
  late final TextEditingController _descCtrl;
  late final TextEditingController _merchantCtrl;
  late final TextEditingController _amountCtrl;
  late String _selectedCategory;
  late DateTime _selectedDate;
  bool _saving = false;

  final List<String> _categories = [
    'Food & Drinks',
    'Shopping & Essentials',
    'Snacks & Study',
    'Transport',
    'Groceries',
    'Other',
  ];

  final List<Map<String, String>> _quickMerchants = const [
    {'name': 'Timo', 'icon': '🍔', 'cat': 'Food & Drinks'},
    {'name': 'Cascavelle', 'icon': '🛍️', 'cat': 'Shopping & Essentials'},
    {'name': 'Campus Tuck', 'icon': '🥪', 'cat': 'Snacks & Study'},
    {'name': 'Metro Express', 'icon': '🚌', 'cat': 'Transport'},
    {'name': 'Winners', 'icon': '🛒', 'cat': 'Groceries'},
    {'name': 'Coffee Shop', 'icon': '☕', 'cat': 'Food & Drinks'},
  ];

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(text: widget.transaction.description ?? '');
    _merchantCtrl = TextEditingController(text: widget.transaction.merchantName ?? '');
    _amountCtrl = TextEditingController(
      text: widget.transaction.amount > 0
          ? (widget.transaction.amount % 1 == 0
              ? widget.transaction.amount.toInt().toString()
              : widget.transaction.amount.toStringAsFixed(2))
          : '',
    );
    _selectedCategory = widget.transaction.category.isNotEmpty
        ? widget.transaction.category
        : 'Food & Drinks';
    if (!_categories.contains(_selectedCategory)) {
      _categories.insert(0, _selectedCategory);
    }
    _selectedDate = widget.transaction.date;
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _merchantCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDate = DateTime(dt.year, dt.month, dt.day);

    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$min';

    if (txDate == today) {
      return 'Today, $timeStr';
    } else if (txDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, $timeStr';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}, $timeStr';
    }
  }

  Future<void> _pickDate() async {
    HapticFeedback.lightImpact();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: FvColors.ink,
              onPrimary: Colors.white,
              surface: FvColors.surface,
              onSurface: FvColors.ink,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  Future<void> _handleSave() async {
    final amountParsed = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;
    if (amountParsed <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount greater than 0'),
          backgroundColor: FvColors.error,
        ),
      );
      return;
    }

    final merchant = _merchantCtrl.text.trim().isEmpty ? 'General' : _merchantCtrl.text.trim();
    final desc = _descCtrl.text.trim().isEmpty ? 'Purchase at $merchant' : _descCtrl.text.trim();

    setState(() => _saving = true);
    HapticFeedback.heavyImpact();

    await widget.onSave(
      id: widget.transaction.id,
      description: desc,
      merchantName: merchant,
      amount: amountParsed,
      category: _selectedCategory,
      date: _selectedDate,
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleDelete() async {
    HapticFeedback.mediumImpact();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: FvColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: FvColors.ink, width: 2),
        ),
        title: const Text(
          'Delete Purchase?',
          style: TextStyle(fontWeight: FontWeight.w900, color: FvColors.ink),
        ),
        content: const Text(
          'Are you sure you want to remove this purchase from your vault?',
          style: TextStyle(color: FvColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('CANCEL', style: TextStyle(color: FvColors.textSecondary, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: FvColors.ink, width: 1.5),
              ),
              elevation: 0,
            ),
            child: const Text('DELETE', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );

    if (confirm == true && widget.onDelete != null) {
      await widget.onDelete!(widget.transaction.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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

              // Title Header with Delete button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EDIT PURCHASE',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: FvColors.ink,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Update your logged expense details',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: FvColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (widget.onDelete != null)
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                            tooltip: 'Delete purchase',
                            onPressed: _handleDelete,
                            visualDensity: VisualDensity.compact,
                          ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: FvColors.ink),
                          onPressed: () => Navigator.of(context).pop(),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(color: FvColors.border, height: 16),

              // Amount Card Input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: FvColors.wash,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: FvColors.ink, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: FvColors.ink,
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${widget.currency} ',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: FvColors.ink,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _amountCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: FvColors.ink,
                            letterSpacing: -0.5,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '0.00',
                            hintStyle: TextStyle(
                              color: FvColors.textSecondary,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Description and Merchant Input Fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PURCHASE DETAILS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: FvColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: TextField(
                            controller: _descCtrl,
                            decoration: InputDecoration(
                              labelText: 'What did you buy?',
                              labelStyle: const TextStyle(fontSize: 12, color: FvColors.textSecondary, fontWeight: FontWeight.w700),
                              hintText: 'e.g. Lunch, Groceries',
                              hintStyle: const TextStyle(fontSize: 12, color: FvColors.textSecondary),
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
                                borderSide: const BorderSide(color: FvColors.ink, width: 2),
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
                              labelText: 'Where / Spot',
                              labelStyle: const TextStyle(fontSize: 12, color: FvColors.textSecondary, fontWeight: FontWeight.w700),
                              hintText: 'e.g. Timo',
                              hintStyle: const TextStyle(fontSize: 12, color: FvColors.textSecondary),
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
                                borderSide: const BorderSide(color: FvColors.ink, width: 2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Quick Spot Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'QUICK SPOTS',
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
                        children: _quickMerchants.map((spot) {
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _merchantCtrl.text = spot['name']!;
                                if (spot['cat'] != null && _categories.contains(spot['cat'])) {
                                  _selectedCategory = spot['cat']!;
                                }
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: FvColors.ink, width: 1.2),
                              ),
                              child: Text(
                                '${spot['icon']} ${spot['name']}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: FvColors.ink,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Category Selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CATEGORY',
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
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Date Tile
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: FvColors.ink, width: 1.2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 16, color: FvColors.ink),
                            const SizedBox(width: 8),
                            Text(
                              'Date: ${_formatDate(_selectedDate)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: FvColors.ink,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          'CHANGE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: FvColors.textSecondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Save Changes Action Button
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
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline_rounded, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'SAVE CHANGES',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
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
}
