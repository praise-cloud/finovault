/// Domain models — mirrors finovault-mobile/types/index.ts and the web app's
/// types/index.ts so all three apps speak the same contract.
library;

import 'dart:math';

import 'package:flutter/material.dart';

enum PrimaryRole { individual, freelancer, entrepreneur, sme }

extension PrimaryRoleMeta on PrimaryRole {
  String get label => switch (this) {
    PrimaryRole.individual => 'Individual',
    PrimaryRole.freelancer => 'Freelancer',
    PrimaryRole.entrepreneur => 'Entrepreneur',
    PrimaryRole.sme => 'SME Owner',
  };

  String get description => switch (this) {
    PrimaryRole.individual => 'Personal wealth & savings',
    PrimaryRole.freelancer => 'Invoices, tax & irregular income',
    PrimaryRole.entrepreneur => 'Personal + business in one view',
    PrimaryRole.sme => 'Cash flow, vendors & runway',
  };

  IconData get icon => switch (this) {
    PrimaryRole.individual => Icons.person_outline,
    PrimaryRole.freelancer => Icons.work_outline,
    PrimaryRole.entrepreneur => Icons.rocket_launch_outlined,
    PrimaryRole.sme => Icons.apartment_outlined,
  };
}

enum RoleScheme { standard, femaleFounder }

enum AccountType { bank, mobileMoney, cash, other }

enum TransactionDirection { inn, out }

enum TransactionStatus { posted, pending, reconciled }

enum RiskTolerance { low, moderate, high }

enum GoalType { general, emergency, taxShield, project, pensionLinked }

enum InvoiceStatus { draft, sent, paid, overdue }

enum EventSeverity { low, medium, high }

enum TransferStatus { pending, completed, failed }

enum BillCategory { electricity, water, data, airtime, cable, schoolFees }

enum BillPaymentStatus { paid, scheduled, failed }

enum BusinessStage { idea, startup, growth, mature, scaling }

extension BusinessStageLabel on BusinessStage {
  String get label => switch (this) {
    BusinessStage.idea => 'Just an idea',
    BusinessStage.startup => 'Early startup (<1 yr)',
    BusinessStage.growth => 'Growing (1-3 yrs)',
    BusinessStage.mature => 'Established (3-10 yrs)',
    BusinessStage.scaling => 'Scaling (10+ yrs)',
  };
}

class BusinessProfile {
  const BusinessProfile({
    this.employeeCount,
    this.annualRevenueRange,
    this.industry,
    this.businessStage,
    this.taxId,
    this.registrationNumber,
    this.monthlyPayroll,
    this.avgInvoiceValue,
    this.paymentTermsDays,
    this.keySuppliers = const [],
    this.keyClients = const [],
  });

  final int? employeeCount;
  final String? annualRevenueRange;
  final String? industry;
  final BusinessStage? businessStage;
  final String? taxId;
  final String? registrationNumber;
  final double? monthlyPayroll;
  final double? avgInvoiceValue;
  final int? paymentTermsDays;
  final List<String> keySuppliers;
  final List<String> keyClients;

  BusinessProfile copyWith({
    int? employeeCount,
    String? annualRevenueRange,
    String? industry,
    BusinessStage? businessStage,
    String? taxId,
    String? registrationNumber,
    double? monthlyPayroll,
    double? avgInvoiceValue,
    int? paymentTermsDays,
    List<String>? keySuppliers,
    List<String>? keyClients,
  }) => BusinessProfile(
    employeeCount: employeeCount ?? this.employeeCount,
    annualRevenueRange: annualRevenueRange ?? this.annualRevenueRange,
    industry: industry ?? this.industry,
    businessStage: businessStage ?? this.businessStage,
    taxId: taxId ?? this.taxId,
    registrationNumber: registrationNumber ?? this.registrationNumber,
    monthlyPayroll: monthlyPayroll ?? this.monthlyPayroll,
    avgInvoiceValue: avgInvoiceValue ?? this.avgInvoiceValue,
    paymentTermsDays: paymentTermsDays ?? this.paymentTermsDays,
    keySuppliers: keySuppliers ?? this.keySuppliers,
    keyClients: keyClients ?? this.keyClients,
  );

  Map<String, dynamic> toJson() => {
    'employeeCount': employeeCount,
    'annualRevenueRange': annualRevenueRange,
    'industry': industry,
    'businessStage': businessStage?.name,
    'taxId': taxId,
    'registrationNumber': registrationNumber,
    'monthlyPayroll': monthlyPayroll,
    'avgInvoiceValue': avgInvoiceValue,
    'paymentTermsDays': paymentTermsDays,
    'keySuppliers': keySuppliers,
    'keyClients': keyClients,
  };

  static BusinessProfile fromJson(Map<String, dynamic> j) => BusinessProfile(
    employeeCount: j['employeeCount'] as int?,
    annualRevenueRange: j['annualRevenueRange'] as String?,
    industry: j['industry'] as String?,
    businessStage: j['businessStage'] == null
        ? null
        : enumFromString(
            BusinessStage.values,
            j['businessStage'] as String,
            BusinessStage.startup,
          ),
    taxId: j['taxId'] as String?,
    registrationNumber: j['registrationNumber'] as String?,
    monthlyPayroll: (j['monthlyPayroll'] as num?)?.toDouble(),
    avgInvoiceValue: (j['avgInvoiceValue'] as num?)?.toDouble(),
    paymentTermsDays: j['paymentTermsDays'] as int?,
    keySuppliers: ((j['keySuppliers'] as List?) ?? const []).cast<String>(),
    keyClients: ((j['keyClients'] as List?) ?? const []).cast<String>(),
  );

  bool get isComplete {
    if (employeeCount == null ||
        annualRevenueRange == null ||
        industry == null ||
        businessStage == null) {
      return false;
    }
    return true;
  }

  bool get isSmeComplete {
    if (!isComplete) return false;
    if (taxId == null || taxId!.isEmpty) return false;
    if (registrationNumber == null || registrationNumber!.isEmpty) return false;
    if (monthlyPayroll == null) return false;
    return true;
  }
}

extension EnumNames on Enum {
  String get serializedName => name;
}

T enumFromString<T extends Enum>(List<T> values, String? raw, T fallback) {
  if (raw == null) return fallback;
  for (final v in values) {
    if (v.name == raw || (v == TransactionDirection.inn && raw == 'in'))
      return v;
  }
  return fallback;
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.primaryRole,
    required this.scheme,
    this.avatarUrl,
    this.secondaryRoles = const [],
    this.preferredLanguage = 'en',
    this.preferredCurrency = 'MUR',
    required this.createdAt,
    this.businessProfile,
    this.privacyPolicyAcceptedAt,
  });

  final String id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final PrimaryRole primaryRole;
  final List<PrimaryRole> secondaryRoles;
  final RoleScheme scheme;
  final String preferredLanguage;
  final String preferredCurrency;
  final DateTime createdAt;
  final BusinessProfile? businessProfile;
  final DateTime? privacyPolicyAcceptedAt;

  bool get hasAcceptedPrivacyPolicy => privacyPolicyAcceptedAt != null;

  UserProfile copyWith({
    String? fullName,
    String? avatarUrl,
    PrimaryRole? primaryRole,
    RoleScheme? scheme,
    String? preferredLanguage,
    String? preferredCurrency,
    BusinessProfile? businessProfile,
    DateTime? privacyPolicyAcceptedAt,
  }) => UserProfile(
    id: id,
    email: email,
    fullName: fullName ?? this.fullName,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    primaryRole: primaryRole ?? this.primaryRole,
    secondaryRoles: secondaryRoles,
    scheme: scheme ?? this.scheme,
    preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    preferredCurrency: preferredCurrency ?? this.preferredCurrency,
    createdAt: createdAt,
    businessProfile: businessProfile ?? this.businessProfile,
    privacyPolicyAcceptedAt:
        privacyPolicyAcceptedAt ?? this.privacyPolicyAcceptedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'fullName': fullName,
    'avatarUrl': avatarUrl,
    'primaryRole': primaryRole.name,
    'secondaryRoles': secondaryRoles.map((r) => r.name).toList(),
    'scheme': scheme.name,
    'preferredLanguage': preferredLanguage,
    'preferredCurrency': preferredCurrency,
    'createdAt': createdAt.toIso8601String(),
    'businessProfile': businessProfile?.toJson(),
    'privacyPolicyAcceptedAt': privacyPolicyAcceptedAt?.toIso8601String(),
  };

  static UserProfile fromJson(Map<String, dynamic> j) => UserProfile(
    id: (j['id'] as String?) ?? '',
    email: (j['email'] as String?) ?? '',
    fullName: (j['fullName'] as String?) ?? '',
    avatarUrl: j['avatarUrl'] as String?,
    primaryRole: enumFromString(
      PrimaryRole.values,
      j['primaryRole'] as String?,
      PrimaryRole.individual,
    ),
    secondaryRoles: ((j['secondaryRoles'] as List?) ?? const [])
        .map(
          (r) => enumFromString(
            PrimaryRole.values,
            r as String?,
            PrimaryRole.individual,
          ),
        )
        .toList(),
    scheme: enumFromString(
      RoleScheme.values,
      j['scheme'] as String?,
      RoleScheme.standard,
    ),
    preferredLanguage: (j['preferredLanguage'] as String?) ?? 'en',
    preferredCurrency: (j['preferredCurrency'] as String?) ?? 'MUR',
    createdAt:
        DateTime.tryParse((j['createdAt'] as String?) ?? '') ?? DateTime.now(),
    businessProfile: j['businessProfile'] == null
        ? null
        : BusinessProfile.fromJson(
            j['businessProfile'] as Map<String, dynamic>,
          ),
    privacyPolicyAcceptedAt: j['privacyPolicyAcceptedAt'] == null
        ? null
        : DateTime.tryParse(j['privacyPolicyAcceptedAt'] as String),
  );
}

class UserPreferences {
  const UserPreferences({
    this.financialGoals = const [],
    this.riskTolerance,
    this.moneyFears,
    this.onboardingCompleted = false,
  });

  final List<String> financialGoals;
  final RiskTolerance? riskTolerance;
  final String? moneyFears;
  final bool onboardingCompleted;

  UserPreferences copyWith({
    List<String>? financialGoals,
    RiskTolerance? riskTolerance,
    bool clearRisk = false,
    String? moneyFears,
    bool? onboardingCompleted,
  }) => UserPreferences(
    financialGoals: financialGoals ?? this.financialGoals,
    riskTolerance: clearRisk ? null : (riskTolerance ?? this.riskTolerance),
    moneyFears: moneyFears ?? this.moneyFears,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
  );

  Map<String, dynamic> toJson() => {
    'financialGoals': financialGoals,
    'riskTolerance': riskTolerance?.name,
    'moneyFears': moneyFears,
    'onboardingCompleted': onboardingCompleted,
  };

  static UserPreferences fromJson(Map<String, dynamic> j) => UserPreferences(
    financialGoals: ((j['financialGoals'] as List?) ?? const []).cast<String>(),
    riskTolerance: j['riskTolerance'] == null
        ? null
        : enumFromString(
            RiskTolerance.values,
            j['riskTolerance'] as String,
            RiskTolerance.moderate,
          ),
    moneyFears: j['moneyFears'] as String?,
    onboardingCompleted: (j['onboardingCompleted'] as bool?) ?? false,
  );
}

class Account {
  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    this.currency = 'MUR',
    this.institution,
    this.isActive = true,
    this.accountNumber,
  });

  final String id;
  final String name;
  final AccountType type;
  final double balance;
  final String currency;
  final String? institution;
  final bool isActive;
  final String? accountNumber;

  Account copyWith({double? balance, String? accountNumber}) => Account(
    id: id,
    name: name,
    type: type,
    balance: balance ?? this.balance,
    currency: currency,
    institution: institution,
    isActive: isActive,
    accountNumber: accountNumber ?? this.accountNumber,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'balance': balance,
    'currency': currency,
    'institution': institution,
    'isActive': isActive,
    'accountNumber': accountNumber,
  };

  static Account fromJson(Map<String, dynamic> j) => Account(
    id: (j['id'] as String?) ?? '',
    name: (j['name'] as String?) ?? '',
    type: enumFromString(
      AccountType.values,
      j['type'] as String?,
      AccountType.bank,
    ),
    balance: (j['balance'] as num?)?.toDouble() ?? 0,
    currency: (j['currency'] as String?) ?? 'MUR',
    institution: j['institution'] as String?,
    isActive: (j['isActive'] as bool?) ?? true,
    accountNumber: j['accountNumber'] as String?,
  );
}

/// Result from the `linkBankAccount` RPC: the linked account + how many
/// historical transactions the BFF generated.
class BankLinkResult {
  const BankLinkResult({required this.account, this.imported = 0});

  final Account account;
  final int imported;

  Map<String, dynamic> toJson() => {
    'account': account.toJson(),
    'imported': imported,
  };

  static BankLinkResult fromJson(Map<String, dynamic> j) => BankLinkResult(
    account: Account.fromJson(j['account'] as Map<String, dynamic>),
    imported: (j['imported'] as num?)?.toInt() ?? 0,
  );
}

class Transaction {
  const Transaction({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.direction,
    required this.category,
    required this.date,
    this.currency = 'MUR',
    this.merchantName,
    this.isExpense = true,
    this.isRecurring = false,
    this.status = TransactionStatus.posted,
  });

  final String id;
  final String accountId;
  final double amount;
  final String currency;
  final TransactionDirection direction;
  final String category;
  final String? merchantName;
  final DateTime date;
  final bool isExpense;
  final bool isRecurring;
  final TransactionStatus status;

  Map<String, dynamic> toJson() => {
    'id': id,
    'accountId': accountId,
    'amount': amount,
    'currency': currency,
    'direction': direction == TransactionDirection.inn ? 'in' : 'out',
    'category': category,
    'merchantName': merchantName,
    'date': date.toIso8601String(),
    'isExpense': isExpense,
    'isRecurring': isRecurring,
    'status': status.name,
  };

  static Transaction fromJson(Map<String, dynamic> j) => Transaction(
    id: (j['id'] as String?) ?? '',
    accountId: (j['accountId'] as String?) ?? '',
    amount: (j['amount'] as num?)?.toDouble() ?? 0,
    currency: (j['currency'] as String?) ?? 'MUR',
    direction: enumFromString(
      TransactionDirection.values,
      j['direction'] as String?,
      TransactionDirection.out,
    ),
    category: (j['category'] as String?) ?? '',
    merchantName: j['merchantName'] as String?,
    date: DateTime.tryParse((j['date'] as String?) ?? '') ?? DateTime.now(),
    isExpense: (j['isExpense'] as bool?) ?? true,
    isRecurring: (j['isRecurring'] as bool?) ?? false,
    status: enumFromString(
      TransactionStatus.values,
      j['status'] as String?,
      TransactionStatus.posted,
    ),
  );
}

class Budget {
  const Budget({
    required this.id,
    required this.category,
    required this.amount,
    this.period = 'monthly',
  });

  final String id;
  final String category;
  final double amount;
  final String period;

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'amount': amount,
    'period': period,
  };

  static Budget fromJson(Map<String, dynamic> j) => Budget(
    id: (j['id'] as String?) ?? '',
    category: (j['category'] as String?) ?? '',
    amount: (j['amount'] as num?)?.toDouble() ?? 0,
    period: (j['period'] as String?) ?? 'monthly',
  );
}

class GoalContribution {
  const GoalContribution({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.date,
    this.sourceAccountId,
  });

  final String id;
  final String goalId;
  final double amount;
  final DateTime date;
  final String? sourceAccountId;

  Map<String, dynamic> toJson() => {
    'id': id,
    'goalId': goalId,
    'amount': amount,
    'date': date.toIso8601String(),
    'sourceAccountId': sourceAccountId,
  };

  static GoalContribution fromJson(Map<String, dynamic> j) => GoalContribution(
    id: (j['id'] as String?) ?? '',
    goalId: (j['goalId'] as String?) ?? '',
    amount: (j['amount'] as num?)?.toDouble() ?? 0,
    date: DateTime.tryParse((j['date'] as String?) ?? '') ?? DateTime.now(),
    sourceAccountId: j['sourceAccountId'] as String?,
  );
}

enum PensionFrequency { daily, weekly, monthly }

/// Flexible micro-pension product (Phase 4). Splits savings into a short-term
/// pot (liquid, near goals) and a long-term pot (retirement), each with its own
/// target. Mirrors the web/backend `/pension` contract.
class PensionPlan {
  const PensionPlan({
    required this.id,
    required this.shortPotTarget,
    required this.longPotTarget,
    this.frequency = PensionFrequency.monthly,
    this.contributionAmount = 0,
    this.currentShortPot = 0,
    this.currentLongPot = 0,
    this.assumedReturnPct = 7,
    this.inflationPct = 4,
    this.currentAge = 30,
    this.retirementAge = 65,
    this.autoDebit = false,
    this.updatedAt,
  });

  final String id;
  final double shortPotTarget;
  final double longPotTarget;
  final PensionFrequency frequency;
  final double contributionAmount;
  final double currentShortPot;
  final double currentLongPot;
  final double assumedReturnPct;
  final double inflationPct;
  final int currentAge;
  final int retirementAge;
  final bool autoDebit;
  final DateTime? updatedAt;

  /// Contribution amount expressed as a monthly equivalent.
  double get monthlyContribution => contributionAmount * _frequencyMultiplier;

  double get _frequencyMultiplier {
    switch (frequency) {
      case PensionFrequency.daily:
        return 30.0;
      case PensionFrequency.weekly:
        return 4.33;
      case PensionFrequency.monthly:
        return 1.0;
    }
  }

  PensionPlan copyWith({
    double? shortPotTarget,
    double? longPotTarget,
    PensionFrequency? frequency,
    double? contributionAmount,
    double? currentShortPot,
    double? currentLongPot,
    double? assumedReturnPct,
    double? inflationPct,
    int? currentAge,
    int? retirementAge,
    bool? autoDebit,
    DateTime? updatedAt,
  }) => PensionPlan(
    id: id,
    shortPotTarget: shortPotTarget ?? this.shortPotTarget,
    longPotTarget: longPotTarget ?? this.longPotTarget,
    frequency: frequency ?? this.frequency,
    contributionAmount: contributionAmount ?? this.contributionAmount,
    currentShortPot: currentShortPot ?? this.currentShortPot,
    currentLongPot: currentLongPot ?? this.currentLongPot,
    assumedReturnPct: assumedReturnPct ?? this.assumedReturnPct,
    inflationPct: inflationPct ?? this.inflationPct,
    currentAge: currentAge ?? this.currentAge,
    retirementAge: retirementAge ?? this.retirementAge,
    autoDebit: autoDebit ?? this.autoDebit,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'shortPotTarget': shortPotTarget,
    'longPotTarget': longPotTarget,
    'frequency': frequency.name,
    'contributionAmount': contributionAmount,
    'currentShortPot': currentShortPot,
    'currentLongPot': currentLongPot,
    'assumedReturnPct': assumedReturnPct,
    'inflationPct': inflationPct,
    'currentAge': currentAge,
    'retirementAge': retirementAge,
    'autoDebit': autoDebit,
    'updatedAt': updatedAt?.toIso8601String(),
  };

  static PensionPlan fromJson(Map<String, dynamic> j) => PensionPlan(
    id: (j['id'] as String?) ?? '',
    shortPotTarget: (j['shortPotTarget'] as num?)?.toDouble() ?? 0,
    longPotTarget: (j['longPotTarget'] as num?)?.toDouble() ?? 0,
    frequency: enumFromString(
      PensionFrequency.values,
      j['frequency'] as String?,
      PensionFrequency.monthly,
    ),
    contributionAmount: (j['contributionAmount'] as num?)?.toDouble() ?? 0,
    currentShortPot: (j['currentShortPot'] as num?)?.toDouble() ?? 0,
    currentLongPot: (j['currentLongPot'] as num?)?.toDouble() ?? 0,
    assumedReturnPct: (j['assumedReturnPct'] as num?)?.toDouble() ?? 7,
    inflationPct: (j['inflationPct'] as num?)?.toDouble() ?? 4,
    currentAge: (j['currentAge'] as num?)?.toInt() ?? 30,
    retirementAge: (j['retirementAge'] as num?)?.toInt() ?? 65,
    autoDebit: (j['autoDebit'] as bool?) ?? false,
    updatedAt: j['updatedAt'] == null
        ? null
        : DateTime.tryParse(j['updatedAt'] as String),
  );

  /// Simple projection: monthly compounding at the assumed nominal return,
  /// discounted to today's money by the inflation assumption. Inspired by
  /// common African micro-pension models (short + long pot split).
  PensionProjection computeProjection() {
    final years = (retirementAge - currentAge).clamp(0, 100);
    final months = years * 12;
    final monthly = monthlyContribution;
    final r = (assumedReturnPct / 100) / 12;

    double futureValue(double start) {
      if (months <= 0 || monthly <= 0) return start;
      final factor = (r == 0)
          ? months.toDouble()
          : (pow(1 + r, months) - 1) / r;
      return start + monthly * factor;
    }

    final shortNominal = futureValue(currentShortPot);
    final longNominal = futureValue(currentLongPot);
    final inflFactor = pow(1 + inflationPct / 100, years).toDouble();
    final realShort = inflFactor > 0 ? shortNominal / inflFactor : shortNominal;
    final realLong = inflFactor > 0 ? longNominal / inflFactor : longNominal;
    return PensionProjection(
      shortPotProjected: realShort,
      longPotProjected: realLong,
      totalProjected: realShort + realLong,
      yearsToRetirement: years,
    );
  }
}

class PensionContribution {
  const PensionContribution({
    required this.id,
    required this.planId,
    required this.pot,
    required this.amount,
    required this.date,
    this.sourceAccountId,
  });

  final String id;
  final String planId;
  final String pot;
  final double amount;
  final DateTime date;
  final String? sourceAccountId;

  Map<String, dynamic> toJson() => {
    'id': id,
    'planId': planId,
    'pot': pot,
    'amount': amount,
    'date': date.toIso8601String(),
    'sourceAccountId': sourceAccountId,
  };

  static PensionContribution fromJson(Map<String, dynamic> j) =>
      PensionContribution(
        id: (j['id'] as String?) ?? '',
        planId: (j['planId'] as String?) ?? '',
        pot: (j['pot'] as String?) ?? 'short',
        amount: (j['amount'] as num?)?.toDouble() ?? 0,
        date: DateTime.tryParse((j['date'] as String?) ?? '') ?? DateTime.now(),
        sourceAccountId: j['sourceAccountId'] as String?,
      );
}

class PensionProjection {
  const PensionProjection({
    required this.shortPotProjected,
    required this.longPotProjected,
    required this.totalProjected,
    required this.yearsToRetirement,
  });

  final double shortPotProjected;
  final double longPotProjected;
  final double totalProjected;
  final int yearsToRetirement;

  Map<String, dynamic> toJson() => {
    'shortPotProjected': shortPotProjected,
    'longPotProjected': longPotProjected,
    'totalProjected': totalProjected,
    'yearsToRetirement': yearsToRetirement,
  };

  factory PensionProjection.fromJson(Map<String, dynamic> j) =>
      PensionProjection(
        shortPotProjected: (j['shortPotProjected'] as num?)?.toDouble() ?? 0,
        longPotProjected: (j['longPotProjected'] as num?)?.toDouble() ?? 0,
        totalProjected: (j['totalProjected'] as num?)?.toDouble() ?? 0,
        yearsToRetirement: (j['yearsToRetirement'] as num?)?.toInt() ?? 0,
      );
}

class SavingsGoal {
  const SavingsGoal({
    required this.id,
    required this.name,
    required this.type,
    required this.targetAmount,
    this.currentAmount = 0,
    this.targetDate,
    this.completed = false,
    this.contributions = const [],
  });

  final String id;
  final String name;
  final GoalType type;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;
  final bool completed;
  final List<GoalContribution> contributions;

  SavingsGoal copyWith({
    double? currentAmount,
    bool? completed,
    List<GoalContribution>? contributions,
  }) => SavingsGoal(
    id: id,
    name: name,
    type: type,
    targetAmount: targetAmount,
    currentAmount: currentAmount ?? this.currentAmount,
    targetDate: targetDate,
    completed: completed ?? this.completed,
    contributions: contributions ?? this.contributions,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'targetDate': targetDate?.toIso8601String(),
    'completed': completed,
    'contributions': contributions.map((c) => c.toJson()).toList(),
  };

  static SavingsGoal fromJson(Map<String, dynamic> j) => SavingsGoal(
    id: (j['id'] as String?) ?? '',
    name: (j['name'] as String?) ?? '',
    type: enumFromString(
      GoalType.values,
      j['type'] as String?,
      GoalType.general,
    ),
    targetAmount: (j['targetAmount'] as num?)?.toDouble() ?? 0,
    currentAmount: (j['currentAmount'] as num?)?.toDouble() ?? 0,
    targetDate: j['targetDate'] == null
        ? null
        : DateTime.tryParse(j['targetDate'] as String),
    completed: (j['completed'] as bool?) ?? false,
    contributions: ((j['contributions'] as List?) ?? const [])
        .map((c) => GoalContribution.fromJson(c as Map<String, dynamic>))
        .toList(),
  );
}

class SecurityDevice {
  const SecurityDevice({
    required this.id,
    required this.name,
    required this.lastSeen,
    this.trusted = false,
  });

  final String id;
  final String name;
  final DateTime lastSeen;
  final bool trusted;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'lastSeen': lastSeen.toIso8601String(),
    'trusted': trusted,
  };

  static SecurityDevice fromJson(Map<String, dynamic> j) => SecurityDevice(
    id: (j['id'] as String?) ?? '',
    name: (j['name'] as String?) ?? '',
    lastSeen:
        DateTime.tryParse((j['lastSeen'] as String?) ?? '') ?? DateTime.now(),
    trusted: (j['trusted'] as bool?) ?? false,
  );
}

class SecurityEvent {
  const SecurityEvent({
    required this.id,
    required this.title,
    required this.severity,
    required this.date,
    this.resolved = false,
    this.description,
  });

  final String id;
  final String title;
  final EventSeverity severity;
  final DateTime date;
  final bool resolved;
  final String? description;

  SecurityEvent copyWith({bool? resolved}) => SecurityEvent(
    id: id,
    title: title,
    severity: severity,
    date: date,
    resolved: resolved ?? this.resolved,
    description: description,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'severity': severity.name,
    'date': date.toIso8601String(),
    'resolved': resolved,
    'description': description,
  };

  static SecurityEvent fromJson(Map<String, dynamic> j) => SecurityEvent(
    id: (j['id'] as String?) ?? '',
    title: (j['title'] as String?) ?? '',
    severity: enumFromString(
      EventSeverity.values,
      j['severity'] as String?,
      EventSeverity.low,
    ),
    date: DateTime.tryParse((j['date'] as String?) ?? '') ?? DateTime.now(),
    resolved: (j['resolved'] as bool?) ?? false,
    description: j['description'] as String?,
  );
}

class SecurityOverview {
  const SecurityOverview({
    required this.score,
    this.twoFactorEnabled = false,
    this.lastPasswordChange,
  });

  final int score;
  final bool twoFactorEnabled;
  final DateTime? lastPasswordChange;

  SecurityOverview copyWith({
    int? score,
    bool? twoFactorEnabled,
    DateTime? lastPasswordChange,
  }) => SecurityOverview(
    score: score ?? this.score,
    twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
    lastPasswordChange: lastPasswordChange ?? this.lastPasswordChange,
  );

  Map<String, dynamic> toJson() => {
    'score': score,
    'twoFactorEnabled': twoFactorEnabled,
    'lastPasswordChange': lastPasswordChange?.toIso8601String(),
  };

  static SecurityOverview fromJson(Map<String, dynamic> j) => SecurityOverview(
    score: (j['score'] as num?)?.toInt() ?? 0,
    twoFactorEnabled: (j['twoFactorEnabled'] as bool?) ?? false,
    lastPasswordChange: DateTime.tryParse(
      (j['lastPasswordChange'] as String?) ?? '',
    ),
  );
}

class Invoice {
  const Invoice({
    required this.id,
    required this.clientName,
    required this.amount,
    required this.dueDate,
    this.currency = 'MUR',
    this.status = InvoiceStatus.draft,
  });

  final String id;
  final String clientName;
  final double amount;
  final String currency;
  final DateTime dueDate;
  final InvoiceStatus status;

  Invoice copyWith({InvoiceStatus? status}) => Invoice(
    id: id,
    clientName: clientName,
    amount: amount,
    currency: currency,
    dueDate: dueDate,
    status: status ?? this.status,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'clientName': clientName,
    'amount': amount,
    'currency': currency,
    'dueDate': dueDate.toIso8601String(),
    'status': status.name,
  };

  static Invoice fromJson(Map<String, dynamic> j) => Invoice(
    id: (j['id'] as String?) ?? '',
    clientName: (j['clientName'] as String?) ?? '',
    amount: (j['amount'] as num?)?.toDouble() ?? 0,
    currency: (j['currency'] as String?) ?? 'MUR',
    dueDate:
        DateTime.tryParse((j['dueDate'] as String?) ?? '') ?? DateTime.now(),
    status: enumFromString(
      InvoiceStatus.values,
      j['status'] as String?,
      InvoiceStatus.sent,
    ),
  );
}

class Vendor {
  const Vendor({
    required this.id,
    required this.name,
    this.totalSpend = 0,
    this.reliabilityScore = 80,
  });

  final String id;
  final String name;
  final double totalSpend;
  final int reliabilityScore;

  Vendor copyWith({double? totalSpend}) => Vendor(
    id: id,
    name: name,
    totalSpend: totalSpend ?? this.totalSpend,
    reliabilityScore: reliabilityScore,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'totalSpend': totalSpend,
    'reliabilityScore': reliabilityScore,
  };

  static Vendor fromJson(Map<String, dynamic> j) => Vendor(
    id: (j['id'] as String?) ?? '',
    name: (j['name'] as String?) ?? '',
    totalSpend: (j['totalSpend'] as num?)?.toDouble() ?? 0,
    reliabilityScore: (j['reliabilityScore'] as num?)?.toInt() ?? 80,
  );
}

class Payee {
  const Payee({required this.id, required this.name, this.destination});

  final String id;
  final String name;
  final String? destination;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'destination': destination,
  };

  static Payee fromJson(Map<String, dynamic> j) => Payee(
    id: (j['id'] as String?) ?? '',
    name: (j['name'] as String?) ?? '',
    destination: j['destination'] as String?,
  );
}

class Transfer {
  const Transfer({
    required this.id,
    required this.sourceAccountId,
    required this.payeeName,
    required this.destination,
    required this.amount,
    required this.fee,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.externalRef,
    required this.idempotencyKey,
  });

  final String id;
  final String sourceAccountId;
  final String payeeName;
  final String destination;
  final double amount;
  final double fee;
  final double total;
  final TransferStatus status;
  final DateTime createdAt;
  final String externalRef;
  final String idempotencyKey;

  Map<String, dynamic> toJson() => {
    'id': id,
    'sourceAccountId': sourceAccountId,
    'payeeName': payeeName,
    'destination': destination,
    'amount': amount,
    'fee': fee,
    'total': total,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'externalRef': externalRef,
    'idempotencyKey': idempotencyKey,
  };

  static Transfer fromJson(Map<String, dynamic> j) => Transfer(
    id: (j['id'] as String?) ?? '',
    sourceAccountId: (j['sourceAccountId'] as String?) ?? '',
    payeeName: (j['payeeName'] as String?) ?? '',
    destination: (j['destination'] as String?) ?? '',
    amount: (j['amount'] as num?)?.toDouble() ?? 0,
    fee: (j['fee'] as num?)?.toDouble() ?? 0,
    total: (j['total'] as num?)?.toDouble() ?? 0,
    status: enumFromString(
      TransferStatus.values,
      j['status'] as String?,
      TransferStatus.completed,
    ),
    createdAt:
        DateTime.tryParse((j['createdAt'] as String?) ?? '') ?? DateTime.now(),
    externalRef: (j['externalRef'] as String?) ?? '',
    idempotencyKey: (j['idempotencyKey'] as String?) ?? '',
  );
}

class BillPayment {
  const BillPayment({
    required this.id,
    required this.category,
    required this.billerName,
    required this.amount,
    required this.status,
    required this.date,
    this.customerRef,
    this.scheduledFor,
  });

  final String id;
  final BillCategory category;
  final String billerName;
  final double amount;
  final BillPaymentStatus status;
  final DateTime date;
  final String? customerRef;
  final DateTime? scheduledFor;

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category.name,
    'billerName': billerName,
    'amount': amount,
    'status': status.name,
    'date': date.toIso8601String(),
    'customerRef': customerRef,
    'scheduledFor': scheduledFor?.toIso8601String(),
  };

  static BillPayment fromJson(Map<String, dynamic> j) => BillPayment(
    id: (j['id'] as String?) ?? '',
    category: enumFromString(
      BillCategory.values,
      j['category'] as String?,
      BillCategory.electricity,
    ),
    billerName: (j['billerName'] as String?) ?? '',
    amount: (j['amount'] as num?)?.toDouble() ?? 0,
    status: enumFromString(
      BillPaymentStatus.values,
      j['status'] as String?,
      BillPaymentStatus.paid,
    ),
    date: DateTime.tryParse((j['date'] as String?) ?? '') ?? DateTime.now(),
    customerRef: j['customerRef'] as String?,
    scheduledFor: j['scheduledFor'] == null
        ? null
        : DateTime.tryParse(j['scheduledFor'] as String),
  );
}

enum NotificationType { transfer, bill, security, goal, system }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.link,
    this.readAt,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final String? link;
  final DateTime? readAt;
  final DateTime createdAt;

  bool get isRead => readAt != null;

  AppNotification markRead() => AppNotification(
    id: id,
    title: title,
    body: body,
    type: type,
    link: link,
    readAt: DateTime.now(),
    createdAt: createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'type': type.name,
    'link': link,
    'readAt': readAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  static AppNotification fromJson(Map<String, dynamic> j) => AppNotification(
    id: (j['id'] as String?) ?? '',
    title: (j['title'] as String?) ?? '',
    body: (j['body'] as String?) ?? '',
    type: enumFromString(
      NotificationType.values,
      j['type'] as String?,
      NotificationType.system,
    ),
    link: j['link'] as String?,
    readAt: j['readAt'] == null
        ? null
        : DateTime.tryParse(j['readAt'] as String),
    createdAt:
        DateTime.tryParse((j['createdAt'] as String?) ?? '') ?? DateTime.now(),
  );
}

class AccountVerification {
  const AccountVerification({
    required this.exists,
    this.holderName,
    required this.verified,
  });

  final bool exists;
  final String? holderName;
  final bool verified;

  Map<String, dynamic> toJson() => {
    'exists': exists,
    'holderName': holderName,
    'verified': verified,
  };

  static AccountVerification fromJson(Map<String, dynamic> j) =>
      AccountVerification(
        exists: (j['exists'] as bool?) ?? false,
        holderName: j['holderName'] as String?,
        verified: (j['verified'] as bool?) ?? false,
      );
}

class TwoFactorSetup {
  const TwoFactorSetup({
    required this.secret,
    required this.qrUrl,
    required this.backupCodes,
  });

  final String secret;
  final String qrUrl;
  final List<String> backupCodes;

  Map<String, dynamic> toJson() => {
    'secret': secret,
    'qrUrl': qrUrl,
    'backupCodes': backupCodes,
  };

  static TwoFactorSetup fromJson(Map<String, dynamic> j) => TwoFactorSetup(
    secret: (j['secret'] as String?) ?? '',
    qrUrl: (j['qrUrl'] as String?) ?? '',
    backupCodes: ((j['backupCodes'] as List?) ?? []).cast<String>(),
  );
}
