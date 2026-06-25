import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tekushare/domain/repositories/photo_repository.dart';
import 'package:tekushare/domain/usecases/photo/attach_photo_to_spot.dart';

import 'attach_photo_to_spot_test.mocks.dart';

@GenerateMocks([PhotoRepository])
void main() {
  late MockPhotoRepository mockRepo;
  late AttachPhotoToSpot usecase;

  setUp(() {
    mockRepo = MockPhotoRepository();
    usecase = AttachPhotoToSpot(mockRepo);
    when(mockRepo.attachPhoto(any, any))
        .thenAnswer((_) => Future<void>.value());
  });

  group('AttachPhotoToSpot', () {
    test('attachPhoto が正しい引数で呼ばれる', () async {
      await usecase.call('spot-1', '/path/to/photo.jpg');
      verify(mockRepo.attachPhoto('spot-1', '/path/to/photo.jpg')).called(1);
    });

    test('attachPhoto が1回だけ呼ばれる', () async {
      await usecase.call('spot-1', '/path/to/photo.jpg');
      verify(mockRepo.attachPhoto(any, any)).called(1);
    });
  });
}
