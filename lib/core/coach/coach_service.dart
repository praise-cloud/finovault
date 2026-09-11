import 'dart:async';

import 'coach_models.dart';
import '../models.dart';
import '../../l10n/app_localizations.dart';

/// Swap-in seam for the Money Coach. `MockCoachService` is fully local and
/// data-aware; a real build drops in an `LlmCoachService` that calls an LLM
/// with the same [CoachContext] summary — no UI changes required.
abstract class CoachService {
  /// Returns a streamed assistant reply. Text chunks are appended in order;
  /// the final part carries optional follow-up action labels.
  Stream<CoachPart> send(String prompt, CoachContext ctx, AppLocalizations l10n);
}

class MockCoachService implements CoachService {
  @override
  Stream<CoachPart> send(String prompt, CoachContext ctx, AppLocalizations l10n) {
    final reply = _reply(prompt, ctx, l10n);
    final words = reply.text.split(' ');
    final controller = StreamController<CoachPart>();
    var i = 0;
    void tick() {
      if (i < words.length) {
        controller.add(CoachPart(text: (i == 0 ? '' : ' ') + words[i]));
        i++;
        Future.delayed(const Duration(milliseconds: 35), tick);
      } else {
        if (reply.actions.isNotEmpty) controller.add(CoachPart(actions: reply.actions));
        controller.close();
      }
    }

    Future.delayed(const Duration(milliseconds: 120), tick);
    return controller.stream;
  }

  ({String text, List<String> actions}) _reply(String prompt, CoachContext ctx, AppLocalizations l10n) {
    final p = prompt.toLowerCase();
    final roleLabel = switch (ctx.role) {
      PrimaryRole.freelancer => l10n.roleFreelancer,
      PrimaryRole.entrepreneur => l10n.roleEntrepreneur,
      PrimaryRole.sme => l10n.roleSme,
      _ => l10n.roleIndividual,
    };
    final goal = ctx.topGoal ?? l10n.yourTopGoal;
    final bp = ctx.businessProfile;

    // SME-specific: cash flow, vendors, compliance
    if (ctx.role == PrimaryRole.sme) {
      if (p.contains('cash') || p.contains('flow') || p.contains('runway')) {
        final runway = ctx.runwayMonths?.toStringAsFixed(1) ?? 'unknown';
        return (
          text: l10n.coachSmeCashFlow(_money(ctx.totalBalance, ctx.currency), runway, _money(ctx.monthlyPayroll ?? 0, ctx.currency)),
          actions: ['Open vendors', 'Open invoices', 'Open accounts']
        );
      }
      if (p.contains('vendor') || p.contains('supplier') || p.contains('payable')) {
        final topVendor = ctx.vendorSpend.entries.isNotEmpty
            ? ctx.vendorSpend.entries.reduce((a, b) => a.value > b.value ? a : b).key
            : l10n.noVendorsYet;
        final topVendorSpend = ctx.vendorSpend.values.isNotEmpty
            ? _money(ctx.vendorSpend.values.reduce((a, b) => a > b ? a : b), ctx.currency)
            : '0';
        return (
          text: l10n.coachSmeVendors(topVendor, topVendorSpend, _money(ctx.monthlyExpense, ctx.currency)),
          actions: ['Open vendors', 'Open transactions']
        );
      }
      if (p.contains('compliance') || p.contains('tax') || p.contains('filing') || p.contains('audit')) {
        final upcoming = ctx.upcomingCompliance.isNotEmpty
            ? ctx.upcomingCompliance.take(3).join(', ')
            : l10n.noUpcomingCompliance;
        return (
          text: l10n.coachSmeCompliance(upcoming),
          actions: ['Open security', 'Open settings']
        );
      }
      if (p.contains('payroll') || p.contains('salary') || p.contains('team') || p.contains('staff')) {
        return (
          text: l10n.coachSmePayroll(_money(ctx.monthlyPayroll ?? 0, ctx.currency), ctx.employeeCount?.toString() ?? '0', _money(ctx.monthlyExpense, ctx.currency)),
          actions: ['Open vendors', 'Open accounts']
        );
      }
    }

    // Entrepreneur-specific: fundraising, burn, hiring, MRR
    if (ctx.role == PrimaryRole.entrepreneur) {
      if (p.contains('fundrais') || p.contains('investor') || p.contains('round') || p.contains('valuation')) {
        return (
          text: l10n.coachEntrepreneurFundraising(_money(ctx.totalBalance, ctx.currency), _money(ctx.monthlyExpense, ctx.currency), ctx.runwayMonths?.toStringAsFixed(1) ?? '?'),
          actions: ['Open pension', 'Open vault']
        );
      }
      if (p.contains('burn') || p.contains('runway') || p.contains('efficienc')) {
        return (
          text: l10n.coachEntrepreneurBurn(_money(ctx.monthlyExpense, ctx.currency), ctx.runwayMonths?.toStringAsFixed(1) ?? '?'),
          actions: ['Open transactions', 'Open goals']
        );
      }
      if (p.contains('hire') || p.contains('team') || p.contains('headcount') || p.contains('staff')) {
        final revPerEmp = ctx.monthlyIncome > 0 && (ctx.employeeCount ?? 0) > 0
            ? _money(ctx.monthlyIncome / ctx.employeeCount!, ctx.currency)
            : 'N/A';
        return (
          text: l10n.coachEntrepreneurHiring(
            ctx.employeeCount?.toString() ?? '0',
            _money(ctx.monthlyPayroll ?? 0, ctx.currency),
            _money(ctx.monthlyIncome, ctx.currency),
            revPerEmp,
          ),
          actions: ['Open vendors', 'Open goals']
        );
      }
      if (p.contains('mrr') || p.contains('revenue') || p.contains('growth') || p.contains('arr')) {
        return (
          text: l10n.coachEntrepreneurRevenue(_money(ctx.monthlyIncome, ctx.currency), _money(ctx.monthlyExpense, ctx.currency), bp?.annualRevenueRange ?? 'unknown'),
          actions: ['Open invoices', 'Open transactions']
        );
      }
      // Female founder specific
      if (ctx.scheme == RoleScheme.femaleFounder && (p.contains('grant') || p.contains('women') || p.contains('female') || p.contains('fund'))) {
        return (
          text: l10n.coachFemaleFounderGrants,
          actions: ['Open insights', 'Open goals']
        );
      }
    }

    // Freelancer-specific: invoices, tax, clients
    if (ctx.role == PrimaryRole.freelancer) {
      if (p.contains('invoice') || p.contains('client') || p.contains('collect') || p.contains('paid')) {
        return (
          text: l10n.coachFreelancerInvoices(_money(ctx.monthlyIncome, ctx.currency), ctx.dso?.toStringAsFixed(0) ?? '?'),
          actions: ['Open invoices', 'Open transactions']
        );
      }
      if (p.contains('tax') || p.contains('set aside') || p.contains('reserve')) {
        return (
          text: l10n.coachFreelancerTax(_money(ctx.monthlyIncome * 0.2, ctx.currency), _money(ctx.monthlyIncome, ctx.currency)),
          actions: ['Open goals', 'Open transactions']
        );
      }
    }

    // Generic save/budget/spend
    if (p.contains('save') || p.contains('budget') || p.contains('spend')) {
      return (
        text: l10n.coachSave(
          _money(ctx.monthlyIncome, ctx.currency),
          _money(ctx.monthlyExpense, ctx.currency),
          _money(ctx.monthlyIncome - ctx.monthlyExpense, ctx.currency),
          ctx.topCategories.take(2).join(' ${l10n.andWord} '),
          goal,
        ),
        actions: ['Open goals', 'Open budgets']
      );
    }
    if (p.contains('invest') || p.contains('grow') || p.contains('pension')) {
      return (
        text: l10n.coachInvest(_money(ctx.totalBalance, ctx.currency), roleLabel),
        actions: ['Open pension', 'Open vault']
      );
    }
    if (p.contains('tax') || p.contains('invoice') || p.contains('client')) {
      return (
        text: l10n.coachTax,
        actions: ['Open invoices', 'Open transactions']
      );
    }
    // Default persona-grounded greeting / nudge.
    final surplus = ctx.monthlyIncome - ctx.monthlyExpense;
    return (
      text: l10n.coachDefault(
        ctx.name.split(' ').first,
        _money(ctx.totalBalance, ctx.currency),
        surplus >= 0 ? l10n.cashFlowHealthy : l10n.cashFlowTight,
        roleLabel,
        goal,
      ),
      actions: [l10n.coachPromptSpending, l10n.coachPromptSave, l10n.coachPromptGrow]
    );
  }

  String _money(double v, String c) => '${c == 'MUR' ? 'Rs ' : ''}${v.round()}';
}

/// Real-LLM placeholder. Wiring point for Phase 5 — intentionally throws so the
/// app never silently falls back to an unconfigured backend.
class LlmCoachService implements CoachService {
  const LlmCoachService({required this.endpoint});

  final String endpoint;

  @override
  Stream<CoachPart> send(String prompt, CoachContext ctx, AppLocalizations l10n) => Stream.error(
        UnimplementedError('LlmCoachService not configured (endpoint: $endpoint)'),
      );
}
