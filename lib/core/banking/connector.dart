import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models.dart';

/// A bank / mobile-money provider the user can connect.
class Institution {
  const Institution({
    required this.id,
    required this.name,
    required this.type,
    this.blurb,
    this.country = 'MU',
    this.code,
  });

  final String id;
  final String name;
  final AccountType type;
  final String? blurb;
  final String country;
  final String? code;
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
  static List<Institution>? _cachedRemoteNgBanks;

  static const List<Institution> _list = [
    Institution(
      id: 'mcb',
      name: 'MCB',
      type: AccountType.bank,
      blurb: 'Mauritius Commercial Bank',
      country: 'MU',
      code: 'MCB',
    ),
    Institution(
      id: 'sbm',
      name: 'SBM',
      type: AccountType.bank,
      blurb: 'State Bank of Mauritius',
      country: 'MU',
      code: 'SBM',
    ),
    Institution(
      id: 'bankone',
      name: 'Bank One',
      type: AccountType.bank,
      blurb: 'Digital-first bank',
      country: 'MU',
      code: 'BANKONE',
    ),
    Institution(
      id: 'maubank',
      name: 'Maubank',
      type: AccountType.bank,
      blurb: 'Everyday banking',
      country: 'MU',
      code: 'MAUBANK',
    ),
    Institution(
      id: 'myt',
      name: 'my.t money',
      type: AccountType.mobileMoney,
      blurb: 'Mobile wallet',
      country: 'MU',
      code: 'MYT',
    ),
    Institution(
      id: 'emtel',
      name: 'Emtel Money',
      type: AccountType.mobileMoney,
      blurb: 'Mobile wallet',
      country: 'MU',
      code: 'EMTEL',
    ),
    Institution(
      id: 'juice',
      name: 'Juice',
      type: AccountType.mobileMoney,
      blurb: 'Mobile wallet',
      country: 'MU',
      code: 'JUICE',
    ),
    // Nigeria banks & fintech wallets with CBN codes
    Institution(
      id: 'gtbank',
      name: 'GTBank',
      type: AccountType.bank,
      blurb: 'Guaranty Trust Bank (Code 058)',
      country: 'NG',
      code: '058',
    ),
    Institution(
      id: 'access',
      name: 'Access Bank',
      type: AccountType.bank,
      blurb: 'Commercial bank (Code 044)',
      country: 'NG',
      code: '044',
    ),
    Institution(
      id: 'zenith',
      name: 'Zenith Bank',
      type: AccountType.bank,
      blurb: 'Corporate & retail bank (Code 057)',
      country: 'NG',
      code: '057',
    ),
    Institution(
      id: 'firstbank',
      name: 'First Bank',
      type: AccountType.bank,
      blurb: 'First Bank of Nigeria (Code 011)',
      country: 'NG',
      code: '011',
    ),
    Institution(
      id: 'uba',
      name: 'UBA',
      type: AccountType.bank,
      blurb: 'United Bank for Africa (Code 033)',
      country: 'NG',
      code: '033',
    ),
    Institution(
      id: 'kuda',
      name: 'Kuda Bank',
      type: AccountType.bank,
      blurb: 'Digital bank for the free (Code 50211)',
      country: 'NG',
      code: '50211',
    ),
    Institution(
      id: 'moniepoint',
      name: 'Moniepoint',
      type: AccountType.bank,
      blurb: 'Business & personal banking (Code 50515)',
      country: 'NG',
      code: '50515',
    ),
    Institution(
      id: 'opay',
      name: 'OPay',
      type: AccountType.mobileMoney,
      blurb: 'Mobile wallet & payments (Code 999992)',
      country: 'NG',
      code: '999992',
    ),
    Institution(
      id: 'palmpay',
      name: 'PalmPay',
      type: AccountType.mobileMoney,
      blurb: 'Rewards & money app (Code 999991)',
      country: 'NG',
      code: '999991',
    ),
    Institution(
      id: 'stanbic',
      name: 'Stanbic IBTC Bank',
      type: AccountType.bank,
      blurb: 'Commercial bank (Code 221)',
      country: 'NG',
      code: '221',
    ),
    Institution(
      id: 'fidelity',
      name: 'Fidelity Bank',
      type: AccountType.bank,
      blurb: 'Commercial bank (Code 070)',
      country: 'NG',
      code: '070',
    ),
    Institution(
      id: 'sterling',
      name: 'Sterling Bank',
      type: AccountType.bank,
      blurb: 'Commercial bank (Code 232)',
      country: 'NG',
      code: '232',
    ),
    Institution(
      id: 'union',
      name: 'Union Bank',
      type: AccountType.bank,
      blurb: 'Union Bank of Nigeria (Code 032)',
      country: 'NG',
      code: '032',
    ),
    Institution(
      id: 'wema',
      name: 'Wema Bank (ALAT)',
      type: AccountType.bank,
      blurb: 'Digital & retail bank (Code 035)',
      country: 'NG',
      code: '035',
    ),
    Institution(
      id: 'fcmb',
      name: 'FCMB',
      type: AccountType.bank,
      blurb: 'First City Monument Bank (Code 214)',
      country: 'NG',
      code: '214',
    ),
    Institution(
      id: 'ecobank',
      name: 'Ecobank',
      type: AccountType.bank,
      blurb: 'Ecobank Nigeria (Code 050)',
      country: 'NG',
      code: '050',
    ),
  ];

  @override
  Future<List<Institution>> institutions({String? country}) async {
    final c = country?.toUpperCase();
    if (c == 'NG') {
      if (_cachedRemoteNgBanks != null && _cachedRemoteNgBanks!.isNotEmpty) {
        return _cachedRemoteNgBanks!;
      }
      try {
        final uri = Uri.parse('https://api.paystack.co/bank?country=nigeria');
        final res = await http.get(uri).timeout(const Duration(seconds: 3));
        if (res.statusCode == 200) {
          final decoded = jsonDecode(res.body) as Map<String, dynamic>;
          if (decoded['status'] == true && decoded['data'] is List) {
            final rawList = decoded['data'] as List;
            final localNg = _list.where((i) => i.country == 'NG').toList();
            final seenCodes = localNg.map((i) => i.code).toSet();
            final merged = <Institution>[...localNg];
            for (final item in rawList) {
              final m = item as Map<String, dynamic>;
              final name = (m['name'] as String?) ?? '';
              final code = (m['code'] as String?) ?? '';
              final slug = (m['slug'] as String?) ?? code;
              if (name.isEmpty || code.isEmpty) continue;
              if (seenCodes.contains(code)) continue;
              seenCodes.add(code);
              final isWallet = name.toLowerCase().contains('opay') ||
                  name.toLowerCase().contains('palmpay') ||
                  name.toLowerCase().contains('wallet');
              merged.add(
                Institution(
                  id: slug.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase(),
                  name: name,
                  type: isWallet ? AccountType.mobileMoney : AccountType.bank,
                  code: code,
                  country: 'NG',
                  blurb: 'Bank code $code',
                ),
              );
            }
            if (merged.isNotEmpty) {
              _cachedRemoteNgBanks = merged;
              return merged;
            }
          }
        }
      } catch (_) {
        // Fallback gracefully on timeout or offline
      }
    }
    if (c == null) return _list;
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
