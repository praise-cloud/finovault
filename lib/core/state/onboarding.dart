import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models.dart';
import '../mock/api.dart';
import '../mock/db.dart';
import '../providers.dart';

enum OnboardingStep { welcome, role, goals, linkAccounts, complete }

class OnboardingState {
  const OnboardingState({
    this.step = OnboardingStep.welcome,
    this.role,
    this.scheme = RoleScheme.standard,
    this.financialGoals = const [],
    this.riskTolerance,
  });

  final OnboardingStep step;
  final PrimaryRole? role;
  final RoleScheme scheme;
  final List<String> financialGoals;
  final RiskTolerance? riskTolerance;

  bool get isComplete => step == OnboardingStep.complete;

  OnboardingState copyWith({
    OnboardingStep? step,
    PrimaryRole? role,
    RoleScheme? scheme,
    List<String>? financialGoals,
    RiskTolerance? riskTolerance,
  }) =>
      OnboardingState(
        step: step ?? this.step,
        role: role ?? this.role,
        scheme: scheme ?? this.scheme,
        financialGoals: financialGoals ?? this.financialGoals,
        riskTolerance: riskTolerance ?? this.riskTolerance,
      );

  Map<String, dynamic> toJson() => {
        'step': step.name,
        'role': role?.name,
        'scheme': scheme.name,
        'financialGoals': financialGoals,
        'riskTolerance': riskTolerance?.name,
      };

  static OnboardingState fromJson(Map<String, dynamic>? j) => OnboardingState(
        step: switch (j?['step'] as String?) {
          'role' => OnboardingStep.role,
          'goals' => OnboardingStep.goals,
          'linkAccounts' || 'link-accounts' => OnboardingStep.linkAccounts,
          'complete' => OnboardingStep.complete,
          _ => OnboardingStep.welcome,
        },
        role: switch (j?['role'] as String?) {
          'individual' => PrimaryRole.individual,
          'freelancer' => PrimaryRole.freelancer,
          'entrepreneur' => PrimaryRole.entrepreneur,
          'sme' => PrimaryRole.sme,
          _ => null,
        },
        scheme: (j?['scheme'] as String?) == 'femaleFounder' ? RoleScheme.femaleFounder : RoleScheme.standard,
        financialGoals: ((j?['financialGoals'] as List?) ?? const []).cast<String>(),
        riskTolerance: switch (j?['riskTolerance'] as String?) {
          'low' => RiskTolerance.low,
          'high' => RiskTolerance.high,
          'moderate' => RiskTolerance.moderate,
          _ => null,
        },
      );
}

const _onboardingKey = 'finovault.onboarding.v1';

final initialOnboardingProvider = Provider<OnboardingState>((ref) => const OnboardingState());

class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => ref.read(initialOnboardingProvider);

  Future<void> _persist() async {
    await ref.read(kvStoreProvider).setString(_onboardingKey, jsonEncode(state.toJson()));
  }

  /// Welcome screen CTA — begin the flow.
  Future<void> start() async {
    if (state.step == OnboardingStep.welcome || state.step == OnboardingStep.complete) {
      state = state.copyWith(step: OnboardingStep.role);
      await _persist();
    }
  }

  /// Step backwards through the linear onboarding flow:
  /// linkAccounts → goals → role → welcome.
  Future<void> back() async {
    state = state.copyWith(
      step: switch (state.step) {
        OnboardingStep.linkAccounts => OnboardingStep.goals,
        OnboardingStep.goals => OnboardingStep.role,
        OnboardingStep.role => OnboardingStep.welcome,
        _ => state.step,
      },
    );
    await _persist();
  }

  Future<void> selectRole(PrimaryRole role, {required bool femaleFounder}) async {
    state = state.copyWith(
      step: OnboardingStep.goals,
      role: role,
      scheme: role == PrimaryRole.entrepreneur && femaleFounder
          ? RoleScheme.femaleFounder
          : RoleScheme.standard,
    );
    await _persist();
  }

  Future<void> setGoals(List<String> goals, RiskTolerance? risk) async {
    state = state.copyWith(
      step: OnboardingStep.linkAccounts,
      financialGoals: goals,
      riskTolerance: risk,
    );
    await _persist();
  }

  /// Finish — persists role + preferences to the backend (best-effort) and
  /// marks onboarding complete.
  Future<void> complete() async {
    final api = ref.read(apiProvider);
    final token = ref.read(kvStoreProvider).getString(sessionKey);
    final s = state;
    try {
      if (token != null && s.role != null) {
        await api.setRole(token, primaryRole: s.role!, scheme: s.scheme);
        await api.savePreferences(
          token,
          UserPreferences(
            financialGoals: s.financialGoals,
            riskTolerance: s.riskTolerance,
            onboardingCompleted: true,
          ),
        );
      }
    } on FvApiException {
      // Best-effort — local completion still stands.
    }
    state = state.copyWith(step: OnboardingStep.complete);
    await _persist();
  }

  Future<void> reset() async {
    state = const OnboardingState();
    await _persist();
  }

  /// Mark onboarding complete for a returning user who already has a role
  /// (i.e. logged in, not signing up). No API call — the role/preferences
  /// already exist server-side, we just stop showing the onboarding flow.
  Future<void> completeFromAuth() async {
    state = state.copyWith(step: OnboardingStep.complete);
    await _persist();
  }
}

final onboardingProvider =
    NotifierProvider<OnboardingController, OnboardingState>(OnboardingController.new);

OnboardingState loadInitialOnboarding(KvStore store) {
  try {
    final raw = store.getString(_onboardingKey);
    return OnboardingState.fromJson(raw == null ? null : jsonDecode(raw) as Map<String, dynamic>);
  } catch (_) {
    return const OnboardingState();
  }
}
