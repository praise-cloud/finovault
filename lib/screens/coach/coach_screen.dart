import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/coach/coach_models.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../core/state/auth.dart';
import '../../core/state/money.dart';
import '../../theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/ui.dart';
import '../money/budgets_screen.dart';
import '../money/goals_list_screen.dart';
import '../money/invoices_screen.dart';
import '../money/pension_screen.dart';
import '../money/transactions_screen.dart';
import '../tabs/vault_tab.dart';

class CoachScreen extends ConsumerStatefulWidget {
  const CoachScreen({super.key});

  @override
  ConsumerState<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends ConsumerState<CoachScreen> {
  final _prompt = TextEditingController();
  final _messages = <CoachMessage>[];
  bool _busy = false;
  bool _greeted = false;

  @override
  void initState() {
    super.initState();
  }

  CoachContext _ctx() {
    final user = ref.read(currentUserProvider);
    final role = user?.primaryRole ?? PrimaryRole.individual;
    final accounts =
        ref.read(accountsProvider).whenOrNull(data: (l) => l) ?? [];
    final txns =
        ref.read(transactionsProvider).whenOrNull(data: (l) => l) ?? [];
    final goals = ref.read(goalsProvider).whenOrNull(data: (l) => l) ?? [];
    final total = accounts.fold<double>(0, (s, a) => s + a.balance);
    final cut = DateTime.now().subtract(const Duration(days: 30));
    double inc = 0, exp = 0;
    final cats = <String, double>{};
    for (final t in txns) {
      if (t.date.isBefore(cut)) continue;
      if (t.direction == TransactionDirection.inn) {
        inc += t.amount;
      } else {
        exp += t.amount;
        cats[t.category] = (cats[t.category] ?? 0) + t.amount;
      }
    }
    final topCats = cats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final goal = goals.isNotEmpty ? goals.first : null;
    return CoachContext(
      role: role,
      name: user?.fullName ?? 'there',
      totalBalance: total,
      monthlyIncome: inc,
      monthlyExpense: exp,
      topCategories: topCats.take(3).map((e) => e.key).toList(),
      topGoal: goal?.name,
      goalProgress: goal != null && goal.targetAmount > 0
          ? goal.currentAmount / goal.targetAmount
          : null,
      currency: 'MUR',
    );
  }

  void _greet(AppLocalizations s) {
    final ctx = _ctx();
    final flow = ctx.monthlyIncome - ctx.monthlyExpense >= 0
        ? s.cashFlowHealthy
        : s.cashFlowTight;
    _messages.add(
      CoachMessage(
        role: CoachRole.assistant,
        text: s.coachGreeting(
          ctx.name.split(' ').first,
          ctx.totalBalance.round().toString(),
          flow,
        ),
        actions: [s.coachPromptSpending, s.coachPromptSave, s.coachPromptGrow],
      ),
    );
  }

  void _ask(String prompt) {
    final s = AppLocalizations.of(context);
    final text = prompt.trim();
    if (text.isEmpty || _busy) return;
    final ctx = _ctx();
    _prompt.clear();
    setState(() {
      _messages.add(CoachMessage(role: CoachRole.user, text: text));
      _messages.add(CoachMessage(role: CoachRole.assistant, text: ''));
      _busy = true;
    });
    final sub = ref.read(coachProvider).send(text, ctx, s).listen((part) {
      setState(() {
        final last = _messages.last;
        if (part.text != null) last.text += part.text!;
        if (part.actions != null) last.actions = part.actions!;
      });
    }, onDone: () => setState(() => _busy = false));
    // ignore: avoid_single_cascade_in_expression_statements
    sub.onError(
      (e) => setState(() {
        _messages.last.text = 'Coach is offline right now.';
        _busy = false;
      }),
    );
  }

  void _handleAction(String action) {
    if (action.toLowerCase().startsWith('open ')) {
      _navigate(action.substring(5).trim());
    } else {
      _ask(action);
    }
  }

  void _navigate(String target) {
    final t = target.toLowerCase();
    Widget? screen;
    if (t.contains('goal')) {
      screen = const GoalsListScreen();
    } else if (t.contains('budget')) {
      screen = const BudgetsScreen();
    } else if (t.contains('invoice')) {
      screen = const InvoicesScreen();
    } else if (t.contains('transaction')) {
      screen = const TransactionsScreen();
    } else if (t.contains('pension')) {
      screen = const PensionScreen();
    } else if (t.contains('vault')) {
      screen = ScreenPage(title: 'Vault', child: VaultTab());
    }
    if (screen != null) pushScreen(context, screen);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final role =
        ref.watch(currentUserProvider)?.primaryRole ?? PrimaryRole.individual;
    final accent = FvColors.roleAccent(role);
    final ctx = _ctx();
    if (!_greeted) {
      _greeted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _greet(s));
    }
    return ScreenPage(
      title: s.coachTitle,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: FvSpacing.x3),
            padding: const EdgeInsets.all(FvSpacing.x4),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(FvRadius.card),
              border: Border.all(
                color: context.fvCardBorder,
                width: FvBorders.width,
              ),
            ),
            child: Row(
              children: [
                Container(width: 8, height: 8, color: accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s.snapshot.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: context.fvText,
                    ),
                  ),
                ),
                MoneyText(
                  ctx.totalBalance,
                  size: MoneySize.sm,
                  currency: 'MUR',
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _messages.length,
              separatorBuilder: (_, _) => const SizedBox(height: FvSpacing.x3),
              itemBuilder: (_, i) {
                final m = _messages[i];
                final isUser = m.role == CoachRole.user;
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.82,
                    ),
                    padding: const EdgeInsets.all(FvSpacing.x4),
                    decoration: BoxDecoration(
                      color: isUser ? FvColors.ink : context.fvSurface,
                      borderRadius: BorderRadius.circular(FvRadius.card),
                      border: Border.all(
                        color: context.fvCardBorder,
                        width: FvBorders.width,
                      ),
                      boxShadow: context.fvBrutalSm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.text,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isUser ? Colors.white : context.fvText,
                          ),
                        ),
                        if (m.actions.isNotEmpty) ...[
                          const SizedBox(height: FvSpacing.x3),
                          Wrap(
                            spacing: FvSpacing.x2,
                            runSpacing: FvSpacing.x2,
                            children: m.actions
                                .map(
                                  (a) => GestureDetector(
                                    onTap: () => _handleAction(a),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: accent.withValues(alpha: 0.14),
                                        borderRadius: BorderRadius.circular(
                                          FvRadius.badge,
                                        ),
                                        border: Border.all(
                                          color: context.fvCardBorder,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Text(
                                        a.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.4,
                                          color: context.fvText,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: FvSpacing.x3),
          Container(
            decoration: BoxDecoration(
              color: context.fvSurface,
              borderRadius: BorderRadius.circular(FvRadius.input),
              border: Border.all(
                color: context.fvPrimary,
                width: FvBorders.width,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _prompt,
                    onSubmitted: _ask,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.fvText,
                    ),
                    decoration: InputDecoration(
                      hintText: s.askCoachHint,
                      hintStyle: TextStyle(color: context.fvTextSecondary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: FvSpacing.x4,
                        vertical: FvSpacing.x3,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: _busy
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.fvPrimary,
                          ),
                        )
                      : Icon(Icons.send, color: context.fvPrimary),
                  onPressed: _busy ? null : () => _ask(_prompt.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
