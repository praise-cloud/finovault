import '../models.dart';

/// A bank / mobile-money provider the user can connect.
class Institution {
  const Institution({
    required this.id,
    required this.name,
    required this.type,
    this.blurb,
    this.country = 'MU',
  });

  final String id;
  final String name;
  final AccountType type;
  final String? blurb;
  final String country;
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
  Future<List<Institution>> institutions({String? country});
  Future<ConnectPlan> planFor(String institutionId, AccountType type);
}

class MockBankConnector implements BankConnector {
  static const List<Institution> _list = [
    Institution(
      id: 'mcb',
      name: 'MCB',
      type: AccountType.bank,
      blurb: 'Mauritius Commercial Bank',
      country: 'MU',
    ),
    Institution(
      id: 'sbm',
      name: 'SBM',
      type: AccountType.bank,
      blurb: 'State Bank of Mauritius',
      country: 'MU',
    ),
    Institution(
      id: 'bankone',
      name: 'Bank One',
      type: AccountType.bank,
      blurb: 'Digital-first bank',
      country: 'MU',
    ),
    Institution(
      id: 'maubank',
      name: 'Maubank',
      type: AccountType.bank,
      blurb: 'Everyday banking',
      country: 'MU',
    ),
    Institution(
      id: 'myt',
      name: 'my.t money',
      type: AccountType.mobileMoney,
      blurb: 'Mobile wallet',
      country: 'MU',
    ),
    Institution(
      id: 'emtel',
      name: 'Emtel Money',
      type: AccountType.mobileMoney,
      blurb: 'Mobile wallet',
      country: 'MU',
    ),
    Institution(
      id: 'juice',
      name: 'Juice',
      type: AccountType.mobileMoney,
      blurb: 'Mobile wallet',
      country: 'MU',
    ),
    // Nigeria banks & fintech wallets
    Institution(
      id: 'gtbank',
      name: 'GTBank',
      type: AccountType.bank,
      blurb: 'Guaranty Trust Bank',
      country: 'NG',
    ),
    Institution(
      id: 'access',
      name: 'Access Bank',
      type: AccountType.bank,
      blurb: 'Commercial bank',
      country: 'NG',
    ),
    Institution(
      id: 'zenith',
      name: 'Zenith Bank',
      type: AccountType.bank,
      blurb: 'Corporate & retail bank',
      country: 'NG',
    ),
    Institution(
      id: 'firstbank',
      name: 'First Bank',
      type: AccountType.bank,
      blurb: 'First Bank of Nigeria',
      country: 'NG',
    ),
    Institution(
      id: 'uba',
      name: 'UBA',
      type: AccountType.bank,
      blurb: 'United Bank for Africa',
      country: 'NG',
    ),
    Institution(
      id: 'kuda',
      name: 'Kuda Bank',
      type: AccountType.bank,
      blurb: 'Digital bank for the free',
      country: 'NG',
    ),
    Institution(
      id: 'moniepoint',
      name: 'Moniepoint',
      type: AccountType.bank,
      blurb: 'Business & personal banking',
      country: 'NG',
    ),
    Institution(
      id: 'opay',
      name: 'OPay',
      type: AccountType.mobileMoney,
      blurb: 'Mobile wallet & payments',
      country: 'NG',
    ),
    Institution(
      id: 'palmpay',
      name: 'PalmPay',
      type: AccountType.mobileMoney,
      blurb: 'Rewards & money app',
      country: 'NG',
    ),
  ];

  @override
  Future<List<Institution>> institutions({String? country}) async {
    if (country == null) return _list;
    final c = country.toUpperCase();
    return _list.where((i) => i.country == c).toList();
  }

  @override
  Future<ConnectPlan> planFor(String institutionId, AccountType type) async {
    final seed = institutionId.hashCode;
    final inst = _list.firstWhere(
      (i) => i.id == institutionId,
      orElse: () => _list.first,
    );
    final isNg = inst.country == 'NG';
    final isWallet = type == AccountType.mobileMoney;
    final startingBalance = isNg
        ? (isWallet ? 25000.0 + (seed % 35000) : 350000.0 + (seed % 500000))
        : (isWallet ? 3200.0 + (seed % 900) : 64000.0 + (seed % 40000));
    final history = <SeedTxn>[];

    // Walk backwards ~45 days, emitting an authentic rhythm of activity.
    for (var d = 1; d <= 45; d++) {
      final k = (seed + d * 7) % 10;
      if (d % 3 == 0) {
        final amt = isNg
            ? (isWallet ? 15000.0 + (k * 2500) : 120000.0 + (k * 25000))
            : (isWallet ? 60.0 + (k * 17) : 1400.0 + (k * 320));
        history.add(
          SeedTxn(
            daysAgo: d,
            amount: amt,
            direction: TransactionDirection.inn,
            category: isWallet ? 'client payment' : 'salary',
            merchantName: isNg
                ? (isWallet ? 'Transfer in' : 'Payroll / Salary')
                : (isWallet ? 'Transfer in' : 'Payroll'),
          ),
        );
      }
      if (d % 2 == 0) {
        final amt = isNg
            ? (isWallet ? 2500.0 + (k * 800) : 12000.0 + (k * 3500))
            : (isWallet ? 40.0 + (k * 9) : 380.0 + (k * 70));
        history.add(
          SeedTxn(
            daysAgo: d,
            amount: amt,
            direction: TransactionDirection.out,
            category: isNg ? _spendNg(k) : _spendMu(k),
            merchantName: isNg ? _merchantNg(k) : _merchantMu(k),
          ),
        );
      }
    }
    return ConnectPlan(startingBalance: startingBalance, history: history);
  }

  String _spendMu(int k) {
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

  String _spendNg(int k) {
    const cats = [
      'groceries',
      'transport',
      'utilities',
      'dining',
      'airtime',
      'shopping',
    ];
    return cats[k % cats.length];
  }

  String _merchantMu(int k) {
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

  String _merchantNg(int k) {
    const m = [
      'Jumia',
      'Chicken Republic',
      'MTN Airtime',
      'Ikeja Electric',
      'Fuel / NNPC',
      'Spar Supermarket',
      'Uber Lagos',
    ];
    return m[k % m.length];
  }
}
