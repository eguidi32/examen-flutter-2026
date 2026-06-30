import 'package:bad_wallet/features/auth/data/auth_repository.dart';
import 'package:bad_wallet/features/dashboard/data/dashboard_repository.dart';
import 'package:bad_wallet/features/dashboard/data/wallet_balance.dart';
import 'package:bad_wallet/main.dart';
import 'package:bad_wallet/core/models/wallet_transaction.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('first launch goes from splash to phone, then dashboard', (
    WidgetTester tester,
  ) async {
    final repository = _FakeAuthRepository();
    final dashboardRepository = _FakeDashboardRepository();

    await tester.pumpWidget(
      BadWalletApp(
        authRepository: repository,
        dashboardRepository: dashboardRepository,
      ),
    );

    expect(find.textContaining('Votre portefeuille mobile'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await _pumpTransition(tester);

    expect(find.text('Connexion à BadWallet'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), '77 000 00 01');
    await tester.ensureVisible(find.text('Continuer'));
    await tester.tap(find.text('Continuer'));
    await _pumpTransition(tester);

    expect(find.text('Bonjour, Koffi 👋'), findsOneWidget);
    expect(repository.session?.phoneNumber, '+221770000001');
    expect(repository.session?.pin, isNull);
  });

  testWidgets('saved phone redirects from splash to PIN unlock', (
    WidgetTester tester,
  ) async {
    final repository = _FakeAuthRepository(
      session: const AuthSession(phoneNumber: '+221770000001', pin: '1234'),
    );
    final dashboardRepository = _FakeDashboardRepository();

    await tester.pumpWidget(
      BadWalletApp(
        authRepository: repository,
        dashboardRepository: dashboardRepository,
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    await _pumpTransition(tester);

    expect(find.text('Entrez votre PIN'), findsOneWidget);

    await _tapPin(tester, '1');
    await _tapPin(tester, '2');
    await _tapPin(tester, '3');
    await _tapPin(tester, '4');
    await tester.ensureVisible(find.text('Deverrouiller'));
    await _pumpTransition(tester);
    await tester.tap(find.text('Deverrouiller'));
    await _pumpTransition(tester);

    expect(find.text('Bonjour, Koffi 👋'), findsOneWidget);
  });
}

Future<void> _tapPin(WidgetTester tester, String digit) async {
  await tester.tap(find.text(digit));
  await tester.pump();
}

Future<void> _pumpTransition(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 600));
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.session});

  AuthSession? session;

  @override
  Future<AuthSession?> readSession() async {
    return session;
  }

  @override
  Future<void> savePhoneNumber(String phoneNumber) async {
    session = AuthSession(phoneNumber: phoneNumber);
  }

  @override
  Future<void> saveSession({
    required String phoneNumber,
    required String pin,
  }) async {
    session = AuthSession(phoneNumber: phoneNumber, pin: pin);
  }

  @override
  Future<void> clearSession() async {
    session = null;
  }
}

class _FakeDashboardRepository implements DashboardRepository {
  @override
  Future<WalletBalance> fetchBalance(String phoneNumber) async {
    return WalletBalance(
      phoneNumber: phoneNumber,
      code: 'BW-0001',
      balance: 50000,
      currency: 'XOF',
    );
  }

  @override
  Future<List<WalletTransaction>> fetchRecentTransactions(
    String phoneNumber,
  ) async {
    return const [];
  }
}
