import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/firebase_options.dart';

void main() {
  group('DefaultFirebaseOptions', () {
    const expectedProjectId = 'tekushare';
    const expectedSenderId = '607979997790';

    test('Androidオプションに正しいprojectIdとmessagingSenderIdが設定されている', () {
      const options = DefaultFirebaseOptions.android;
      expect(options.projectId, expectedProjectId);
      expect(options.messagingSenderId, expectedSenderId);
      expect(options.apiKey, isNotEmpty);
      expect(options.appId, isNotEmpty);
    });

    test('iOSオプションに正しいprojectIdとmessagingSenderIdが設定されている', () {
      const options = DefaultFirebaseOptions.ios;
      expect(options.projectId, expectedProjectId);
      expect(options.messagingSenderId, expectedSenderId);
      expect(options.apiKey, isNotEmpty);
      expect(options.appId, isNotEmpty);
    });

    test('Webオプションに正しいprojectIdとmessagingSenderIdが設定されている', () {
      const options = DefaultFirebaseOptions.web;
      expect(options.projectId, expectedProjectId);
      expect(options.messagingSenderId, expectedSenderId);
      expect(options.apiKey, isNotEmpty);
      expect(options.appId, isNotEmpty);
    });

  });
}
