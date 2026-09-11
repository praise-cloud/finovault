import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/state/onboarding.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';

const _employeeCountOptions = [
  0,
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9,
  10,
  11,
  12,
  13,
  14,
  15,
  16,
  17,
  18,
  19,
  20,
  21,
  22,
  23,
  24,
  25,
  30,
  40,
  50,
  75,
  100,
  150,
  200,
  300,
  500,
];

const _revenueRangeOptions = [
  'pre_revenue',
  'under_1m',
  '1m_5m',
  '5m_20m',
  '20m_100m',
  '100m_plus',
];

const _industryOptions = [
  'technology',
  'retail',
  'manufacturing',
  'services',
  'agriculture',
  'hospitality',
  'construction',
  'healthcare',
  'education',
  'finance',
  'transport_logistics',
  'creative_media',
  'real_estate',
  'other',
];

const _paymentTermsOptions = [15, 30, 45, 60, 90];

/// Onboarding step for Entrepreneur/SME — collects business-specific data
class BusinessDetailsScreen extends ConsumerStatefulWidget {
  const BusinessDetailsScreen({super.key});

  @override
  ConsumerState<BusinessDetailsScreen> createState() => _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends ConsumerState<BusinessDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Common fields
  int? _employeeCount;
  String? _annualRevenueRange;
  String? _industry;
  BusinessStage? _businessStage;
  final _monthlyPayrollController = TextEditingController();

  // SME-only fields
  final _taxIdController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _avgInvoiceValueController = TextEditingController();
  int? _paymentTermsDays;
  final _keySuppliersController = TextEditingController();
  final _keyClientsController = TextEditingController();

  // Pre-fill from existing state
  BusinessProfile? _existingProfile;

  @override
  void initState() {
    super.initState();
    final saved = ref.read(onboardingProvider);
    _existingProfile = saved.businessProfile;
    if (_existingProfile != null) {
      _employeeCount = _existingProfile!.employeeCount;
      _annualRevenueRange = _existingProfile!.annualRevenueRange;
      _industry = _existingProfile!.industry;
      _businessStage = _existingProfile!.businessStage;
      _monthlyPayrollController.text = _existingProfile!.monthlyPayroll?.toString() ?? '';
      _taxIdController.text = _existingProfile!.taxId ?? '';
      _registrationNumberController.text = _existingProfile!.registrationNumber ?? '';
      _avgInvoiceValueController.text = _existingProfile!.avgInvoiceValue?.toString() ?? '';
      _paymentTermsDays = _existingProfile!.paymentTermsDays;
      _keySuppliersController.text = _existingProfile!.keySuppliers.join(', ');
      _keyClientsController.text = _existingProfile!.keyClients.join(', ');
    }
  }

  @override
  void dispose() {
    _monthlyPayrollController.dispose();
    _taxIdController.dispose();
    _registrationNumberController.dispose();
    _avgInvoiceValueController.dispose();
    _keySuppliersController.dispose();
    _keyClientsController.dispose();
    super.dispose();
  }

  bool get _isSme => ref.read(onboardingProvider).role == PrimaryRole.sme;

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = BusinessProfile(
      employeeCount: _employeeCount,
      annualRevenueRange: _annualRevenueRange,
      industry: _industry,
      businessStage: _businessStage,
      taxId: _isSme ? _taxIdController.text.trim() : null,
      registrationNumber: _isSme ? _registrationNumberController.text.trim() : null,
      monthlyPayroll: _monthlyPayrollController.text.isEmpty
          ? null
          : double.tryParse(_monthlyPayrollController.text.replaceAll(',', '')),
      avgInvoiceValue: _avgInvoiceValueController.text.isEmpty
          ? null
          : double.tryParse(_avgInvoiceValueController.text.replaceAll(',', '')),
      paymentTermsDays: _paymentTermsDays,
      keySuppliers: _keySuppliersController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      keyClients: _keyClientsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
    );

    // Validate SME required fields
    if (_isSme && !profile.isSmeComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).businessDetailsSmeRequired),
          backgroundColor: FvColors.error,
        ),
      );
      return;
    }

    await ref.read(onboardingProvider.notifier).setBusinessDetails(profile);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: context.fvOnboardingDecoration,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(FvSpacing.x6, FvSpacing.x4, FvSpacing.x6, 0),
                child: OnboardingHeader(
                  onBack: () => ref.read(onboardingProvider.notifier).back(),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(FvSpacing.x6, FvSpacing.x8, FvSpacing.x6, FvSpacing.x6),
                  children: [
                    Text(
                      s.businessDetailsTitle,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: context.fvText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isSme ? s.businessDetailsSubtitleSme : s.businessDetailsSubtitleEntrepreneur,
                      style: TextStyle(fontSize: 15, height: 1.5, color: context.fvTextSecondary),
                    ),
                    const SizedBox(height: FvSpacing.x5),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Employee Count
                          Text(s.employeeCountLabel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.fvText)),
                          const SizedBox(height: FvSpacing.x2),
                          DropdownButtonFormField<int>(
                            initialValue: _employeeCount,
                            decoration: InputDecoration(
                              hintText: s.employeeCountHint,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(FvRadius.input)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: FvSpacing.x4, vertical: FvSpacing.x3),
                            ),
                            items: _employeeCountOptions
                                .map((e) => DropdownMenuItem(value: e, child: Text(e == 0 ? s.employeeCountZero : e.toString())))
                                .toList(),
                            onChanged: (v) => setState(() => _employeeCount = v),
                            validator: (v) => v == null ? s.employeeCountRequired : null,
                          ),
                          const SizedBox(height: FvSpacing.x4),

                          // Annual Revenue Range
                          Text(s.annualRevenueLabel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.fvText)),
                          const SizedBox(height: FvSpacing.x2),
                          DropdownButtonFormField<String>(
                            initialValue: _annualRevenueRange,
                            decoration: InputDecoration(
                              hintText: s.annualRevenueHint,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(FvRadius.input)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: FvSpacing.x4, vertical: FvSpacing.x3),
                            ),
                            items: _revenueRangeOptions
                                .map((e) => DropdownMenuItem(value: e, child: Text(_revenueLabel(s, e))))
                                .toList(),
                            onChanged: (v) => setState(() => _annualRevenueRange = v),
                            validator: (v) => v == null ? s.annualRevenueRequired : null,
                          ),
                          const SizedBox(height: FvSpacing.x4),

                          // Industry
                          Text(s.industryLabel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.fvText)),
                          const SizedBox(height: FvSpacing.x2),
                          DropdownButtonFormField<String>(
                            initialValue: _industry,
                            decoration: InputDecoration(
                              hintText: s.industryHint,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(FvRadius.input)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: FvSpacing.x4, vertical: FvSpacing.x3),
                            ),
                            items: _industryOptions
                                .map((e) => DropdownMenuItem(value: e, child: Text(_industryLabel(s, e))))
                                .toList(),
                            onChanged: (v) => setState(() => _industry = v),
                            validator: (v) => v == null ? s.industryRequired : null,
                          ),
                          const SizedBox(height: FvSpacing.x4),

                          // Business Stage
                          Text(s.businessStageLabel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.fvText)),
                          const SizedBox(height: FvSpacing.x2),
                          DropdownButtonFormField<BusinessStage>(
                            initialValue: _businessStage,
                            decoration: InputDecoration(
                              hintText: s.businessStageHint,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(FvRadius.input)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: FvSpacing.x4, vertical: FvSpacing.x3),
                            ),
                            items: BusinessStage.values
                                .map((e) => DropdownMenuItem(value: e, child: Text(e.label)))
                                .toList(),
                            onChanged: (v) => setState(() => _businessStage = v),
                            validator: (v) => v == null ? s.businessStageRequired : null,
                          ),
                          const SizedBox(height: FvSpacing.x4),

                          // Monthly Payroll
                          Text(s.monthlyPayrollLabel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.fvText)),
                          const SizedBox(height: FvSpacing.x2),
                          FvTextField(
                            label: s.monthlyPayrollLabel,
                            controller: _monthlyPayrollController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            hint: s.monthlyPayrollHint,
                          ),
                          if (_isSme) ...[
                            const SizedBox(height: FvSpacing.x4),
                            Text(s.smeRequiredFieldsNote, style: TextStyle(fontSize: 12, color: context.fvTextSecondary)),
                          ],
                          const SizedBox(height: FvSpacing.x6),

                          // SME-only fields
                          if (_isSme) ...[
                            Text(s.smeDetailsSection, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.fvText)),
                            const SizedBox(height: FvSpacing.x3),

                            // Tax ID
                            Text(s.taxIdLabel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.fvText)),
                            const SizedBox(height: FvSpacing.x2),
                            FvTextField(
                              label: s.taxIdLabel,
                              controller: _taxIdController,
                              hint: s.taxIdHint,
                            ),
                            const SizedBox(height: FvSpacing.x4),

                            // Registration Number
                            Text(s.registrationNumberLabel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.fvText)),
                            const SizedBox(height: FvSpacing.x2),
                            FvTextField(
                              label: s.registrationNumberLabel,
                              controller: _registrationNumberController,
                              hint: s.registrationNumberHint,
                            ),
                            const SizedBox(height: FvSpacing.x4),

                            // Average Invoice Value
                            Text(s.avgInvoiceValueLabel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.fvText)),
                            const SizedBox(height: FvSpacing.x2),
                            FvTextField(
                              label: s.avgInvoiceValueLabel,
                              controller: _avgInvoiceValueController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              hint: s.avgInvoiceValueHint,
                            ),
                            const SizedBox(height: FvSpacing.x4),

                            // Payment Terms
                            Text(s.paymentTermsLabel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.fvText)),
                            const SizedBox(height: FvSpacing.x2),
                            DropdownButtonFormField<int>(
                              initialValue: _paymentTermsDays,
                              decoration: InputDecoration(
                                hintText: s.paymentTermsHint,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(FvRadius.input)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: FvSpacing.x4, vertical: FvSpacing.x3),
                              ),
                              items: _paymentTermsOptions
                                  .map((e) => DropdownMenuItem(value: e, child: Text('$e ${s.days}')))
                                  .toList(),
                              onChanged: (v) => setState(() => _paymentTermsDays = v),
                            ),
                            const SizedBox(height: FvSpacing.x4),

                            // Key Suppliers
                            Text(s.keySuppliersLabel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.fvText)),
                            const SizedBox(height: FvSpacing.x2),
                            FvTextField(
                              label: s.keySuppliersLabel,
                              controller: _keySuppliersController,
                              hint: s.keySuppliersHint,
                            ),
                            const SizedBox(height: FvSpacing.x4),

                            // Key Clients
                            Text(s.keyClientsLabel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.fvText)),
                            const SizedBox(height: FvSpacing.x2),
                            FvTextField(
                              label: s.keyClientsLabel,
                              controller: _keyClientsController,
                              hint: s.keyClientsHint,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: FvSpacing.x5),
                    SizedBox(
                      width: double.infinity,
                      child: FvButton(
                        label: s.continueCta,
                        onPressed: _continue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _revenueLabel(AppLocalizations s, String key) {
    return switch (key) {
      'pre_revenue' => s.revenuePreRevenue,
      'under_1m' => s.revenueUnder1m,
      '1m_5m' => s.revenue1m5m,
      '5m_20m' => s.revenue5m20m,
      '20m_100m' => s.revenue20m100m,
      '100m_plus' => s.revenue100mPlus,
      _ => key,
    };
  }

  String _industryLabel(AppLocalizations s, String key) {
    return switch (key) {
      'technology' => s.industryTechnology,
      'retail' => s.industryRetail,
      'manufacturing' => s.industryManufacturing,
      'services' => s.industryServices,
      'agriculture' => s.industryAgriculture,
      'hospitality' => s.industryHospitality,
      'construction' => s.industryConstruction,
      'healthcare' => s.industryHealthcare,
      'education' => s.industryEducation,
      'finance' => s.industryFinance,
      'transport_logistics' => s.industryTransportLogistics,
      'creative_media' => s.industryCreativeMedia,
      'real_estate' => s.industryRealEstate,
      'other' => s.industryOther,
      _ => key,
    };
  }
}