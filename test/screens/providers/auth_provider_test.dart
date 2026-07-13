import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tekushare/screens/providers/auth_provider.dart';

import 'auth_provider_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  ProviderContainer makeContainer() {
    return ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(mockAuthService),
      ],
    );
  }

  group('EmailAuthNotifier', () {
    test('初期状態は EmailAuthIdle', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      expect(container.read(emailAuthProvider), isA<EmailAuthIdle>());
    });

    test('register 成功時はエラー状態にならない', () async {
      when(
        mockAuthService.registerWithEmail(
          argThat(isA<String>()),
          argThat(isA<String>()),
          argThat(isA<String>()),
        ),
      ).thenAnswer((_) async => Future<void>.value());

      final container = makeContainer();
      addTearDown(container.dispose);

      await container
          .read(emailAuthProvider.notifier)
          .register('test@example.com', 'password123', 'テストユーザー');

      expect(container.read(emailAuthProvider), isNot(isA<EmailAuthError>()));
    });

    test('register でメールが重複すると EmailAuthError に遷移する', () async {
      when(
        mockAuthService.registerWithEmail(
          argThat(isA<String>()),
          argThat(isA<String>()),
          argThat(isA<String>()),
        ),
      ).thenThrow(const AuthException('email-already-in-use'));

      final container = makeContainer();
      addTearDown(container.dispose);

      await container
          .read(emailAuthProvider.notifier)
          .register('existing@example.com', 'password123', 'テストユーザー');

      final state = container.read(emailAuthProvider);
      expect(state, isA<EmailAuthError>());
      expect(
        (state as EmailAuthError).message,
        'このメールアドレスはすでに使われています',
      );
    });

    test('signIn 成功時はエラー状態にならない', () async {
      when(
        mockAuthService.signInWithEmail(
          argThat(isA<String>()),
          argThat(isA<String>()),
        ),
      ).thenAnswer((_) async => Future<void>.value());

      final container = makeContainer();
      addTearDown(container.dispose);

      await container
          .read(emailAuthProvider.notifier)
          .signIn('test@example.com', 'password123');

      expect(container.read(emailAuthProvider), isNot(isA<EmailAuthError>()));
    });

    test('signIn でパスワードが間違うと EmailAuthError に遷移する', () async {
      when(
        mockAuthService.signInWithEmail(
          argThat(isA<String>()),
          argThat(isA<String>()),
        ),
      ).thenThrow(const AuthException('invalid-credential'));

      final container = makeContainer();
      addTearDown(container.dispose);

      await container
          .read(emailAuthProvider.notifier)
          .signIn('test@example.com', 'wrongpassword');

      final state = container.read(emailAuthProvider);
      expect(state, isA<EmailAuthError>());
      expect(
        (state as EmailAuthError).message,
        'メールアドレスまたはパスワードが間違っています',
      );
    });

    test('reset を呼ぶと EmailAuthIdle に戻る', () async {
      when(
        mockAuthService.signInWithEmail(
          argThat(isA<String>()),
          argThat(isA<String>()),
        ),
      ).thenThrow(const AuthException('invalid-credential'));

      final container = makeContainer();
      addTearDown(container.dispose);

      await container
          .read(emailAuthProvider.notifier)
          .signIn('test@example.com', 'wrong');
      expect(container.read(emailAuthProvider), isA<EmailAuthError>());

      container.read(emailAuthProvider.notifier).reset();
      expect(container.read(emailAuthProvider), isA<EmailAuthIdle>());
    });
  });

  group('DisplayNameNotifier', () {
    test('save 成功時は AsyncData(null) になる', () async {
      when(mockAuthService.setDisplayName(argThat(isA<String>())))
          .thenAnswer((_) async => Future<void>.value());

      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(displayNameProvider.notifier).save('テストユーザー');

      expect(container.read(displayNameProvider), isA<AsyncData<void>>());
    });

    test('save 失敗時は AsyncError になる', () async {
      when(mockAuthService.setDisplayName(argThat(isA<String>())))
          .thenThrow(Exception('更新失敗'));

      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(displayNameProvider.notifier).save('テストユーザー');

      expect(container.read(displayNameProvider), isA<AsyncError<void>>());
    });
  });
}
