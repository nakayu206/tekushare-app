import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tekushare/infrastructure/camera_service.dart';

import 'camera_service_test.mocks.dart';

@GenerateMocks([ImagePicker])
void main() {
  late MockImagePicker mockPicker;
  late CameraService service;

  setUp(() {
    mockPicker = MockImagePicker();
    service = CameraService(picker: mockPicker);
  });

  group('CameraService', () {
    group('takePhoto', () {
      test('撮影した画像のパスを返す', () async {
        when(
          mockPicker.pickImage(
            source: ImageSource.camera,
            imageQuality: 85,
          ),
        ).thenAnswer((_) async => XFile('/path/to/photo.jpg'));

        final result = await service.takePhoto();

        expect(result, '/path/to/photo.jpg');
      });

      test('キャンセル時は null を返す', () async {
        when(
          mockPicker.pickImage(
            source: ImageSource.camera,
            imageQuality: 85,
          ),
        ).thenAnswer((_) async => null);

        final result = await service.takePhoto();

        expect(result, isNull);
      });
    });

    group('pickFromGallery', () {
      test('選択した画像のパスを返す', () async {
        when(
          mockPicker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 85,
          ),
        ).thenAnswer((_) async => XFile('/path/to/gallery.jpg'));

        final result = await service.pickFromGallery();

        expect(result, '/path/to/gallery.jpg');
      });

      test('キャンセル時は null を返す', () async {
        when(
          mockPicker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 85,
          ),
        ).thenAnswer((_) async => null);

        final result = await service.pickFromGallery();

        expect(result, isNull);
      });
    });
  });
}
