// Reference mock BFF for Finovault.
//
// Implements the RPC envelope documented in ../../18-API-CONTRACTS.md so the
// Flutter app can be exercised end-to-end over real HTTP without a backend.
//
// Run:
//   dart run tool/mock_bff/server.dart [--port 8080]
// Then point the app at it:
//   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
// (use 10.0.2.2 from the Android emulator; localhost from desktop).
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;

class MockBff {
  MockBff() {
    _seed();
  }

  final Map<String, dynamic> _store = {};
  final Map<String, Map<String, dynamic>> _sessions = {};
  int _seq = 0;

  String _id(String prefix) => '${prefix}_${++_seq}';

  void _seed() {
    _store['accounts'] = [
      {'id': 'acc_1', 'name': 'Main current', 'type': 'checking', 'balance': 128400.0, 'currency': 'MUR', 'institution': 'MCB'},
      {'id': 'acc_2', 'name': 'Stack', 'type': 'savings', 'balance': 56200.0, 'currency': 'MUR', 'institution': 'Absa'},
      {'id': 'acc_3', 'name': 'MyMo', 'type': 'mobileMoney', 'balance': 3200.0, 'currency': 'MUR', 'institution': 'Emtel'},
    ];
    _store['transactions'] = [
      {'id': _id('txn'), 'accountId': 'acc_1', 'amount': 4500.0, 'direction': 'out', 'category': 'Groceries', 'merchantName': 'Winners', 'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String()},
      {'id': _id('txn'), 'accountId': 'acc_1', 'amount': 22000.0, 'direction': 'inn', 'category': 'Salary', 'merchantName': 'Acme Ltd', 'date': DateTime.now().subtract(const Duration(days: 3)).toIso8601String()},
    ];
    _store['budgets'] = [
      {'id': _id('bud'), 'category': 'Groceries', 'amount': 12000.0},
      {'id': _id('bud'), 'category': 'Transport', 'amount': 6000.0},
    ];
    _store['goals'] = [
      {'id': 'goal_1', 'name': 'Emergency fund', 'type': 'emergency', 'targetAmount': 100000.0, 'currentAmount': 42000.0, 'targetDate': DateTime.now().add(const Duration(days: 365)).toIso8601String(), 'completed': false},
    ];
    _store['invoices'] = [
      {'id': _id('inv'), 'clientName': 'Globex', 'amount': 35000.0, 'dueDate': DateTime.now().add(const Duration(days: 7)).toIso8601String(), 'status': 'sent', 'issuedDate': DateTime.now().toIso8601String()},
    ];
    _store['vendors'] = [
      {'id': _id('ven'), 'name': 'Office Supplies Co', 'totalSpend': 18400.0},
    ];
    _store['transfers'] = <Map<String, dynamic>>[];
    _store['billPayments'] = [
      {'id': _id('bp'), 'category': 'electricity', 'billerName': 'CEB', 'amount': 1800.0, 'customerRef': 'CEB-9981', 'date': DateTime.now().toIso8601String(), 'status': 'paid'},
    ];
    _store['payees'] = [
      {'id': _id('pay'), 'name': 'Priya', 'destination': '9899123456'},
    ];
    _store['pensionPlan'] = {
      'shortPotTarget': 50000.0,
      'longPotTarget': 500000.0,
      'frequency': 'monthly',
      'contributionAmount': 2500.0,
      'currentShortPot': 12000.0,
      'currentLongPot': 80000.0,
      'assumedReturnPct': 7.0,
      'inflationPct': 4.0,
      'currentAge': 30,
      'retirementAge': 60,
      'autoDebit': false,
    };
    _store['securityOverview'] = {
      'score': 72,
      'twoFactor': false,
      'lastPasswordChange': DateTime.now().subtract(const Duration(days: 40)).toIso8601String(),
    };
    _store['devices'] = [
      {'id': _id('dev'), 'name': 'iPhone 15', 'lastActive': DateTime.now().toIso8601String(), 'current': true},
    ];
    _store['securityEvents'] = [
      {'id': _id('evt'), 'type': 'login', 'description': 'New sign-in from Port Louis', 'date': DateTime.now().toIso8601String(), 'resolved': false},
    ];
    _store['prefs'] = {'preferredLanguage': 'en', 'preferredCurrency': 'MUR', 'theme': 'system'};
  }

  Map<String, dynamic> _ok(dynamic data) => {'data': data, 'error': null};

  Map<String, dynamic> _fail(String code, String message) => {
        'data': null,
        'error': {'code': code, 'message': message},
      };

  Map<String, dynamic> _envelope(shelf.Request req, Map<String, dynamic> body) {
    final method = body['method'] as String? ?? '';
    final args = (body['args'] as Map? ?? {}).cast<String, dynamic>();
    final token = req.headers['authorization']?.replaceFirst('Bearer ', '');
    try {
      return _ok(_dispatch(method, args, token));
    } on _BffError catch (e) {
      return _fail(e.code, e.message);
    }
  }

  dynamic _dispatch(String method, Map<String, dynamic> a, String? token) {
    switch (method) {
      case 'login':
      case 'signup':
        final email = (a['email'] as String? ?? '').trim();
        final password = a['password'] as String? ?? '';
        if (method == 'login' && email == 'demo@finovault.app' && password != 'Vault123!') {
          throw const _BffError('unauthorized', 'Invalid demo credentials');
        }
        final t = 'tok_$email';
        final user = {
          'id': 'usr_1',
          'fullName': a['fullName'] as String? ?? email.split('@').first,
          'email': email,
          'primaryRole': 'individual',
          'scheme': 'standard',
          'avatarUrl': null,
        };
        _sessions[t] = user;
        return {'token': t, 'user': user};
      case 'getSession':
        if (token == null || !_sessions.containsKey(token)) return null;
        return _sessions[token];
      case 'logout':
        if (token != null) _sessions.remove(token);
        return null;
      case 'updateMe':
        final user = _sessions[token]!;
        if (a['fullName'] != null) user['fullName'] = a['fullName'];
        if (a['avatarUrl'] != null) user['avatarUrl'] = a['avatarUrl'];
        if (a['preferredLanguage'] != null) _store['prefs']['preferredLanguage'] = a['preferredLanguage'];
        if (a['preferredCurrency'] != null) _store['prefs']['preferredCurrency'] = a['preferredCurrency'];
        return user;
      case 'getPreferences':
        return Map<String, dynamic>.from(_store['prefs'] as Map);
      case 'savePreferences':
        final patch = (a['patch'] as Map? ?? {}).cast<String, dynamic>();
        (_store['prefs'] as Map).addAll(patch);
        return Map<String, dynamic>.from(_store['prefs'] as Map);
      case 'setRole':
        final user = _sessions[token]!;
        user['primaryRole'] = a['primaryRole'];
        user['scheme'] = a['scheme'];
        return user;
      case 'accounts':
        return List.from(_store['accounts'] as List);
      case 'linkAccount':
        final acc = {
          'id': _id('acc'),
          'name': a['name'],
          'type': a['type'],
          'balance': (a['balance'] as num? ?? 0).toDouble(),
          'currency': 'MUR',
          'institution': a['institution'],
        };
        (_store['accounts'] as List).add(acc);
        return acc;
      case 'unlinkAccount':
        _store['accounts'] = (_store['accounts'] as List).where((e) => e['id'] != a['accountId']).toList();
        return null;
      case 'transactions':
        return List.from(_store['transactions'] as List);
      case 'createTransaction':
        final txn = {
          'id': _id('txn'),
          'accountId': a['accountId'],
          'amount': a['amount'],
          'direction': a['direction'],
          'category': a['category'],
          'merchantName': a['merchantName'],
          'date': DateTime.now().toIso8601String(),
        };
        (_store['transactions'] as List).insert(0, txn);
        return txn;
      case 'budgets':
        return List.from(_store['budgets'] as List);
      case 'createBudget':
        final b = {'id': _id('bud'), 'category': a['category'], 'amount': a['amount']};
        (_store['budgets'] as List).add(b);
        return b;
      case 'goals':
        return List.from(_store['goals'] as List);
      case 'goal':
        return (_store['goals'] as List).firstWhere((e) => e['id'] == a['goalId'], orElse: () => null);
      case 'createGoal':
        final g = {
          'id': _id('goal'),
          'name': a['name'],
          'type': a['type'],
          'targetAmount': a['targetAmount'],
          'currentAmount': 0.0,
          'targetDate': a['targetDate'],
          'completed': false,
        };
        (_store['goals'] as List).add(g);
        return g;
      case 'contribute':
        final g = (_store['goals'] as List).firstWhere((e) => e['id'] == a['goalId']) as Map;
        g['currentAmount'] = (g['currentAmount'] as num) + (a['amount'] as num);
        if ((g['currentAmount'] as num) >= (g['targetAmount'] as num)) g['completed'] = true;
        return g;
      case 'getPensionPlan':
        return Map<String, dynamic>.from(_store['pensionPlan'] as Map);
      case 'pensionProjection':
        final p = _store['pensionPlan'] as Map;
        final years = (p['retirementAge'] as int) - (p['currentAge'] as int);
        final total = (p['currentShortPot'] as num) + (p['currentLongPot'] as num) + (p['contributionAmount'] as num) * 12 * years;
        return {'shortPotProjected': total * 0.3, 'longPotProjected': total * 0.7, 'totalProjected': total, 'yearsToRetirement': years};
      case 'upsertPensionPlan':
        _store['pensionPlan'] = Map<String, dynamic>.from(a);
        return Map<String, dynamic>.from(_store['pensionPlan'] as Map);
      case 'contributePension':
        final p = _store['pensionPlan'] as Map;
        if (a['pot'] == 'short') p['currentShortPot'] = (p['currentShortPot'] as num) + (a['amount'] as num);
        if (a['pot'] == 'long') p['currentLongPot'] = (p['currentLongPot'] as num) + (a['amount'] as num);
        return {'id': _id('pc'), 'pot': a['pot'], 'amount': a['amount'], 'date': DateTime.now().toIso8601String()};
      case 'pensionContributions':
        return <Map<String, dynamic>>[];
      case 'securityOverview':
        return Map<String, dynamic>.from(_store['securityOverview'] as Map);
      case 'setTwoFactor':
        (_store['securityOverview'] as Map)['twoFactor'] = a['enabled'];
        return Map<String, dynamic>.from(_store['securityOverview'] as Map);
      case 'devices':
        return List.from(_store['devices'] as List);
      case 'securityEvents':
        return List.from(_store['securityEvents'] as List);
      case 'resolveSecurityEvent':
        final e = (_store['securityEvents'] as List).firstWhere((x) => x['id'] == a['eventId'], orElse: () => null);
        if (e != null) e['resolved'] = true;
        return e;
      case 'invoices':
        return List.from(_store['invoices'] as List);
      case 'createInvoice':
        final inv = {
          'id': _id('inv'),
          'clientName': a['clientName'],
          'amount': a['amount'],
          'dueDate': a['dueDate'],
          'status': 'sent',
          'issuedDate': DateTime.now().toIso8601String(),
        };
        (_store['invoices'] as List).add(inv);
        return inv;
      case 'updateInvoiceStatus':
        final inv = (_store['invoices'] as List).firstWhere((e) => e['id'] == a['invoiceId']) as Map;
        inv['status'] = a['status'];
        return inv;
      case 'vendors':
        return List.from(_store['vendors'] as List);
      case 'createVendor':
        final v = {'id': _id('ven'), 'name': a['name'], 'totalSpend': 0.0};
        (_store['vendors'] as List).add(v);
        return v;
      case 'transfers':
        return List.from(_store['transfers'] as List);
      case 'transferById':
        return (_store['transfers'] as List).firstWhere((e) => e['id'] == a['id'], orElse: () => null);
      case 'createTransfer':
        final key = a['idempotencyKey'] as String? ?? '';
        final existing = (_store['transfers'] as List).where((e) => e['idempotencyKey'] == key).toList();
        if (existing.isNotEmpty) return existing.first;
        final t = {
          'id': _id('tr'),
          'idempotencyKey': key,
          'sourceAccountId': a['sourceAccountId'],
          'payeeName': a['payeeName'],
          'destination': a['destination'],
          'amount': a['amount'],
          'date': DateTime.now().toIso8601String(),
          'status': 'completed',
        };
        (_store['transfers'] as List).insert(0, t);
        return t;
      case 'payees':
        return List.from(_store['payees'] as List);
      case 'createPayee':
        final p = {'id': _id('pay'), 'name': a['name'], 'destination': a['destination']};
        (_store['payees'] as List).add(p);
        return p;
      case 'billPayments':
        return List.from(_store['billPayments'] as List);
      case 'payBill':
      case 'scheduleBill':
        final bp = {
          'id': _id('bp'),
          'category': a['category'],
          'billerName': a['billerName'],
          'amount': a['amount'],
          'customerRef': a['customerRef'],
          'date': DateTime.now().toIso8601String(),
          'status': method == 'scheduleBill' ? 'scheduled' : 'paid',
        };
        (_store['billPayments'] as List).add(bp);
        return bp;
      default:
        throw _BffError('not_found', 'Unknown method: $method');
    }
  }
}

class _BffError {
  const _BffError(this.code, this.message);
  final String code;
  final String message;
}

/// Builds the shelf handler backed by a fresh [MockBff]. Exposed so the app's
/// integration tests can spin up the reference server in-process instead of
/// needing a separately running process.
shelf.Handler mockBffHandler([MockBff? bff]) {
  final server = bff ?? MockBff();
  return const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addHandler((shelf.Request req) async {
    if (req.method != 'POST' || req.url.path != 'rpc') {
      return shelf.Response.notFound(jsonEncode(server._fail('not_found', 'Use POST /rpc')));
    }
    final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    final env = server._envelope(req, body);
    return shelf.Response.ok(jsonEncode(env), headers: {'content-type': 'application/json'});
  });
}

Future<void> main(List<String> argv) async {
  var port = 8080;
  for (var i = 0; i < argv.length - 1; i++) {
    if (argv[i] == '--port' || argv[i] == '-p') port = int.tryParse(argv[i + 1]) ?? port;
  }

  final handler = mockBffHandler();

  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  // ignore: avoid_print
  print('Finovault mock BFF listening on http://${server.address.host}:$port/rpc');
}
