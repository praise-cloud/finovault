import 'package:flutter_test/flutter_test.dart';

import 'package:finovault_flutter/core/mock/api.dart';
import 'package:finovault_flutter/core/mock/db.dart';

void main() {
  MockFinovaultApi api() =>
      MockFinovaultApi(db: MockDb(), latency: Duration.zero);

  group('uploadAvatar', () {
    test('stores an inline data URI and updates the user', () async {
      final sdk = api();
      final auth = await sdk.signup(
        fullName: 'Amina',
        email: 'a@x.com',
        password: 'Password123!',
      );
      final url = await sdk.uploadAvatar(
        auth.token,
        mimeType: 'image/png',
        data: 'aGVsbG8=',
      );
      expect(url, startsWith('data:image/png;base64,'));

      final me = (await sdk.getSession(auth.token))!;
      expect(me.avatarUrl, url);
    });

    test('rejects non-image mime types', () async {
      final sdk = api();
      final auth = await sdk.signup(
        fullName: 'Amina',
        email: 'a@x.com',
        password: 'Password123!',
      );
      expect(
        () => sdk.uploadAvatar(auth.token, mimeType: 'text/plain', data: 'x'),
        throwsA(
          isA<FvApiException>().having((e) => e.code, 'code', 'validation'),
        ),
      );
    });
  });

  group('changePassword', () {
    test('rejects an incorrect current password', () async {
      final sdk = api();
      final auth = await sdk.signup(
        fullName: 'Amina',
        email: 'a@x.com',
        password: 'Password123!',
      );
      expect(
        () => sdk.changePassword(
          auth.token,
          currentPassword: 'wrong',
          newPassword: 'NewPassword456!',
        ),
        throwsA(
          isA<FvApiException>().having(
            (e) => e.code,
            'code',
            'incorrect_password',
          ),
        ),
      );
    });

    test(
      'updates the credential and records a security event + timestamp',
      () async {
        final sdk = api();
        final auth = await sdk.signup(
          fullName: 'Amina',
          email: 'a@x.com',
          password: 'Password123!',
        );
        final overview = await sdk.changePassword(
          auth.token,
          currentPassword: 'Password123!',
          newPassword: 'NewPassword456!',
        );

        expect(overview.lastPasswordChange, isNotNull);
        final after = await sdk.login(
          email: 'a@x.com',
          password: 'NewPassword456!',
        );
        expect(after.user.email, 'a@x.com');
        final events = await sdk.securityEvents(auth.token);
        expect(events.any((e) => e.title == 'Password changed'), isTrue);
      },
    );
  });

  group('password reset', () {
    test(
      'requesting a reset for an existing email issues a usable token',
      () async {
        final sdk = api();
        await sdk.signup(
          fullName: 'Amina',
          email: 'a@x.com',
          password: 'Password123!',
        );
        await sdk.requestPasswordReset('a@x.com');
        final token = sdk.db.passwordResetTokens.keys.last;
        expect(token, isNotNull);

        await sdk.resetPassword(token, 'BrandNew789!');

        final after = await sdk.login(
          email: 'a@x.com',
          password: 'BrandNew789!',
        );
        expect(after.user.email, 'a@x.com');
      },
    );

    test('reset invalidates existing sessions', () async {
      final sdk = api();
      final auth = await sdk.signup(
        fullName: 'Amina',
        email: 'a@x.com',
        password: 'Password123!',
      );
      await sdk.requestPasswordReset('a@x.com');
      await sdk.resetPassword(
        sdk.db.passwordResetTokens.keys.last,
        'BrandNew789!',
      );

      final session = await sdk.getSession(auth.token);
      expect(session, isNull);
    });

    test('an unknown email never leaks account existence', () async {
      final sdk = api();
      await sdk.requestPasswordReset('nobody@x.com');
      expect(sdk.db.passwordResetTokens, isEmpty);
    });

    test('an invalid or expired token is rejected', () async {
      final sdk = api();
      await sdk.signup(
        fullName: 'Amina',
        email: 'a@x.com',
        password: 'Password123!',
      );
      await sdk.requestPasswordReset('a@x.com');

      final token = sdk.db.passwordResetTokens.keys.last;
      sdk.db.passwordResetIssuedAt[token] = DateTime.now().subtract(
        const Duration(hours: 1),
      );

      expect(
        () => sdk.resetPassword(token, 'BrandNew789!'),
        throwsA(
          isA<FvApiException>().having(
            (e) => e.code,
            'code',
            'invalid_reset_token',
          ),
        ),
      );
      expect(
        () => sdk.resetPassword('bogus', 'BrandNew789!'),
        throwsA(
          isA<FvApiException>().having(
            (e) => e.code,
            'code',
            'invalid_reset_token',
          ),
        ),
      );
    });
  });
}
