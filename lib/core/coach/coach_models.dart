import '../models.dart';

/// Snapshot of the user's finances the coach uses to ground its advice.
class CoachContext {
  const CoachContext({
    required this.role,
    required this.name,
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.topCategories,
    required this.topGoal,
    required this.goalProgress,
    required this.currency,
    this.businessProfile,
    this.employeeCount,
    this.businessStage,
    this.monthlyPayroll,
    this.runwayMonths,
    this.dso,
    this.dpo,
    this.vendorSpend = const {},
    this.upcomingCompliance = const [],
    this.scheme = RoleScheme.standard,
  });

  final PrimaryRole role;
  final String name;
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final List<String> topCategories;
  final String? topGoal;
  final double? goalProgress;
  final String currency;
  final BusinessProfile? businessProfile;
  final int? employeeCount;
  final BusinessStage? businessStage;
  final double? monthlyPayroll;
  final double? runwayMonths;
  final double? dso;
  final double? dpo;
  final Map<String, double> vendorSpend;
  final List<String> upcomingCompliance;
  final RoleScheme scheme;
}

enum CoachRole { user, assistant }

/// A single chat bubble.
class CoachMessage {
  CoachMessage({required this.role, required this.text, this.actions = const []});

  final CoachRole role;
  String text;
  List<String> actions;
}

/// A streamed chunk of the assistant reply (text appended, or terminal actions).
class CoachPart {
  const CoachPart({this.text, this.actions});

  final String? text;
  final List<String>? actions;
}
