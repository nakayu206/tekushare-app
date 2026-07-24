import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/screens/widgets/common/photo_viewer_dialog.dart';

void main() {
  // Builder 内の context を onPressed でキャプチャすることで stale context を回避
  Widget buildApp(String path, {void Function()? onDelete}) => MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) {
            return TextButton(
              onPressed: () =>
                  showPhotoViewer(context, path, onDelete: onDelete),
              child: const Text('open'),
            );
          }),
        ),
      );

  group('showPhotoViewer', () {
    // 【バグ再現テスト】ローカルパスに CachedNetworkImage を使うと壊れる問題 (#145)
    testWidgets('ローカルパスのとき CachedNetworkImage を使わず Image.file を使う',
        (tester) async {
      await tester.pumpWidget(buildApp('/local/path/photo.jpg'));
      await tester.tap(find.text('open'));
      await tester.pump();

      expect(find.byType(CachedNetworkImage), findsNothing);
      expect(
        find.byWidgetPredicate((w) => w is Image && w.image is FileImage),
        findsOneWidget,
      );
    });

    testWidgets('http URL のとき CachedNetworkImage を使う', (tester) async {
      await tester.pumpWidget(buildApp('https://example.com/photo.jpg'));
      await tester.tap(find.text('open'));
      await tester.pump();

      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });

    testWidgets('閉じるボタンでダイアログが閉じる', (tester) async {
      await tester.pumpWidget(buildApp('/local/path/photo.jpg'));
      await tester.tap(find.text('open'));
      await tester.pump();

      expect(find.byType(Dialog), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('onDelete あり: 削除ボタンが表示され、タップで onDelete が呼ばれる', (tester) async {
      var deleted = false;
      await tester.pumpWidget(
        buildApp('/local/path/photo.jpg', onDelete: () => deleted = true),
      );

      await tester.tap(find.text('open'));
      await tester.pump();

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(deleted, isTrue);
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('onDelete なし: 削除ボタンが表示されない', (tester) async {
      await tester.pumpWidget(buildApp('/local/path/photo.jpg'));
      await tester.tap(find.text('open'));
      await tester.pump();

      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });
  });
}
