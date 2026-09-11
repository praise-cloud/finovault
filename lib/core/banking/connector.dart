import '../models.dart';

/// A bank / mobile-money provider the user can connect.
class Institution {
  const Institution({
    required this.id,
    required this.name,
    required this.type,
    this.blurb,
  });

  final String id;
  final String name;
  final AccountType type;
  final String? blurb;
}

/// One imported transaction the connector wants the app to seed when an
/// account is linked. Timestamps are expressed as `daysAgo` so the consumer
/// can place them on the right date.
class SeedTxn {
  const SeedTxn({
    required this.daysAgo,
    required this.amount,
    required this.direction,
    required this.category,
    required this.merchantName,
  });

  final int daysAgo;
  final double amount;
  final TransactionDirection direction;
  final String category;
  final String merchantName;
}

/// Result of "connecting" an institution: the opening balance plus the
/// imported history the app should persist.
class ConnectPlan {
  const ConnectPlan({required this.startingBalance, required this.history});

  final double startingBalance;
  final List<SeedTxn> history;
}

/// Swappable bank-aggregation seam. `MockBankConnector` fabricates a believable
/// history; a real implementation would perform OAuth + OFX/Open Banking import.
abstract class BankConnector {
  Future<List<Institution>> institutions();
  Future<ConnectPlan> planFor(String institutionId, AccountType type);
}

class MockBankConnector implements BankConnector {
  static const List<Institution> _list = [
    Institution(
      id: 'mcb',
      name: 'MCB',
      type: AccountType.bank,
      blurb: 'Mauritius Commercial Bank',
    ),
    Institution(
      id: 'sbm',
      name: 'SBM',
      type: AccountType.bank,
      blurb: 'State Bank of Mauritius',
    ),
    Institution(
      id: 'bankone',
      name: 'Bank One',
      type: AccountType.bank,
      blurb: 'Digital-first bank',
    ),
    Institution(
      id: 'maubank',
      name: 'Maubank',
      type: AccountType.bank,
      blurb: 'Everyday banking',
    ),
    Institution(
      id: 'myt',
      name: 'my.t money',
      type: AccountType.mobileMoney,
      blurb: 'Mobile wallet',
    ),
    Institution(
      id: 'emtel',
      name: 'Emtel Money',
      type: AccountType.mobileMoney,
      blurb: 'Mobile wallet',
    ),
    Institution(
      id: 'juice',
      name: 'Juice',
      type: AccountType.mobileMoney,
      blurb: 'Mobile wallet',
    ),
  ];

  @override
  Future<List<Institution>> institutions() async => _list;

  @override
  Future<ConnectPlan> planFor(String institutionId, AccountType type) async {
    final seed = institutionId.hashCode;
    final isWallet = type == AccountType.mobileMoney;
    final startingBalance = isWallet
        ? 3200.0 + (seed % 900)
        : 64000.0 + (seed % 40000);
    final history = <SeedTxn>[];
    // Walk backwards ~45 days, emitting a believable rhythm of activity.
    for (var d = 1; d <= 45; d++) {
      final k = (seed + d * 7) % 10;
      if (d % 3 == 0) {
        history.add(
          SeedTxn(
            daysAgo: d,
            amount: isWallet ? 60 + (k * 17) : 1400 + (k * 320),
            direction: TransactionDirection.inn,
            category: isWallet ? 'client payment' : 'salary',
            merchantName: isWallet ? 'Transfer in' : 'Payroll',
          ),
        );
      }
      if (d % 2 == 0) {
        history.add(
          SeedTxn(
            daysAgo: d,
            amount: isWallet ? 40 + (k * 9) : 380 + (k * 70),
            direction: TransactionDirection.out,
            category: _spend(k),
            merchantName: _merchant(k),
          ),
        );
      }
    }
    return ConnectPlan(startingBalance: startingBalance, history: history);
  }

  String _spend(int k) {
    const cats = [
      'groceries',
      'transport',
      'utilities',
      'dining',
      'software',
      'supplies',
    ];
    return cats[k % cats.length];
  }

  String _merchant(int k) {
    const m = [
      'Shoprite',
      'Bus ticket',
      'CEB',
      'Lambrooks',
      'Flicks',
      'Canva',
      'Office Supplies',
    ];
    return m[k % m.length];
  }
}
