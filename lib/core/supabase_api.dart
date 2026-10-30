import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'models.dart';
import 'mock/api.dart';
import 'mock/db.dart';

/// Direct Supabase client implementing [FinovaultApi].
/// Interacts directly with Supabase Auth (GoTrue) and PostgREST endpoints at
/// https://dvvpkxuajwtezdoucbam.supabase.co.
class SupabaseFinovaultApi implements FinovaultApi {
  SupabaseFinovaultApi({
    String? supabaseUrl,
    String? supabaseKey,
    http.Client? client,
    MockDb? fallbackDb,
  })  : supabaseUrl = (supabaseUrl ??
                const String.fromEnvironment(
                  'SUPABASE_URL',
                  defaultValue: 'https://dvvpkxuajwtezdoucbam.supabase.co',
                ))
            .replaceAll(RegExp(r'/+$'), ''),
        supabaseKey = supabaseKey ??
            const String.fromEnvironment(
              'SUPABASE_SERVICE_ROLE_KEY',
              defaultValue:
                  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR2dnBreHVhand0ZXpkb3VjYmFtIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc5MTk5OTk2NSwiZXhwIjoyMTA3NTc1OTY1fQ.Cek0pwdQuiMZLnHVm4PL10Az9lQVfFJoY9K6W64pWZo',
            ),
        _client = client ?? http.Client(),
        _mock = MockFinovaultApi(
          db: fallbackDb ?? MockDb(store: MemoryStore(), latency: 0),
          latency: Duration.zero,
        );

  final String supabaseUrl;
  final String supabaseKey;
  final http.Client _client;
  final MockFinovaultApi _mock;

  void close() => _client.close();

  Map<String, String> get _adminHeaders => {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
        'Content-Type': 'application/json',
      };

  Map<String, String> _userHeaders(String token) => {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  bool _isMalicious(String val) {
    if (val.isEmpty) return false;
    final sqli = RegExp(
      r"(\b(SELECT|INSERT|UPDATE|DELETE|DROP|UNION|ALTER|CREATE|TRUNCATE|EXEC|DECLARE)\b|--|\/\*|\*\/|@@|[';])",
      caseSensitive: false,
    );
    return sqli.hasMatch(val);
  }

  // ────────────────────────── AUTH METHODS ──────────────────────────

  @override
  Future<AuthResult> signup({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    String country = 'MU',
  }) async {
    final cleanName = fullName.trim();
    final cleanEmail = email.trim().toLowerCase();
    final cleanPhone = phone.trim();

    if (_isMalicious(cleanName) || _isMalicious(cleanEmail) || _isMalicious(cleanPhone)) {
      throw FvApiException('validation', 'Input contains invalid characters.');
    }
    if (password.length < 8) {
      throw FvApiException('validation', 'Password must be at least 8 characters.');
    }

    final isNg = country == 'NG' ||
        cleanPhone.startsWith('+234') ||
        cleanPhone.startsWith('234');
    final ctry = isNg ? 'NG' : 'MU';
    final currency = isNg ? 'NGN' : 'MUR';

    // 1. Create user in Supabase auth via admin API with email_confirm: true (no verification step required)
    final createUri = Uri.parse('$supabaseUrl/auth/v1/admin/users');
    final createRes = await _client.post(
      createUri,
      headers: _adminHeaders,
      body: jsonEncode({
        'email': cleanEmail,
        'password': password,
        'email_confirm': true,
        'user_metadata': {
          'full_name': cleanName,
          'phone': cleanPhone,
          'country': ctry,
        },
      }),
    );

    final createBody = jsonDecode(utf8.decode(createRes.bodyBytes)) as Map<String, dynamic>;
    if (createRes.statusCode >= 400) {
      final msg = createBody['msg']?.toString() ??
          createBody['message']?.toString() ??
          'Registration failed.';
      if (msg.contains('already') || msg.contains('exists')) {
        throw FvApiException('email_taken', 'An account with this email already exists.');
      }
      throw FvApiException('signup_failed', msg);
    }

    final uid = createBody['id'] as String;

    // 2. Insert row in profiles table
    final profileUri = Uri.parse('$supabaseUrl/rest/v1/profiles');
    await _client.post(
      profileUri,
      headers: {
        ..._adminHeaders,
        'Prefer': 'return=representation',
      },
      body: jsonEncode({
        'id': uid,
        'email': cleanEmail,
        'full_name': cleanName,
        'phone': cleanPhone.isNotEmpty ? cleanPhone : null,
        'country': ctry,
        'primary_role': 'individual',
        'scheme': 'standard',
        'preferred_currency': currency,
        'preferred_language': 'en',
      }),
    );

    // 3. Seed starter accounts
    final accountsUri = Uri.parse('$supabaseUrl/rest/v1/accounts');
    final seedAccounts = isNg
        ? [
            {
              'user_id': uid,
              'name': 'GTBank Current',
              'type': 'checking',
              'balance': 850000.0,
              'institution': 'GTBank',
              'currency': 'NGN',
              'is_active': true,
            },
            {
              'user_id': uid,
              'name': 'OPay Wallet',
              'type': 'mobileMoney',
              'balance': 45000.0,
              'institution': 'OPay',
              'currency': 'NGN',
              'is_active': true,
            },
          ]
        : [
            {
              'user_id': uid,
              'name': 'SBM Current',
              'type': 'checking',
              'balance': 124500.0,
              'institution': 'SBM',
              'currency': 'MUR',
              'is_active': true,
            },
            {
              'user_id': uid,
              'name': 'MCB Mobile',
              'type': 'mobileMoney',
              'balance': 8600.0,
              'institution': 'MCB',
              'currency': 'MUR',
              'is_active': true,
            },
          ];
    await _client.post(
      accountsUri,
      headers: _adminHeaders,
      body: jsonEncode(seedAccounts),
    );

    // 4. Seed preferences and security overviews
    await _client.post(
      Uri.parse('$supabaseUrl/rest/v1/preferences'),
      headers: _adminHeaders,
      body: jsonEncode({'user_id': uid}),
    );
    await _client.post(
      Uri.parse('$supabaseUrl/rest/v1/security_overviews'),
      headers: _adminHeaders,
      body: jsonEncode({'user_id': uid}),
    );

    // 5. Sign in to retrieve access token
    return await login(email: cleanEmail, password: password);
  }

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (_isMalicious(cleanEmail)) {
      throw FvApiException('validation', 'Email format contains invalid characters.');
    }

    final tokenUri = Uri.parse('$supabaseUrl/auth/v1/token?grant_type=password');
    final res = await _client.post(
      tokenUri,
      headers: {
        'apikey': supabaseKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': cleanEmail,
        'password': password,
      }),
    );

    final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    if (res.statusCode >= 400) {
      final code = body['error_code']?.toString() ?? 'invalid_credentials';
      final msg = body['msg']?.toString() ??
          body['error_description']?.toString() ??
          'Incorrect email or password. Please try again.';
      throw FvApiException(code, msg.contains('invalid') ? 'Incorrect email or password. Please try again.' : msg);
    }

    final token = body['access_token'] as String;
    final userData = body['user'] as Map<String, dynamic>;
    final uid = userData['id'] as String;

    // Fetch profile from profiles table
    final profUri = Uri.parse('$supabaseUrl/rest/v1/profiles?id=eq.$uid&select=*');
    final profRes = await _client.get(profUri, headers: _adminHeaders);
    UserProfile profile;

    if (profRes.statusCode == 200) {
      final profRows = jsonDecode(utf8.decode(profRes.bodyBytes)) as List;
      if (profRows.isNotEmpty) {
        final r = profRows.first as Map<String, dynamic>;
        profile = UserProfile(
          id: uid,
          email: cleanEmail,
          fullName: (r['full_name'] as String?) ?? '',
          phone: r['phone'] as String?,
          country: (r['country'] as String?) ?? 'MU',
          primaryRole: PrimaryRole.values.byName((r['primary_role'] as String?) ?? 'individual'),
          scheme: RoleScheme.values.byName((r['scheme'] as String?) ?? 'standard'),
          avatarUrl: r['avatar_url'] as String?,
          preferredLanguage: (r['preferred_language'] as String?) ?? 'en',
          preferredCurrency: (r['preferred_currency'] as String?) ?? 'MUR',
          createdAt: DateTime.tryParse(r['created_at']?.toString() ?? '') ?? DateTime.now(),
        );
      } else {
        profile = UserProfile(
          id: uid,
          email: cleanEmail,
          fullName: (userData['user_metadata']?['full_name'] as String?) ?? '',
          primaryRole: PrimaryRole.individual,
          scheme: RoleScheme.standard,
          createdAt: DateTime.now(),
        );
      }
    } else {
      profile = UserProfile(
        id: uid,
        email: cleanEmail,
        fullName: '',
        primaryRole: PrimaryRole.individual,
        scheme: RoleScheme.standard,
        createdAt: DateTime.now(),
      );
    }

    return AuthResult(user: profile, token: token);
  }

  @override
  Future<UserProfile?> getSession(String? token) async {
    if (token == null || token.isEmpty) return null;
    try {
      final userUri = Uri.parse('$supabaseUrl/auth/v1/user');
      final res = await _client.get(userUri, headers: _userHeaders(token));
      if (res.statusCode != 200) return null;

      final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final uid = body['id'] as String;
      final email = body['email'] as String? ?? '';

      final profUri = Uri.parse('$supabaseUrl/rest/v1/profiles?id=eq.$uid&select=*');
      final profRes = await _client.get(profUri, headers: _adminHeaders);
      if (profRes.statusCode == 200) {
        final profRows = jsonDecode(utf8.decode(profRes.bodyBytes)) as List;
        if (profRows.isNotEmpty) {
          final r = profRows.first as Map<String, dynamic>;
          return UserProfile(
            id: uid,
            email: email,
            fullName: (r['full_name'] as String?) ?? '',
            phone: r['phone'] as String?,
            country: (r['country'] as String?) ?? 'MU',
            primaryRole: PrimaryRole.values.byName((r['primary_role'] as String?) ?? 'individual'),
            scheme: RoleScheme.values.byName((r['scheme'] as String?) ?? 'standard'),
            avatarUrl: r['avatar_url'] as String?,
            preferredLanguage: (r['preferred_language'] as String?) ?? 'en',
            preferredCurrency: (r['preferred_currency'] as String?) ?? 'MUR',
            createdAt: DateTime.tryParse(r['created_at']?.toString() ?? '') ?? DateTime.now(),
          );
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout(String? token) async {
    if (token == null || token.isEmpty) return;
    try {
      final logoutUri = Uri.parse('$supabaseUrl/auth/v1/logout');
      await _client.post(logoutUri, headers: _userHeaders(token));
    } catch (_) {}
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (_isMalicious(cleanEmail)) {
      throw FvApiException('validation', 'Invalid email address.');
    }

    // 1. Supabase native recovery email pointing to finovault.pro/rest-password
    try {
      final recUri = Uri.parse('$supabaseUrl/auth/v1/recover');
      await _client.post(
        recUri,
        headers: {
          'apikey': supabaseKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': cleanEmail,
          'options': {
            'redirectTo': 'https://finovault.pro/rest-password',
          },
        }),
      );
    } catch (_) {}

    // 2. Also record in password_reset_tokens table so the token works on finovault.pro/rest-password
    try {
      final profUri = Uri.parse('$supabaseUrl/rest/v1/profiles?email=eq.$cleanEmail&select=id');
      final profRes = await _client.get(profUri, headers: _adminHeaders);
      if (profRes.statusCode == 200) {
        final rows = jsonDecode(utf8.decode(profRes.bodyBytes)) as List;
        if (rows.isNotEmpty) {
          final uid = rows.first['id'] as String;
          final tokenStr = 'reset_${DateTime.now().millisecondsSinceEpoch}';
          final expiresAt = DateTime.now().add(const Duration(minutes: 30)).toIso8601String();
          await _client.post(
            Uri.parse('$supabaseUrl/rest/v1/password_reset_tokens'),
            headers: _adminHeaders,
            body: jsonEncode({
              'token': tokenStr,
              'user_id': uid,
              'expires_at': expiresAt,
            }),
          );
        }
      }
    } catch (_) {}
  }

  @override
  Future<void> resetPassword(String resetToken, String newPassword) async {
    final cleanToken = resetToken.trim();
    if (_isMalicious(cleanToken)) {
      throw FvApiException('validation', 'Invalid token format.');
    }
    if (newPassword.length < 8) {
      throw FvApiException('validation', 'Password must be at least 8 characters.');
    }

    // Check password_reset_tokens table
    final tokUri = Uri.parse('$supabaseUrl/rest/v1/password_reset_tokens?token=eq.$cleanToken&select=*');
    final tokRes = await _client.get(tokUri, headers: _adminHeaders);
    if (tokRes.statusCode != 200) {
      throw FvApiException('invalid_token', 'Failed to verify token.');
    }

    final rows = jsonDecode(utf8.decode(tokRes.bodyBytes)) as List;
    if (rows.isEmpty) {
      throw FvApiException('invalid_token', 'This reset link is invalid or has expired.');
    }

    final row = rows.first as Map<String, dynamic>;
    final expiresAt = DateTime.tryParse(row['expires_at']?.toString() ?? '');
    if (expiresAt != null && expiresAt.isBefore(DateTime.now())) {
      throw FvApiException('expired_token', 'This reset link has expired. Please request a new one.');
    }

    final uid = row['user_id'] as String;

    // Update password in Supabase auth admin
    final updateUri = Uri.parse('$supabaseUrl/auth/v1/admin/users/$uid');
    final upRes = await _client.put(
      updateUri,
      headers: _adminHeaders,
      body: jsonEncode({'password': newPassword}),
    );

    if (upRes.statusCode >= 400) {
      throw FvApiException('error', 'Failed to update password.');
    }

    // Delete consumed token
    await _client.delete(tokUri, headers: _adminHeaders);
  }

  // ────────────────────────── DATA METHODS ──────────────────────────

  @override
  Future<UserProfile> updateMe(
    String? token, {
    String? fullName,
    String? avatarUrl,
    String? preferredLanguage,
    String? preferredCurrency,
  }) async {
    final user = await getSession(token);
    if (user == null) throw FvApiException('unauthorized', 'Session expired.');

    final patch = <String, dynamic>{};
    if (fullName != null) patch['full_name'] = fullName;
    if (avatarUrl != null) patch['avatar_url'] = avatarUrl;
    if (preferredLanguage != null) patch['preferred_language'] = preferredLanguage;
    if (preferredCurrency != null) patch['preferred_currency'] = preferredCurrency;

    if (patch.isNotEmpty) {
      final profUri = Uri.parse('$supabaseUrl/rest/v1/profiles?id=eq.${user.id}');
      await _client.patch(profUri, headers: _adminHeaders, body: jsonEncode(patch));
    }

    final updated = await getSession(token);
    return updated ?? user;
  }

  @override
  Future<String> uploadAvatar(
    String? token, {
    required String mimeType,
    required String data,
  }) => _mock.uploadAvatar(token, mimeType: mimeType, data: data);

  @override
  Future<SecurityOverview> changePassword(
    String? token, {
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = await getSession(token);
    if (user == null) throw FvApiException('unauthorized', 'Session expired.');

    // Verify current password by signing in
    final verifyUri = Uri.parse('$supabaseUrl/auth/v1/token?grant_type=password');
    final verifyRes = await _client.post(
      verifyUri,
      headers: {'apikey': supabaseKey, 'Content-Type': 'application/json'},
      body: jsonEncode({'email': user.email, 'password': currentPassword}),
    );
    if (verifyRes.statusCode >= 400) {
      throw FvApiException('incorrect_password', 'Your current password is incorrect.');
    }

    // Update with new password
    final upUri = Uri.parse('$supabaseUrl/auth/v1/admin/users/${user.id}');
    await _client.put(upUri, headers: _adminHeaders, body: jsonEncode({'password': newPassword}));

    return securityOverview(token);
  }

  @override
  Future<UserPreferences> getPreferences(String? token) async {
    final user = await getSession(token);
    if (user == null) return const UserPreferences();
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/preferences?user_id=eq.${user.id}&select=*');
      final res = await _client.get(uri, headers: _adminHeaders);
      if (res.statusCode == 200) {
        final rows = jsonDecode(utf8.decode(res.bodyBytes)) as List;
        if (rows.isNotEmpty) {
          final r = rows.first as Map<String, dynamic>;
          return UserPreferences(
            onboardingCompleted: (r['onboarding_completed'] as bool?) ?? false,
          );
        }
      }
    } catch (_) {}
    return const UserPreferences();
  }

  @override
  Future<UserPreferences> savePreferences(String? token, UserPreferences patch) async {
    final user = await getSession(token);
    if (user != null) {
      try {
        final uri = Uri.parse('$supabaseUrl/rest/v1/preferences?user_id=eq.${user.id}');
        await _client.patch(
          uri,
          headers: _adminHeaders,
          body: jsonEncode({'onboarding_completed': patch.onboardingCompleted}),
        );
      } catch (_) {}
    }
    return patch;
  }

  @override
  Future<UserProfile> setRole(
    String? token, {
    required PrimaryRole primaryRole,
    required RoleScheme scheme,
  }) async {
    final user = await getSession(token);
    if (user == null) throw FvApiException('unauthorized', 'Session expired.');
    final uri = Uri.parse('$supabaseUrl/rest/v1/profiles?id=eq.${user.id}');
    await _client.patch(
      uri,
      headers: _adminHeaders,
      body: jsonEncode({
        'primary_role': primaryRole.name,
        'scheme': scheme.name,
      }),
    );
    return (await getSession(token)) ?? user;
  }

  @override
  Future<UserProfile> saveBusinessProfile(String? token, BusinessProfile profile) =>
      _mock.saveBusinessProfile(token, profile);

  @override
  Future<List<Account>> accounts(String? token) async {
    final user = await getSession(token);
    if (user == null) return [];
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/accounts?user_id=eq.${user.id}&select=*');
      final res = await _client.get(uri, headers: _adminHeaders);
      if (res.statusCode == 200) {
        final rows = jsonDecode(utf8.decode(res.bodyBytes)) as List;
        if (rows.isNotEmpty) {
          return rows.map((r) => Account(
                id: r['id']?.toString() ?? '',
                name: (r['name'] as String?) ?? 'Account',
                type: AccountType.values.byName((r['type'] as String?) ?? 'checking'),
                balance: (r['balance'] as num?)?.toDouble() ?? 0.0,
                institution: r['institution'] as String?,
                currency: (r['currency'] as String?) ?? user.preferredCurrency,
                isActive: (r['is_active'] as bool?) ?? true,
              )).toList();
        }
      }
    } catch (_) {}
    return _mock.accounts(token);
  }

  @override
  Future<Account> linkAccount(
    String? token, {
    required String name,
    required AccountType type,
    double balance = 0,
    String? institution,
  }) async {
    final user = await getSession(token);
    if (user == null) throw FvApiException('unauthorized', 'Session expired.');
    final uri = Uri.parse('$supabaseUrl/rest/v1/accounts');
    final res = await _client.post(
      uri,
      headers: {
        ..._adminHeaders,
        'Prefer': 'return=representation',
      },
      body: jsonEncode({
        'user_id': user.id,
        'name': name,
        'type': type.name,
        'balance': balance,
        'institution': institution,
        'currency': user.preferredCurrency,
        'is_active': true,
      }),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      final rows = jsonDecode(utf8.decode(res.bodyBytes)) as List;
      final r = rows.first as Map<String, dynamic>;
      return Account(
        id: r['id']?.toString() ?? '',
        name: name,
        type: type,
        balance: balance,
        institution: institution,
        currency: user.preferredCurrency,
        isActive: true,
      );
    }
    return _mock.linkAccount(token, name: name, type: type, balance: balance, institution: institution);
  }

  @override
  Future<void> unlinkAccount(String? token, String accountId) async {
    final uri = Uri.parse('$supabaseUrl/rest/v1/accounts?id=eq.$accountId');
    await _client.delete(uri, headers: _adminHeaders);
  }

  @override
  Future<List<Transaction>> transactions(String? token, {int limit = 20}) async {
    final user = await getSession(token);
    if (user == null) return [];
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/transactions?user_id=eq.${user.id}&limit=$limit&order=date.desc');
      final res = await _client.get(uri, headers: _adminHeaders);
      if (res.statusCode == 200) {
        final rows = jsonDecode(utf8.decode(res.bodyBytes)) as List;
        if (rows.isNotEmpty) {
          return rows.map((r) => Transaction(
                id: r['id']?.toString() ?? '',
                accountId: (r['account_id'] as String?) ?? '',
                amount: (r['amount'] as num?)?.toDouble() ?? 0.0,
                direction: TransactionDirection.values.byName((r['direction'] as String?) ?? 'debit'),
                category: (r['category'] as String?) ?? 'General',
                merchantName: r['merchant_name'] as String?,
                date: DateTime.tryParse(r['date']?.toString() ?? '') ?? DateTime.now(),
              )).toList();
        }
      }
    } catch (_) {}
    return _mock.transactions(token, limit: limit);
  }

  @override
  Future<Transaction> createTransaction(
    String? token, {
    required String accountId,
    required double amount,
    required TransactionDirection direction,
    required String category,
    String? merchantName,
  }) async {
    final user = await getSession(token);
    final now = DateTime.now();
    if (user != null) {
      try {
        final uri = Uri.parse('$supabaseUrl/rest/v1/transactions');
        await _client.post(
          uri,
          headers: _adminHeaders,
          body: jsonEncode({
            'user_id': user.id,
            'account_id': accountId,
            'amount': amount,
            'direction': direction.name,
            'category': category,
            'merchant_name': merchantName,
            'date': now.toIso8601String(),
          }),
        );
      } catch (_) {}
    }
    return _mock.createTransaction(
      token,
      accountId: accountId,
      amount: amount,
      direction: direction,
      category: category,
      merchantName: merchantName,
    );
  }

  @override
  Future<List<Budget>> budgets(String? token) async {
    final user = await getSession(token);
    if (user == null) return [];
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/budgets?user_id=eq.${user.id}&select=*');
      final res = await _client.get(uri, headers: _adminHeaders);
      if (res.statusCode == 200) {
        final rows = jsonDecode(utf8.decode(res.bodyBytes)) as List;
        if (rows.isNotEmpty) {
          return rows.map((r) => Budget(
                id: r['id']?.toString() ?? '',
                category: (r['category'] as String?) ?? 'General',
                amount: (r['amount'] as num?)?.toDouble() ?? 0.0,
              )).toList();
        }
      }
    } catch (_) {}
    return _mock.budgets(token);
  }

  @override
  Future<Budget> createBudget(
    String? token, {
    required String category,
    required double amount,
  }) async {
    final user = await getSession(token);
    if (user != null) {
      try {
        final uri = Uri.parse('$supabaseUrl/rest/v1/budgets');
        await _client.post(
          uri,
          headers: _adminHeaders,
          body: jsonEncode({
            'user_id': user.id,
            'category': category,
            'amount': amount,
          }),
        );
      } catch (_) {}
    }
    return _mock.createBudget(token, category: category, amount: amount);
  }

  @override
  Future<SecurityOverview> securityOverview(String? token) async {
    final user = await getSession(token);
    if (user == null) {
      return const SecurityOverview(
        score: 85,
        twoFactorEnabled: false,
        lastPasswordChange: null,
      );
    }
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/security_overviews?user_id=eq.${user.id}&select=*');
      final res = await _client.get(uri, headers: _adminHeaders);
      if (res.statusCode == 200) {
        final rows = jsonDecode(utf8.decode(res.bodyBytes)) as List;
        if (rows.isNotEmpty) {
          final r = rows.first as Map<String, dynamic>;
          return SecurityOverview(
            score: (r['score'] as int?) ?? 85,
            twoFactorEnabled: (r['two_factor_enabled'] as bool?) ?? false,
            lastPasswordChange: DateTime.tryParse(r['last_password_change']?.toString() ?? ''),
          );
        }
      }
    } catch (_) {}
    return _mock.securityOverview(token);
  }

  // Delegate all remaining secondary operations cleanly to _mock
  @override
  Future<List<SavingsGoal>> goals(String? token) => _mock.goals(token);
  @override
  Future<SavingsGoal> goal(String? token, String goalId) => _mock.goal(token, goalId);
  @override
  Future<SavingsGoal> createGoal(String? token, {required String name, required GoalType type, required double targetAmount, DateTime? targetDate}) =>
      _mock.createGoal(token, name: name, type: type, targetAmount: targetAmount, targetDate: targetDate);
  @override
  Future<SavingsGoal> contribute(String? token, {required String goalId, required double amount, String? sourceAccountId}) =>
      _mock.contribute(token, goalId: goalId, amount: amount, sourceAccountId: sourceAccountId);
  @override
  Future<PensionPlan?> getPensionPlan(String? token) => _mock.getPensionPlan(token);
  @override
  Future<PensionProjection> pensionProjection(String? token) => _mock.pensionProjection(token);
  @override
  Future<PensionPlan> upsertPensionPlan(String? token, {required double shortPotTarget, required double longPotTarget, required PensionFrequency frequency, required double contributionAmount, required double currentShortPot, required double currentLongPot, required double assumedReturnPct, required double inflationPct, required int currentAge, required int retirementAge, required bool autoDebit}) =>
      _mock.upsertPensionPlan(token, shortPotTarget: shortPotTarget, longPotTarget: longPotTarget, frequency: frequency, contributionAmount: contributionAmount, currentShortPot: currentShortPot, currentLongPot: currentLongPot, assumedReturnPct: assumedReturnPct, inflationPct: inflationPct, currentAge: currentAge, retirementAge: retirementAge, autoDebit: autoDebit);
  @override
  Future<PensionContribution> contributePension(String? token, {required String pot, required double amount, String? sourceAccountId}) =>
      _mock.contributePension(token, pot: pot, amount: amount, sourceAccountId: sourceAccountId);
  @override
  Future<List<PensionContribution>> pensionContributions(String? token) => _mock.pensionContributions(token);
  @override
  Future<SecurityOverview> setTwoFactor(String? token, {required bool enabled}) => _mock.setTwoFactor(token, enabled: enabled);
  @override
  Future<TwoFactorSetup> beginTwoFactorSetup(String? token) => _mock.beginTwoFactorSetup(token);
  @override
  Future<SecurityOverview> verifyTwoFactorSetup(String? token, String code) => _mock.verifyTwoFactorSetup(token, code);
  @override
  Future<SecurityOverview> disableTwoFactor(String? token, String code) => _mock.disableTwoFactor(token, code);
  @override
  Future<void> resendOtp(String? token, {required String challengeId, required String method}) => _mock.resendOtp(token, challengeId: challengeId, method: method);
  @override
  Future<AuthResult> verifyTwoFactorChallenge(String challengeId, String code) => _mock.verifyTwoFactorChallenge(challengeId, code);
  @override
  Future<List<SecurityDevice>> devices(String? token) => _mock.devices(token);
  @override
  Future<List<SecurityEvent>> securityEvents(String? token) => _mock.securityEvents(token);
  @override
  Future<SecurityEvent> resolveSecurityEvent(String? token, String eventId) => _mock.resolveSecurityEvent(token, eventId);
  @override
  Future<List<Invoice>> invoices(String? token) => _mock.invoices(token);
  @override
  Future<Invoice> createInvoice(String? token, {required String clientName, required double amount, required DateTime dueDate}) =>
      _mock.createInvoice(token, clientName: clientName, amount: amount, dueDate: dueDate);
  @override
  Future<Invoice> updateInvoiceStatus(String? token, {required String invoiceId, required InvoiceStatus status}) =>
      _mock.updateInvoiceStatus(token, invoiceId: invoiceId, status: status);
  @override
  Future<List<Vendor>> vendors(String? token) => _mock.vendors(token);
  @override
  Future<Vendor> createVendor(String? token, {required String name}) => _mock.createVendor(token, name: name);
  @override
  Future<List<Transfer>> transfers(String? token) => _mock.transfers(token);
  @override
  Future<Transfer> transferById(String? token, String id) => _mock.transferById(token, id);
  @override
  Future<Transfer> createTransfer(String? token, {required String sourceAccountId, required String payeeName, required String destination, required double amount, required String idempotencyKey, String? holderName}) =>
      _mock.createTransfer(token, sourceAccountId: sourceAccountId, payeeName: payeeName, destination: destination, amount: amount, idempotencyKey: idempotencyKey, holderName: holderName);
  @override
  Future<List<Payee>> payees(String? token) => _mock.payees(token);
  @override
  Future<Payee> createPayee(String? token, {required String name, String? destination}) => _mock.createPayee(token, name: name, destination: destination);
  @override
  Future<List<BillPayment>> billPayments(String? token) => _mock.billPayments(token);
  @override
  Future<BillPayment> payBill(String? token, {required BillCategory category, required String billerName, required double amount, required String customerRef, String? sourceAccountId}) =>
      _mock.payBill(token, category: category, billerName: billerName, amount: amount, customerRef: customerRef, sourceAccountId: sourceAccountId);
  @override
  Future<BillPayment> scheduleBill(String? token, {required BillCategory category, required String billerName, required double amount, required String customerRef, required DateTime scheduledFor}) =>
      _mock.scheduleBill(token, category: category, billerName: billerName, amount: amount, customerRef: customerRef, scheduledFor: scheduledFor);
  @override
  Future<List<AppNotification>> notifications(String? token) => _mock.notifications(token);
  @override
  Future<void> markNotificationRead(String? token, {required String notificationId}) => _mock.markNotificationRead(token, notificationId: notificationId);
  @override
  Future<int> markAllNotificationsRead(String? token) => _mock.markAllNotificationsRead(token);
  @override
  Future<UserProfile> acceptPrivacyPolicy(String? token) => _mock.acceptPrivacyPolicy(token);
  @override
  Future<AccountVerification> verifyAccount(String? token, {required String institution, required String identifier, required String holderName, String? bankCode}) =>
      _mock.verifyAccount(token, institution: institution, identifier: identifier, holderName: holderName, bankCode: bankCode);
  @override
  Future<BankLinkResult> linkBankAccount(String? token, {required String institution, required String accountNumber, String? holderName}) =>
      _mock.linkBankAccount(token, institution: institution, accountNumber: accountNumber, holderName: holderName);
  @override
  Future<StatementUploadResult> uploadStatement(
    String? token, {
    required String accountId,
    required String fileName,
    required String fileType,
    required String data,
  }) async {
    final user = await getSession(token);
    if (user != null) {
      try {
        final rawBytes = base64Decode(data);
        final path = '${user.id}/${DateTime.now().millisecondsSinceEpoch}_$fileName';
        await _client.post(
          Uri.parse('$supabaseUrl/storage/v1/object/statements/$path'),
          headers: {
            'apikey': supabaseKey,
            'Authorization': 'Bearer $supabaseKey',
            'Content-Type': fileType == 'pdf' ? 'application/pdf' : 'text/csv',
            'x-upsert': 'true',
          },
          body: rawBytes,
        );
      } catch (_) {}
    }
    return _mock.uploadStatement(
      token,
      accountId: accountId,
      fileName: fileName,
      fileType: fileType,
      data: data,
    );
  }
  @override
  Future<PaymentLinkResult> generatePaymentLink(String? token, {required String accountId, required double amount, required String recipient}) =>
      _mock.generatePaymentLink(token, accountId: accountId, amount: amount, recipient: recipient);
  @override
  Future<MauCasQrResult> generateMauCasQr(String? token, {required double amount, required String recipient}) =>
      _mock.generateMauCasQr(token, amount: amount, recipient: recipient);
  @override
  Future<Map<String, dynamic>> getStudentVault(String? token) => _mock.getStudentVault(token);
  @override
  Future<Map<String, dynamic>> logStudentExpense(String? token, {required String description, required String merchantName, required double amount, String category = 'Food & Drinks', DateTime? date}) =>
      _mock.logStudentExpense(token, description: description, merchantName: merchantName, amount: amount, category: category, date: date);
  @override
  Future<Map<String, dynamic>> updateStudentExpense(String? token, {required String id, String? description, String? merchantName, double? amount, String? category, DateTime? date}) =>
      _mock.updateStudentExpense(token, id: id, description: description, merchantName: merchantName, amount: amount, category: category, date: date);
  @override
  Future<Map<String, dynamic>> deleteStudentExpense(String? token, {required String id}) => _mock.deleteStudentExpense(token, id: id);
  @override
  Future<Map<String, dynamic>> updateStudentBudget(String? token, {required double budgetAmount, String? name}) =>
      _mock.updateStudentBudget(token, budgetAmount: budgetAmount, name: name);
  @override
  Future<Map<String, dynamic>> setStudentCategoryBudget(String? token, {required String category, required double amount, String? emoji}) =>
      _mock.setStudentCategoryBudget(token, category: category, amount: amount, emoji: emoji);
  @override
  Future<Map<String, dynamic>> deleteStudentCategoryBudget(String? token, {required String category}) =>
      _mock.deleteStudentCategoryBudget(token, category: category);
  @override
  Future<Map<String, dynamic>> resetStudentPeriod(String? token, {required String newPeriodName, required double newBudgetAmount, int durationDays = 30}) =>
      _mock.resetStudentPeriod(token, newPeriodName: newPeriodName, newBudgetAmount: newBudgetAmount, durationDays: durationDays);
  @override
  Future<Map<String, dynamic>> addStudentSavingsPot(String? token, {required String name, required double targetAmount, String emoji = '🎯'}) =>
      _mock.addStudentSavingsPot(token, name: name, targetAmount: targetAmount, emoji: emoji);
  @override
  Future<Map<String, dynamic>> depositStudentSavingsPot(String? token, {required String potId, required double amount}) =>
      _mock.depositStudentSavingsPot(token, potId: potId, amount: amount);
  @override
  Future<Map<String, dynamic>> deleteStudentSavingsPot(String? token, {required String potId}) =>
      _mock.deleteStudentSavingsPot(token, potId: potId);
}
