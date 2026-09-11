import 'package:flutter_test/flutter_test.dart';

import 'package:finovault_flutter/core/mock/api.dart';
import 'package:finovault_flutter/core/mock/db.dart';

String totp(String secret, DateTime time) {
  final window = (time.millisecondsSinceEpoch ~/ 30000).toRadixString(16);
  final hash =
      secret.codeUnits.fold<int>(0, (h, c) => (h * 31 + c) ^ window.hashCode) &
      0x7FFFFFFF;
  return (hash % 1000000).toString().padLeft(6, '0');
}

void main() {
  MockFinovaultApi api() =>
      MockFinovaultApi(db: MockDb(), latency: Duration.zero);
  final now = DateTime.now();

  group('beginTwoFactorSetup', () {
    test('returns a TOTP secret, QR URL and 8 backup codes', () async {
      final sdk = api();
      final auth = await sdk.signup(
        fullName: 'Amina',
        email: 'a@x.com',
        password: 'Password123!',
        phone: '51234567',
      );
      final setup = await sdk.beginTwoFactorSetup(auth.token);
      expect(setup.secret.length, 16);
      expect(setup.qrUrl, contains('otpauth://totp/Finovault:a@x.com'));
      expect(setup.backupCodes.length, 8);
    });

    test('rejects when not authenticated', () async {
      final sdk = api();
      expect(
        () => sdk.beginTwoFactorSetup(null),
        throwsA(
          isA<FvApiException>().having((e) => e.code, 'code', 'unauthorized'),
        ),
      );
    });
  });

  group('verifyTwoFactorSetup', () {
    test('enables 2FA with a valid TOTP code and bumps the score', () async {
      final sdk = api();
      final auth = await sdk.signup(
        fullName: 'Amina',
        email: 'a@x.com',
        password: 'Password123!',
        phone: '51234567',
      );
      final setup = await sdk.beginTwoFactorSetup(auth.token);
      final before = await sdk.securityOverview(auth.token);
      final ov = await sdk.verifyTwoFactorSetup(
        auth.token,
        totp(setup.secret, now),
      );
      expect(ov.twoFactorEnabled, isTrue);
      expect(ov.score, greaterThan(before.score));
    });

    test('rejects an invalid code', () async {
      final sdk = api();
      final auth = await sdk.signup(
        fullName: 'Amina',
        email: 'a@x.com',
        password: 'Password123!',
        phone: '51234567',
      );
      await sdk.beginTwoFactorSetup(auth.token);
      expect(
        () => sdk.verifyTwoFactorSetup(auth.token, '000000'),
        throwsA(
          isA<FvApiException>().having((e) => e.code, 'code', 'invalid_code'),
        ),
      );
    });
  });

  group('login with 2FA', () {
    test('returns mfaRequired when 2FA is enabled', () async {
      final sdk = api();
      final auth = await sdk.signup(
        fullName: 'Amina',
        email: 'a@x.com',
        password: 'Password123!',
        phone: '51234567',
      );
      final setup = await sdk.beginTwoFactorSetup(auth.token);
      await sdk.verifyTwoFactorSetup(auth.token, totp(setup.secret, now));

      final result = await sdk.login(
        email: 'a@x.com',
        password: 'Password123!',
      );
      expect(result.mfaRequired, isTrue);
      expect(result.challengeId, isNotNull);
      expect(result.methods, contains('totp'));
      expect(result.token, isEmpty);
    });

    test('verifyTwoFactorChallenge with valid code returns a token', () async {
      final sdk = api();
      final auth = await sdk.signup(
        fullName: 'Amina',
        email: 'a@x.com',
        password: 'Password123!',
        phone: '51234567',
      );
      final setup = await sdk.beginTwoFactorSetup(auth.token);
      await sdk.verifyTwoFactorSetup(auth.token, totp(setup.secret, now));

      final result = await sdk.login(
        email: 'a@x.com',
        password: 'Password123!',
      );
      final verified = await sdk.verifyTwoFactorChallenge(
        result.challengeId!,
        totp(setup.secret, now),
      );
      expect(verified.token, isNotEmpty);
      expect(verified.user.email, 'a@x.com');
    });

    test('verifyTwoFactorChallenge accepts a backup code once', () async {
      final sdk = api();
      final auth = await sdk.signup(
        fullName: 'Amina',
        email: 'a@x.com',
        password: 'Password123!',
        phone: '51234567',
      );
      final setup = await sdk.beginTwoFactorSetup(auth.token);
      await sdk.verifyTwoFactorSetup(auth.token, totp(setup.secret, now));

      final result = await sdk.login(
        email: 'a@x.com',
        password: 'Password123!',
      );
      final backup = setup.backupCodes.first;
      final verified = await sdk.verifyTwoFactorChallenge(
        result.challengeId!,
        backup,
      );
      expect(verified.token, isNotEmpty);

      // Backup code is now consumed
      final result2 = await sdk.login(
        email: 'a@x.com',
        password: 'Password123!',
      );
      expect(
        () => sdk.verifyTwoFactorChallenge(result2.challengeId!, backup),
        throwsA(
          isA<FvApiException>().having((e) => e.code, 'code', 'invalid_code'),
        ),
      );
    });

    test('verifyTwoFactorChallenge rejects a bad code', () async {
      final sdk = api();
      final auth = await sdk.signup(
        fullName: 'Amina',
        email: 'a@x.com',
        password: 'Password123!',
        phone: '51234567',
      );
      final setup = await sdk.beginTwoFactorSetup(auth.token);
      await sdk.verifyTwoFactorSetup(auth.token, totp(setup.secret, now));
      final result = await sdk.login(
        email: 'a@x.com',
        password: 'Password123!',
      );
      expect(
        () => sdk.verifyTwoFactorChallenge(result.challengeId!, '000000'),
        throwsA(
          isA<FvApiException>().having((e) => e.code, 'code', 'invalid_code'),
        ),
      );
    });

    test(
      'verifyTwoFactorChallenge rejects an unknown/expired challenge',
      () async {
        final sdk = api();
        expect(
          () => sdk.verifyTwoFactorChallenge('mfa_nope', '123456'),
          throwsA(
            isA<FvApiException>().having(
              (e) => e.code,
              'code',
              'invalid_challenge',
            ),
          ),
        );
      },
    );
  });

  group('disableTwoFactor', () {
    test('disables 2FA with a valid code', () async {
      final sdk = api();
      final auth = await sdk.signup(
        fullName: 'Amina',
        email: 'a@x.com',
        password: 'Password123!',
        phone: '51234567',
      );
      final setup = await sdk.beginTwoFactorSetup(auth.token);
      await sdk.verifyTwoFactorSetup(auth.token, totp(setup.secret, now));
      final after = await sdk.securityOverview(auth.token);
      expect(after.twoFactorEnabled, isTrue);

      final ov = await sdk.disableTwoFactor(
        auth.token,
        totp(setup.secret, now),
      );
      expect(ov.twoFactorEnabled, isFalse);

      // login no longer requires 2FA
      final result = await sdk.login(
        email: 'a@x.com',
        password: 'Password123!',
      );
      expect(result.mfaRequired, isFalse);
      expect(result.token, isNotEmpty);
    });

    test('rejects an invalid code when disabling', () async {
      final sdk = api();
      final auth = await sdk.signup(
        fullName: 'Amina',
        email: 'a@x.com',
        password: 'Password123!',
        phone: '51234567',
      );
      final setup = await sdk.beginTwoFactorSetup(auth.token);
      await sdk.verifyTwoFactorSetup(auth.token, totp(setup.secret, now));
      expect(
        () => sdk.disableTwoFactor(auth.token, '000000'),
        throwsA(
          isA<FvApiException>().having((e) => e.code, 'code', 'invalid_code'),
        ),
      );
    });
  });

  group('persistence round-trip', () {
    test('MFA secret + backup codes survive a persist/hydrate cycle', () async {
      final store = MemoryStore();
      final db = MockDb(store: store, latency: 0);
      await db.hydrate();
      final sdk = MockFinovaultApi(db: db, latency: Duration.zero);
      final auth = await sdk.signup(
        fullName: 'Amina',
        email: 'a@x.com',
        password: 'Password123!',
        phone: '51234567',
      );
      final setup = await sdk.beginTwoFactorSetup(auth.token);
      await sdk.verifyTwoFactorSetup(auth.token, totp(setup.secret, now));
      await db.persist();

      // New DB hydrating from the same store still knows the secret + codes.
      final db2 = MockDb(store: store, latency: 0);
      await db2.hydrate();
      expect(db2.mfaSecrets['${auth.user.id}'], setup.secret);
      expect(db2.mfaBackupCodes['${auth.user.id}'], setup.backupCodes);
      final ov = db2.securityOverviews['${auth.user.id}'];
      expect(ov?.twoFactorEnabled, isTrue);
    });
  });
}
