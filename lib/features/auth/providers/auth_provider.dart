import 'package:flutter/foundation.dart';

import '../data/auth_repository.dart';
import '../data/phone_number_formatter.dart';

enum PinMode { setup, unlock }

sealed class AuthState {
  const AuthState();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthPhoneEntry extends AuthState {
  const AuthPhoneEntry({this.errorMessage});

  final String? errorMessage;
}

class AuthPinEntry extends AuthState {
  const AuthPinEntry({
    required this.phoneNumber,
    required this.mode,
    this.errorMessage,
  });

  final String phoneNumber;
  final PinMode mode;
  final String? errorMessage;
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.phoneNumber});

  final String phoneNumber;
}

class AuthError extends AuthState {
  const AuthError({required this.message});

  final String message;
}

class AuthProvider extends ChangeNotifier {
  AuthProvider({required this.authRepository});

  static const Duration _minimumSplashDuration = Duration(milliseconds: 1300);

  final AuthRepository authRepository;

  AuthState _state = const AuthLoading();

  AuthState get state => _state;

  Future<void> bootstrap() async {
    _setState(const AuthLoading());
    final startedAt = DateTime.now();

    try {
      final session = await authRepository.readSession();
      await _waitForSplash(startedAt);

      if (session == null) {
        _setState(const AuthPhoneEntry());
        return;
      }

      _setState(
        AuthPinEntry(
          phoneNumber: session.phoneNumber,
          mode: session.hasPin ? PinMode.unlock : PinMode.setup,
        ),
      );
    } catch (_) {
      await _waitForSplash(startedAt);
      _setState(
        const AuthError(message: 'Impossible de lire la session securisee.'),
      );
    }
  }

  void submitPhone(String rawPhoneNumber) {
    final phoneNumber = PhoneNumberFormatter.normalize(rawPhoneNumber);

    if (!PhoneNumberFormatter.isValid(phoneNumber)) {
      _setState(
        const AuthPhoneEntry(
          errorMessage: PhoneNumberFormatter.validationMessage,
        ),
      );
      return;
    }

    _setState(AuthPinEntry(phoneNumber: phoneNumber, mode: PinMode.setup));
  }

  Future<void> submitPin(String pin) async {
    final currentState = _state;
    if (currentState is! AuthPinEntry) {
      return;
    }

    if (!_isValidPin(pin)) {
      _setState(
        AuthPinEntry(
          phoneNumber: currentState.phoneNumber,
          mode: currentState.mode,
          errorMessage: 'Le PIN doit contenir entre 4 et 6 chiffres.',
        ),
      );
      return;
    }

    try {
      if (currentState.mode == PinMode.setup) {
        await authRepository.saveSession(
          phoneNumber: currentState.phoneNumber,
          pin: pin,
        );
        _setState(AuthAuthenticated(phoneNumber: currentState.phoneNumber));
        return;
      }

      final session = await authRepository.readSession();
      if (session?.pin == pin) {
        _setState(AuthAuthenticated(phoneNumber: currentState.phoneNumber));
        return;
      }

      _setState(
        AuthPinEntry(
          phoneNumber: currentState.phoneNumber,
          mode: currentState.mode,
          errorMessage: 'PIN incorrect. Reessayez.',
        ),
      );
    } catch (_) {
      _setState(
        AuthPinEntry(
          phoneNumber: currentState.phoneNumber,
          mode: currentState.mode,
          errorMessage: 'Impossible de verifier le PIN.',
        ),
      );
    }
  }

  void clearPinError() {
    final currentState = _state;
    if (currentState is! AuthPinEntry || currentState.errorMessage == null) {
      return;
    }

    _setState(
      AuthPinEntry(
        phoneNumber: currentState.phoneNumber,
        mode: currentState.mode,
      ),
    );
  }

  Future<void> clearSession() async {
    await authRepository.clearSession();
    _setState(const AuthPhoneEntry());
  }

  Future<void> retryBootstrap() {
    return bootstrap();
  }

  void _setState(AuthState state) {
    _state = state;
    notifyListeners();
  }

  Future<void> _waitForSplash(DateTime startedAt) async {
    final elapsed = DateTime.now().difference(startedAt);
    if (elapsed >= _minimumSplashDuration) {
      return;
    }

    await Future<void>.delayed(_minimumSplashDuration - elapsed);
  }

  bool _isValidPin(String pin) {
    return RegExp(r'^\d{4,6}$').hasMatch(pin);
  }
}
