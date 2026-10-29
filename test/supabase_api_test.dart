import 'package:flutter_test/flutter_test.dart';
import 'package:finovault_flutter/core/supabase_api.dart';
import 'package:finovault_flutter/core/mock/api.dart';

void main() {
  group('SupabaseFinovaultApi input validation', () {
    late SupabaseFinovaultApi api;

    setUp(() {
      api = SupabaseFinovaultApi();
    });

    test('signup rejects SQL injection in name', () async {
      expect(
        () => api.signup(
          fullName: "Admin' OR 1=1 --",
          email: 'valid@example.com',
          password: 'Password123!',
          phone: '+23051234567',
        ),
        throwsA(isA<FvApiException>()),
      );
    });

    test('signup rejects SQL injection in email', () async {
      expect(
        () => api.signup(
          fullName: 'Valid Name',
          email: "victim@example.com'; DROP TABLE users;--",
          password: 'Password123!',
          phone: '+23051234567',
        ),
        throwsA(isA<FvApiException>()),
      );
    });

    test('signup rejects short password', () async {
      expect(
        () => api.signup(
          fullName: 'Valid Name',
          email: 'valid@example.com',
          password: 'short',
          phone: '+23051234567',
        ),
        throwsA(isA<FvApiException>()),
      );
    });

    test('login rejects SQL injection in email', () async {
      expect(
        () => api.login(
          email: "admin'--",
          password: 'anyPassword',
        ),
        throwsA(isA<FvApiException>()),
      );
    });

    test('requestPasswordReset rejects SQL injection in email', () async {
      expect(
        () => api.requestPasswordReset("admin' UNION SELECT *--"),
        throwsA(isA<FvApiException>()),
      );
    });

    test('resetPassword rejects short password', () async {
      expect(
        () => api.resetPassword('valid_token_123', 'short'),
        throwsA(isA<FvApiException>()),
      );
    });
  });
}
