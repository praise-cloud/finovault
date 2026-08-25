import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

/// Thin wrapper around the platform biometric API. All calls are guarded so the
/// UI never throws if biometrics are unavailable (e.g. on the web or in tests).
class BiometricService {
  final LocalAuthentication _local = LocalAuthentication();

  /// True when the device can actually perform a biometric challenge.
  Future<bool> get available async {
    try {
      return await _local.canCheckBiometrics || await _local.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// Prompts the user. Returns true only on a successful challenge.
  Future<bool> authenticate([String reason = 'Unlock your Finovault vault']) async {
    try {
      return await _local.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(biometricOnly: false, stickyAuth: true),
      );
    } catch (_) {
      return false;
    }
  }
}

final biometricServiceProvider = Provider<BiometricService>((ref) => BiometricService());

/// Whether the vault has been unlocked with biometrics for this app session.
/// Reset on logout so re-entry requires a fresh challenge.
final biometricSessionUnlockedProvider = StateProvider<bool>((ref) => false);
