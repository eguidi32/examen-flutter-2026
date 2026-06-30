import 'package:bad_wallet/features/auth/data/auth_repository.dart';
import 'package:bad_wallet/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('first launch goes from splash to phone, PIN, dashboard', (
    WidgetTester tester,
  ) async {
    final repository = _FakeAuthRepository();

    await tester.pumpWidget(BadWalletApp(authRepository: repository));

    expect(find.bySemanticsLabel('BadWallet'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();

    expect(find.text('Votre numero'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), '77 000 00 01');
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    expect(find.text('Creez votre PIN'), findsOneWidget);

    await _tapPin(tester, '1');
    await _tapPin(tester, '2');
    await _tapPin(tester, '3');
    await _tapPin(tester, '4');
    await tester.ensureVisible(find.text('Creer le PIN'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Creer le PIN'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Connecte avec +221770000001'), findsOneWidget);
    expect(repository.session?.phoneNumber, '+221770000001');
    expect(repository.session?.pin, '1234');
  });

  testWidgets('saved phone redirects from splash to PIN unlock', (
    WidgetTester tester,
  ) async {
    final repository = _FakeAuthRepository(
      session: const AuthSession(phoneNumber: '+221770000001', pin: '1234'),
    );

    await tester.pumpWidget(BadWalletApp(authRepository: repository));
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();

    expect(find.text('Entrez votre PIN'), findsOneWidget);

    await _tapPin(tester, '1');
    await _tapPin(tester, '2');
    await _tapPin(tester, '3');
    await _tapPin(tester, '4');
    await tester.ensureVisible(find.text('Deverrouiller'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deverrouiller'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
  });
}

Future<void> _tapPin(WidgetTester tester, String digit) async {
  await tester.tap(find.text(digit));
  await tester.pump();
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.session});

  AuthSession? session;

  @override
  Future<AuthSession?> readSession() async {
    return session;
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
