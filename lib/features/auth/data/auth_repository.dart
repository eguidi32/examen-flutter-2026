import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthSession {
  const AuthSession({required this.phoneNumber, this.pin});

  final String phoneNumber;
  final String? pin;

  bool get hasPin => pin != null && pin!.trim().isNotEmpty;
}

abstract class AuthRepository {
  Future<AuthSession?> readSession();

  Future<void> savePhoneNumber(String phoneNumber);

  Future<void> saveSession({required String phoneNumber, required String pin});

  Future<void> clearSession();
}

class SecureAuthRepository implements AuthRepository {
  SecureAuthRepository({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<AuthSession?> readSession() async {
    final phoneNumber = await _storage.read(key: AuthStorageKeys.phoneNumber);
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      return null;
    }

    final pin = await _storage.read(key: AuthStorageKeys.pin);
    return AuthSession(phoneNumber: phoneNumber, pin: pin);
  }

  @override
  Future<void> savePhoneNumber(String phoneNumber) async {
    await _storage.write(key: AuthStorageKeys.phoneNumber, value: phoneNumber);
  }

  @override
  Future<void> saveSession({
    required String phoneNumber,
    required String pin,
  }) async {
    await _storage.write(key: AuthStorageKeys.phoneNumber, value: phoneNumber);
    await _storage.write(key: AuthStorageKeys.pin, value: pin);
  }

  @override
  Future<void> clearSession() async {
    await _storage.delete(key: AuthStorageKeys.phoneNumber);
    await _storage.delete(key: AuthStorageKeys.pin);
  }
}

class AuthStorageKeys {
  const AuthStorageKeys._();

  static const String phoneNumber = 'bad_wallet_phone_number';
  static const String pin = 'bad_wallet_pin';
}
