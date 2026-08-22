/// Domain models — mirrors finovault-mobile/types/index.ts and the web app's
/// types/index.ts so all three apps speak the same contract.
library;

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

extension EnumNames on Enum {
  String get serializedName => name;
}

T enumFromString<T extends Enum>(List<T> values, String? raw, T fallback) {
  if (raw == null) return fallback;
  for (final v in values) {
    if (v.name == raw || (v == TransactionDirection.inn && raw == 'in')) return v;
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

  UserProfile copyWith({
    String? fullName,
    String? avatarUrl,
    PrimaryRole? primaryRole,
    RoleScheme? scheme,
    String? preferredLanguage,
    String? preferredCurrency,
  }) =>
      UserProfile(
        id: id,
        email: email,
        fullName: fullName ?? this.fullName,
        primaryRole: primaryRole ?? this.primaryRole,
        secondaryRoles: secondaryRoles,
        scheme: scheme ?? this.scheme,
        preferredLanguage: preferredLanguage ?? this.preferredLanguage,
        preferredCurrency: preferredCurrency ?? this.preferredCurrency,
        createdAt: createdAt,
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
      };

  static UserProfile fromJson(Map<String, dynamic> j) => UserProfile(
        id: j['id'] as String,
        email: j['email'] as String,
        fullName: j['fullName'] as String,
        avatarUrl: j['avatarUrl'] as String?,
        primaryRole: enumFromString(PrimaryRole.values, j['primaryRole'] as String?, PrimaryRole.individual),
        secondaryRoles: ((j['secondaryRoles'] as List?) ?? const [])
            .map((r) => enumFromString(PrimaryRole.values, r as String?, PrimaryRole.individual))
            .toList(),
        scheme: enumFromString(RoleScheme.values, j['scheme'] as String?, RoleScheme.standard),
        preferredLanguage: (j['preferredLanguage'] as String?) ?? 'en',
        preferredCurrency: (j['preferredCurrency'] as String?) ?? 'MUR',
        createdAt: DateTime.tryParse((j['createdAt'] as String?) ?? '') ?? DateTime.now(),
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
  }) =>
      UserPreferences(
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
            : enumFromString(RiskTolerance.values, j['riskTolerance'] as String, RiskTolerance.moderate),
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
  });

  final String id;
  final String name;
  final AccountType type;
  final double balance;
  final String currency;
  final String? institution;
  final bool isActive;

  Account copyWith({double? balance}) => Account(
        id: id,
        name: name,
        type: type,
        balance: balance ?? this.balance,
        currency: currency,
        institution: institution,
        isActive: isActive,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'balance': balance,
        'currency': currency,
        'institution': institution,
        'isActive': isActive,
      };

  static Account fromJson(Map<String, dynamic> j) => Account(
        id: j['id'] as String,
        name: j['name'] as String,
        type: enumFromString(AccountType.values, j['type'] as String?, AccountType.bank),
        balance: (j['balance'] as num).toDouble(),
        currency: (j['currency'] as String?) ?? 'MUR',
        institution: j['institution'] as String?,
        isActive: (j['isActive'] as bool?) ?? true,
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
        id: j['id'] as String,
        accountId: j['accountId'] as String,
        amount: (j['amount'] as num).toDouble(),
        currency: (j['currency'] as String?) ?? 'MUR',
        direction: enumFromString(TransactionDirection.values, j['direction'] as String?, TransactionDirection.out),
        category: j['category'] as String,
        merchantName: j['merchantName'] as String?,
        date: DateTime.tryParse((j['date'] as String?) ?? '') ?? DateTime.now(),
        isExpense: (j['isExpense'] as bool?) ?? true,
        isRecurring: (j['isRecurring'] as bool?) ?? false,
        status: enumFromString(TransactionStatus.values, j['status'] as String?, TransactionStatus.posted),
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

  Map<String, dynamic> toJson() => {'id': id, 'category': category, 'amount': amount, 'period': period};

  static Budget fromJson(Map<String, dynamic> j) => Budget(
        id: j['id'] as String,
        category: j['category'] as String,
        amount: (j['amount'] as num).toDouble(),
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
        id: j['id'] as String,
        goalId: j['goalId'] as String,
        amount: (j['amount'] as num).toDouble(),
        date: DateTime.tryParse((j['date'] as String?) ?? '') ?? DateTime.now(),
        sourceAccountId: j['sourceAccountId'] as String?,
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
  }) =>
      SavingsGoal(
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
        id: j['id'] as String,
        name: j['name'] as String,
        type: enumFromString(GoalType.values, j['type'] as String?, GoalType.general),
        targetAmount: (j['targetAmount'] as num).toDouble(),
        currentAmount: (j['currentAmount'] as num?)?.toDouble() ?? 0,
        targetDate: j['targetDate'] == null ? null : DateTime.tryParse(j['targetDate'] as String),
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

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'lastSeen': lastSeen.toIso8601String(), 'trusted': trusted};

  static SecurityDevice fromJson(Map<String, dynamic> j) => SecurityDevice(
        id: j['id'] as String,
        name: j['name'] as String,
        lastSeen: DateTime.tryParse((j['lastSeen'] as String?) ?? '') ?? DateTime.now(),
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
        id: j['id'] as String,
        title: j['title'] as String,
        severity: enumFromString(EventSeverity.values, j['severity'] as String?, EventSeverity.low),
        date: DateTime.tryParse((j['date'] as String?) ?? '') ?? DateTime.now(),
        resolved: (j['resolved'] as bool?) ?? false,
        description: j['description'] as String?,
      );
}

class SecurityOverview {
  const SecurityOverview({required this.score, this.twoFactorEnabled = false});

  final int score;
  final bool twoFactorEnabled;

  SecurityOverview copyWith({int? score, bool? twoFactorEnabled}) => SecurityOverview(
        score: score ?? this.score,
        twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      );

  Map<String, dynamic> toJson() => {'score': score, 'twoFactorEnabled': twoFactorEnabled};

  static SecurityOverview fromJson(Map<String, dynamic> j) => SecurityOverview(
        score: (j['score'] as num?)?.toInt() ?? 0,
        twoFactorEnabled: (j['twoFactorEnabled'] as bool?) ?? false,
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
        id: j['id'] as String,
        clientName: j['clientName'] as String,
        amount: (j['amount'] as num).toDouble(),
        currency: (j['currency'] as String?) ?? 'MUR',
        dueDate: DateTime.tryParse((j['dueDate'] as String?) ?? '') ?? DateTime.now(),
        status: enumFromString(InvoiceStatus.values, j['status'] as String?, InvoiceStatus.sent),
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

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'totalSpend': totalSpend, 'reliabilityScore': reliabilityScore};

  static Vendor fromJson(Map<String, dynamic> j) => Vendor(
        id: j['id'] as String,
        name: j['name'] as String,
        totalSpend: (j['totalSpend'] as num?)?.toDouble() ?? 0,
        reliabilityScore: (j['reliabilityScore'] as num?)?.toInt() ?? 80,
      );
}

class Payee {
  const Payee({required this.id, required this.name, this.destination});

  final String id;
  final String name;
  final String? destination;

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'destination': destination};

  static Payee fromJson(Map<String, dynamic> j) => Payee(
        id: j['id'] as String,
        name: j['name'] as String,
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
        id: j['id'] as String,
        sourceAccountId: j['sourceAccountId'] as String,
        payeeName: j['payeeName'] as String,
        destination: j['destination'] as String,
        amount: (j['amount'] as num).toDouble(),
        fee: (j['fee'] as num).toDouble(),
        total: (j['total'] as num).toDouble(),
        status: enumFromString(TransferStatus.values, j['status'] as String?, TransferStatus.completed),
        createdAt: DateTime.tryParse((j['createdAt'] as String?) ?? '') ?? DateTime.now(),
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
        id: j['id'] as String,
        category: enumFromString(BillCategory.values, j['category'] as String?, BillCategory.electricity),
        billerName: (j['billerName'] as String?) ?? '',
        amount: (j['amount'] as num).toDouble(),
        status: enumFromString(BillPaymentStatus.values, j['status'] as String?, BillPaymentStatus.paid),
        date: DateTime.tryParse((j['date'] as String?) ?? '') ?? DateTime.now(),
        customerRef: j['customerRef'] as String?,
        scheduledFor: j['scheduledFor'] == null ? null : DateTime.tryParse(j['scheduledFor'] as String),
      );
}
