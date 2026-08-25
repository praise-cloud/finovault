import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models.dart';
import 'api.dart';

/// Talks to the Finovault BFF over HTTP. It expects the envelope documented in
/// 18-API-CONTRACTS.md: `{ "data": <json>, "error": { "code", "message" } | null }`.
///
/// Each Dart method maps to a BFF RPC method of the same name. Enums are sent as
/// their `.name` and `DateTime` as ISO-8601; the BFF stores them as strings and
/// the model `fromJson` factories reconstruct the typed values on the way back.
class HttpFinovaultApi extends FinovaultApi {
  HttpFinovaultApi({required this.baseUrl, http.Client? client, Duration? timeout})
      : _client = client ?? http.Client(),
        _timeout = timeout ?? const Duration(seconds: 15);

  final String baseUrl;
  final http.Client _client;
  final Duration _timeout;

  void close() => _client.close();

  dynamic _enc(dynamic v) {
    if (v == null) return null;
    if (v is Enum) return v.name;
    if (v is DateTime) return v.toIso8601String();
    if (v is List) return v.map(_enc).toList();
    if (v is Map) return v.map((k, val) => MapEntry(k, _enc(val)));
    return v;
  }

  Map<String, dynamic> _encArgs(Map<String, dynamic> args) =>
      args.map((k, v) => MapEntry(k, _enc(v)));

  Future<dynamic> _rpc(
    String method,
    Map<String, dynamic> args, {
    String? token,
    String verb = 'POST',
  }) async {
    final uri = Uri.parse('$baseUrl/rpc');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final body = jsonEncode({'method': method, 'args': _encArgs(args)});
    late final http.Response res;
    try {
      res = verb == 'GET'
          ? await _client.get(uri, headers: headers).timeout(_timeout)
          : await _client.post(uri, headers: headers, body: body).timeout(_timeout);
    }     on TimeoutException {
      throw FvApiException('network', 'Request timed out. Check your connection.');
    } on SocketException catch (e) {
      throw FvApiException('network', 'Network error: ${e.message}');
    } on Exception {
      throw FvApiException('network', 'Unexpected response from server.');
    }

    final env = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    if (env['error'] != null) {
      final e = env['error'] as Map<String, dynamic>;
      final code = e['code']?.toString() ?? 'error';
      final message = e['message']?.toString() ?? 'Request failed';
      // 401/403 mean the session is no longer valid — surface it so the app
      // can clear the stored token and return to the welcome gate.
      if (res.statusCode == 401 || res.statusCode == 403 || code == 'unauthorized') {
        throw FvApiException('unauthorized', message);
      }
      throw FvApiException(code, message);
    }
    return env['data'];
  }

  List<T> _list<T>(dynamic data, T Function(Map<String, dynamic>) from) =>
      (data as List).map((e) => from(e as Map<String, dynamic>)).toList();

  @override
  Future<AuthResult> signup({
    required String fullName,
    required String email,
    required String password,
  }) async =>
      AuthResult.fromJson(await _rpc('signup', {
        'fullName': fullName,
        'email': email,
        'password': password,
      }));

  @override
  Future<AuthResult> login({required String email, required String password}) async =>
      AuthResult.fromJson(await _rpc('login', {'email': email, 'password': password}));

  @override
  Future<UserProfile?> getSession(String? token) async {
    final data = await _rpc('getSession', {}, token: token);
    return data == null ? null : UserProfile.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> logout(String? token) async => _rpc('logout', {}, token: token);

  @override
  Future<UserProfile> updateMe(
    String? token, {
    String? fullName,
    String? avatarUrl,
    String? preferredLanguage,
    String? preferredCurrency,
  }) async =>
      UserProfile.fromJson(await _rpc('updateMe', {
        'fullName': fullName,
        'avatarUrl': avatarUrl,
        'preferredLanguage': preferredLanguage,
        'preferredCurrency': preferredCurrency,
      }, token: token));

  @override
  Future<UserPreferences> getPreferences(String? token) async =>
      UserPreferences.fromJson(await _rpc('getPreferences', {}, token: token) as Map<String, dynamic>);

  @override
  Future<UserPreferences> savePreferences(String? token, UserPreferences patch) async =>
      UserPreferences.fromJson(await _rpc('savePreferences', {'patch': patch.toJson()}, token: token)
          as Map<String, dynamic>);

  @override
  Future<UserProfile> setRole(String? token, {required PrimaryRole primaryRole, required RoleScheme scheme}) async =>
      UserProfile.fromJson(await _rpc('setRole', {'primaryRole': primaryRole, 'scheme': scheme}, token: token));

  @override
  Future<List<Account>> accounts(String? token) async =>
      _list(await _rpc('accounts', {}, token: token), Account.fromJson);

  @override
  Future<Account> linkAccount(String? token,
          {required String name, required AccountType type, double balance = 0, String? institution}) async =>
      Account.fromJson(await _rpc('linkAccount',
          {'name': name, 'type': type, 'balance': balance, 'institution': institution}, token: token));

  @override
  Future<void> unlinkAccount(String? token, String accountId) async =>
      _rpc('unlinkAccount', {'accountId': accountId}, token: token);

  @override
  Future<List<Transaction>> transactions(String? token, {int limit = 20}) async =>
      _list(await _rpc('transactions', {'limit': limit}, token: token), Transaction.fromJson);

  @override
  Future<Transaction> createTransaction(
    String? token, {
    required String accountId,
    required double amount,
    required TransactionDirection direction,
    required String category,
    String? merchantName,
  }) async =>
      Transaction.fromJson(await _rpc('createTransaction', {
        'accountId': accountId,
        'amount': amount,
        'direction': direction,
        'category': category,
        'merchantName': merchantName,
      }, token: token));

  @override
  Future<List<Budget>> budgets(String? token) async =>
      _list(await _rpc('budgets', {}, token: token), Budget.fromJson);

  @override
  Future<Budget> createBudget(String? token, {required String category, required double amount}) async =>
      Budget.fromJson(await _rpc('createBudget', {'category': category, 'amount': amount}, token: token));

  @override
  Future<List<SavingsGoal>> goals(String? token) async =>
      _list(await _rpc('goals', {}, token: token), SavingsGoal.fromJson);

  @override
  Future<SavingsGoal> goal(String? token, String goalId) async =>
      SavingsGoal.fromJson(await _rpc('goal', {'goalId': goalId}, token: token));

  @override
  Future<SavingsGoal> createGoal(String? token,
          {required String name, required GoalType type, required double targetAmount, DateTime? targetDate}) async =>
      SavingsGoal.fromJson(await _rpc('createGoal',
          {'name': name, 'type': type, 'targetAmount': targetAmount, 'targetDate': targetDate}, token: token));

  @override
  Future<SavingsGoal> contribute(String? token,
          {required String goalId, required double amount, String? sourceAccountId}) async =>
      SavingsGoal.fromJson(await _rpc('contribute',
          {'goalId': goalId, 'amount': amount, 'sourceAccountId': sourceAccountId}, token: token));

  @override
  Future<PensionPlan?> getPensionPlan(String? token) async {
    final data = await _rpc('getPensionPlan', {}, token: token);
    return data == null ? null : PensionPlan.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<PensionProjection> pensionProjection(String? token) async =>
      PensionProjection.fromJson(await _rpc('pensionProjection', {}, token: token) as Map<String, dynamic>);

  @override
  Future<PensionPlan> upsertPensionPlan(
    String? token, {
    required double shortPotTarget,
    required double longPotTarget,
    required PensionFrequency frequency,
    required double contributionAmount,
    required double currentShortPot,
    required double currentLongPot,
    required double assumedReturnPct,
    required double inflationPct,
    required int currentAge,
    required int retirementAge,
    required bool autoDebit,
  }) async =>
      PensionPlan.fromJson(await _rpc('upsertPensionPlan', {
        'shortPotTarget': shortPotTarget,
        'longPotTarget': longPotTarget,
        'frequency': frequency,
        'contributionAmount': contributionAmount,
        'currentShortPot': currentShortPot,
        'currentLongPot': currentLongPot,
        'assumedReturnPct': assumedReturnPct,
        'inflationPct': inflationPct,
        'currentAge': currentAge,
        'retirementAge': retirementAge,
        'autoDebit': autoDebit,
      }, token: token));

  @override
  Future<PensionContribution> contributePension(
    String? token, {
    required String pot,
    required double amount,
    String? sourceAccountId,
  }) async =>
      PensionContribution.fromJson(await _rpc('contributePension',
          {'pot': pot, 'amount': amount, 'sourceAccountId': sourceAccountId}, token: token));

  @override
  Future<List<PensionContribution>> pensionContributions(String? token) async =>
      _list(await _rpc('pensionContributions', {}, token: token), PensionContribution.fromJson);

  @override
  Future<SecurityOverview> securityOverview(String? token) async =>
      SecurityOverview.fromJson(await _rpc('securityOverview', {}, token: token));

  @override
  Future<SecurityOverview> setTwoFactor(String? token, {required bool enabled}) async =>
      SecurityOverview.fromJson(await _rpc('setTwoFactor', {'enabled': enabled}, token: token));

  @override
  Future<List<SecurityDevice>> devices(String? token) async =>
      _list(await _rpc('devices', {}, token: token), SecurityDevice.fromJson);

  @override
  Future<List<SecurityEvent>> securityEvents(String? token) async =>
      _list(await _rpc('securityEvents', {}, token: token), SecurityEvent.fromJson);

  @override
  Future<SecurityEvent> resolveSecurityEvent(String? token, String eventId) async =>
      SecurityEvent.fromJson(await _rpc('resolveSecurityEvent', {'eventId': eventId}, token: token));

  @override
  Future<List<Invoice>> invoices(String? token) async =>
      _list(await _rpc('invoices', {}, token: token), Invoice.fromJson);

  @override
  Future<Invoice> createInvoice(String? token,
          {required String clientName, required double amount, required DateTime dueDate}) async =>
      Invoice.fromJson(await _rpc('createInvoice',
          {'clientName': clientName, 'amount': amount, 'dueDate': dueDate}, token: token));

  @override
  Future<Invoice> updateInvoiceStatus(String? token,
          {required String invoiceId, required InvoiceStatus status}) async =>
      Invoice.fromJson(await _rpc('updateInvoiceStatus', {'invoiceId': invoiceId, 'status': status}, token: token));

  @override
  Future<List<Vendor>> vendors(String? token) async =>
      _list(await _rpc('vendors', {}, token: token), Vendor.fromJson);

  @override
  Future<Vendor> createVendor(String? token, {required String name}) async =>
      Vendor.fromJson(await _rpc('createVendor', {'name': name}, token: token));

  @override
  Future<List<Transfer>> transfers(String? token) async =>
      _list(await _rpc('transfers', {}, token: token), Transfer.fromJson);

  @override
  Future<Transfer> transferById(String? token, String id) async =>
      Transfer.fromJson(await _rpc('transferById', {'id': id}, token: token));

  @override
  Future<Transfer> createTransfer(String? token,
          {required String sourceAccountId,
          required String payeeName,
          required String destination,
          required double amount,
          required String idempotencyKey}) async =>
      Transfer.fromJson(await _rpc('createTransfer', {
        'sourceAccountId': sourceAccountId,
        'payeeName': payeeName,
        'destination': destination,
        'amount': amount,
        'idempotencyKey': idempotencyKey,
      }, token: token));

  @override
  Future<List<Payee>> payees(String? token) async =>
      _list(await _rpc('payees', {}, token: token), Payee.fromJson);

  @override
  Future<Payee> createPayee(String? token, {required String name, String? destination}) async =>
      Payee.fromJson(await _rpc('createPayee', {'name': name, 'destination': destination}, token: token));

  @override
  Future<List<BillPayment>> billPayments(String? token) async =>
      _list(await _rpc('billPayments', {}, token: token), BillPayment.fromJson);

  @override
  Future<BillPayment> payBill(String? token,
          {required BillCategory category,
          required String billerName,
          required double amount,
          required String customerRef,
          String? sourceAccountId}) async =>
      BillPayment.fromJson(await _rpc('payBill', {
        'category': category,
        'billerName': billerName,
        'amount': amount,
        'customerRef': customerRef,
        'sourceAccountId': sourceAccountId,
      }, token: token));

  @override
  Future<BillPayment> scheduleBill(String? token,
          {required BillCategory category,
          required String billerName,
          required double amount,
          required String customerRef,
          required DateTime scheduledFor}) async =>
      BillPayment.fromJson(await _rpc('scheduleBill', {
        'category': category,
        'billerName': billerName,
        'amount': amount,
        'customerRef': customerRef,
        'scheduledFor': scheduledFor,
      }, token: token));
}
