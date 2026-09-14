import 'package:flutter_test/flutter_test.dart';
import 'package:finovault_flutter/core/banking/connector.dart';
import 'package:finovault_flutter/core/format.dart';
import 'package:finovault_flutter/core/mock/api.dart';
import 'package:finovault_flutter/core/mock/db.dart';
import 'package:finovault_flutter/core/models.dart';

void main() {
  group('Multi-Country Currency & Format', () {
    test('FvFormat formats NGN with Naira symbol', () {
      final formatted = FvFormat.formatMoney(250000.50, currency: 'NGN');
      expect(formatted, contains('₦'));
      expect(formatted, contains('250,000.50'));
    });

    test('FvFormat formats MUR with Rs symbol', () {
      final formatted = FvFormat.formatMoney(45000, currency: 'MUR');
      expect(formatted, contains('Rs'));
      expect(formatted, contains('45,000.00'));
    });
  });

  group('MockFinovaultApi Multi-Country Signup', () {
    late MockDb db;
    late MockFinovaultApi api;

    setUp(() async {
      db = MockDb();
      api = MockFinovaultApi(db: db, latency: Duration.zero);
    });

    test('Signup with Nigeria country and Nigerian phone creates NGN profile and accounts', () async {
      final result = await api.signup(
        fullName: 'Babatunde Adeyemi',
        email: 'babatunde@example.com',
        password: 'Password123!',
        phone: '08031234567',
        country: 'NG',
      );

      expect(result.user.country, equals('NG'));
      expect(result.user.preferredCurrency, equals('NGN'));
      expect(result.user.phone, equals('08031234567'));

      // Check seeded accounts for Nigerian user
      final accounts = await api.accounts(result.token);
      expect(accounts.length, equals(2));
      expect(accounts.any((a) => a.institution == 'GTBank' && a.currency == 'NGN'), isTrue);
      expect(accounts.any((a) => a.institution == 'OPay' && a.currency == 'NGN'), isTrue);
    });

    test('Signup with Nigeria rejects invalid phone numbers', () async {
      expect(
        () => api.signup(
          fullName: 'Babatunde Adeyemi',
          email: 'baba2@example.com',
          password: 'Password123!',
          phone: '12345',
          country: 'NG',
        ),
        throwsA(isA<FvApiException>()),
      );
    });

    test('Signup with Mauritius country and Mauritian phone creates MUR profile', () async {
      final result = await api.signup(
        fullName: 'Kevin Appadoo',
        email: 'kevin@example.mu',
        password: 'Password123!',
        phone: '57654321',
        country: 'MU',
      );

      expect(result.user.country, equals('MU'));
      expect(result.user.preferredCurrency, equals('MUR'));

      final accounts = await api.accounts(result.token);
      expect(accounts.length, equals(2));
      expect(accounts.any((a) => a.institution == 'SBM' && a.currency == 'MUR'), isTrue);
      expect(accounts.any((a) => a.institution == 'MCB' && a.currency == 'MUR'), isTrue);
    });
  });

  group('Nigerian Bank Account Linking & Automatic History Fetch', () {
    late MockDb db;
    late MockFinovaultApi api;

    setUp(() async {
      db = MockDb();
      api = MockFinovaultApi(db: db, latency: Duration.zero);
    });

    test('Linking Nigerian bank (GTBank) fetches 45 days of NGN transactions', () async {
      final signup = await api.signup(
        fullName: 'Chioma Okafor',
        email: 'chioma@example.ng',
        password: 'Password123!',
        phone: '08123456789',
        country: 'NG',
      );

      final linkResult = await api.linkBankAccount(
        signup.token,
        institution: 'GTBank',
        accountNumber: '0123456789',
      );

      expect(linkResult.account.currency, equals('NGN'));
      expect(linkResult.account.institution, equals('GTBank'));
      expect(linkResult.account.balance, greaterThan(300000));
      expect(linkResult.imported, greaterThan(20));

      final txs = await api.transactions(signup.token, limit: 50);
      expect(txs.isNotEmpty, isTrue);
      expect(txs.first.currency, equals('NGN'));
    });

    test('Linking Nigerian fintech wallet (OPay) validates wallet phone/number', () async {
      final signup = await api.signup(
        fullName: 'Emeka Balogun',
        email: 'emeka@example.ng',
        password: 'Password123!',
        phone: '09012345678',
        country: 'NG',
      );

      final linkResult = await api.linkBankAccount(
        signup.token,
        institution: 'OPay',
        accountNumber: '09012345678',
      );

      expect(linkResult.account.currency, equals('NGN'));
      expect(linkResult.account.type, equals(AccountType.mobileMoney));
      expect(linkResult.imported, greaterThan(20));
    });
  });

  group('BankConnector Country Filtering', () {
    final connector = MockBankConnector();

    test('institutions(country: "NG") returns only Nigerian institutions', () async {
      final nigerian = await connector.institutions(country: 'NG');
      expect(nigerian.every((i) => i.country == 'NG'), isTrue);
      expect(nigerian.any((i) => i.id == 'gtbank'), isTrue);
      expect(nigerian.any((i) => i.id == 'opay'), isTrue);
      expect(nigerian.any((i) => i.id == 'mcb'), isFalse);
    });

    test('institutions(country: "MU") returns only Mauritian institutions', () async {
      final mauritian = await connector.institutions(country: 'MU');
      expect(mauritian.every((i) => i.country == 'MU'), isTrue);
      expect(mauritian.any((i) => i.id == 'mcb'), isTrue);
      expect(mauritian.any((i) => i.id == 'sbm'), isTrue);
      expect(mauritian.any((i) => i.id == 'gtbank'), isFalse);
    });

    test('planFor Nigerian bank produces NGN starting balance and transactions', () async {
      final plan = await connector.planFor('gtbank', AccountType.bank);
      expect(plan.startingBalance, greaterThan(300000));
      expect(plan.history.isNotEmpty, isTrue);
    });

    test('institutions(country: "NG") includes official CBN bank codes', () async {
      final nigerian = await connector.institutions(country: 'NG');
      final gtbank = nigerian.firstWhere((i) => i.id == 'gtbank');
      expect(gtbank.code, equals('058'));

      final opay = nigerian.firstWhere((i) => i.id == 'opay');
      expect(opay.code, equals('999992'));

      final zenith = nigerian.firstWhere((i) => i.id == 'zenith');
      expect(zenith.code, equals('057'));
    });
  });

  group('NUBAN Verification & Live Resolution', () {
    late MockDb db;
    late MockFinovaultApi api;

    setUp(() async {
      db = MockDb();
      api = MockFinovaultApi(db: db, latency: Duration.zero);
    });

    test('verifyAccount resolves 10-digit NUBAN with bankCode when holderName is empty', () async {
      final signup = await api.signup(
        fullName: 'Folake Adebayo',
        email: 'folake@example.ng',
        password: 'Password123!',
        phone: '08023456789',
        country: 'NG',
      );

      final check = await api.verifyAccount(
        signup.token,
        institution: 'GTBank',
        identifier: '0123456789',
        holderName: '',
        bankCode: '058',
      );

      expect(check.exists, isTrue);
      expect(check.verified, isTrue);
      expect(check.holderName, isNotNull);
      expect(check.holderName!.isNotEmpty, isTrue);
    });

    test('verifyAccount rejects short identifiers', () async {
      final signup = await api.signup(
        fullName: 'Folake Adebayo',
        email: 'folake2@example.ng',
        password: 'Password123!',
        phone: '08023456789',
        country: 'NG',
      );

      final check = await api.verifyAccount(
        signup.token,
        institution: 'GTBank',
        identifier: '12345',
        holderName: '',
        bankCode: '058',
      );

      expect(check.exists, isFalse);
      expect(check.verified, isFalse);
    });
  });
}
