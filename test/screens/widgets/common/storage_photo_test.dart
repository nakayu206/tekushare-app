import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/screens/providers/auth_provider.dart';
import 'package:tekushare/screens/widgets/common/photo_viewer_dialog.dart';
import 'package:tekushare/screens/widgets/common/storage_photo.dart';

// 1x1 の透明PNG
final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

Widget _wrap(Future<Uint8List?> Function(String) loader, String path) {
  return ProviderScope(
    overrides: [storagePhotoLoaderProvider.overrideWithValue(loader)],
    child: MaterialApp(
      home: StoragePhoto(
        path: path,
        errorWidget: (_, __, ___) => const Text('error'),
        placeholder: (_, __) => const Text('loading'),
      ),
    ),
  );
}

Widget _errorBuilder(BuildContext _, String __, Object ___) =>
    const Text('error');

void main() {
  test('isStoragePath は users/ 始まりのみ true', () {
    expect(isStoragePath('users/a/spots/s/x.jpg'), true);
    expect(isStoragePath('https://example.com/x.jpg'), false);
  });

  testWidgets('Storageのパスはローダー経由で取得して表示する', (tester) async {
    String? requested;
    await tester.pumpWidget(_wrap((p) async {
      requested = p;
      return Uint8List.fromList(_png);
    }, 'users/alice/spots/s1/a_${DateTime.now().microsecondsSinceEpoch}.jpg'));
    expect(find.text('loading'), findsOneWidget);
    await tester.pump();
    await tester.pump();
    expect(requested, startsWith('users/alice/spots/s1/'));
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('取得に失敗したらエラー表示になる', (tester) async {
    await tester.pumpWidget(_wrap((_) async => throw Exception('denied'),
        'users/alice/spots/s1/b_${DateTime.now().microsecondsSinceEpoch}.jpg'));
    await tester.pump();
    await tester.pump();
    expect(find.text('error'), findsOneWidget);
  });

  group('キャッシュ', () {
    const path = 'users/alice/spots/s1/cache.jpg';
    late int calls;
    late StateProvider<String> uidProvider;

    Widget app(ProviderContainer c) => UncontrolledProviderScope(
          container: c,
          child: const MaterialApp(home: StoragePhoto(path: path)),
        );

    ProviderContainer makeContainer(
        {Future<Uint8List?> Function(String)? loader}) {
      calls = 0;
      uidProvider = StateProvider((_) => 'bob');
      final c = ProviderContainer(overrides: [
        storagePhotoLoaderProvider.overrideWithValue(loader ??
            (_) async {
              calls++;
              return Uint8List.fromList(_png);
            }),
        authStateProvider.overrideWith(
            (ref) => Stream.value(AuthUser(uid: ref.watch(uidProvider)))),
      ]);
      addTearDown(c.dispose);
      return c;
    }

    testWidgets('同じユーザーの間は再取得しない', (tester) async {
      final c = makeContainer();
      await c.read(authStateProvider.future);
      await tester.pumpWidget(app(c));
      await tester.pump();
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(app(c));
      await tester.pump();
      expect(calls, 1);
    });

    testWidgets('表示したままユーザーが切り替わっても取得し直し、拒否なら表示を消す', (tester) async {
      var deny = false;
      final c = makeContainer(loader: (_) async {
        calls++;
        if (deny) throw Exception('denied');
        return Uint8List.fromList(_png);
      });
      await c.read(authStateProvider.future);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: StoragePhoto(
            path: path,
            errorWidget: _errorBuilder,
          ),
        ),
      ));
      await tester.pump();
      expect(find.byType(Image), findsOneWidget);

      deny = true;
      c.read(uidProvider.notifier).state = 'carol';
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pump(const Duration(milliseconds: 10));
      expect(calls, 2);
      expect(find.text('error'), findsOneWidget);
    });

    testWidgets('表示したまま保持期限が来たら認証付きで取得し直す', (tester) async {
      final c = makeContainer();
      await c.read(authStateProvider.future);
      await tester.pumpWidget(app(c));
      await tester.pump();
      expect(calls, 1);
      await tester.pump(storagePhotoCacheTtl + const Duration(seconds: 1));
      await tester.pump();
      expect(calls, 2);
    });

    testWidgets('ユーザーが切り替わるとキャッシュを破棄して再取得する', (tester) async {
      final c = makeContainer();
      await c.read(authStateProvider.future);
      await tester.pumpWidget(app(c));
      await tester.pump();
      await tester.pumpWidget(const SizedBox());
      c.read(uidProvider.notifier).state = 'carol';
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pumpWidget(app(c));
      await tester.pump();
      expect(calls, 2);
    });
  });

  testWidgets('拡大表示でもStorageのパスは認証付きで取得する', (tester) async {
    String? requested;
    await tester.pumpWidget(ProviderScope(
      overrides: [
        storagePhotoLoaderProvider.overrideWithValue((p) async {
          requested = p;
          return Uint8List.fromList(_png);
        }),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showPhotoViewer(context,
                'users/alice/spots/s1/viewer_${DateTime.now().microsecondsSinceEpoch}.jpg'),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump();
    expect(requested, startsWith('users/alice/'));
  });
}
