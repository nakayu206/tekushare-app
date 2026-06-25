import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tekushare/domain/entities/spot.dart';
import 'package:tekushare/domain/repositories/spot_repository.dart';
import 'package:tekushare/domain/usecases/spot/update_spot_status.dart';

import 'update_spot_status_test.mocks.dart';

@GenerateMocks([SpotRepository])
void main() {
  late MockSpotRepository mockRepo;
  late UpdateSpotStatus usecase;

  setUp(() {
    mockRepo = MockSpotRepository();
    usecase = UpdateSpotStatus(mockRepo);
    when(mockRepo.updateSpotStatus(any, any))
        .thenAnswer((_) => Future<void>.value());
  });

  group('UpdateSpotStatus', () {
    test('updateSpotStatus が正しい引数で呼ばれる', () async {
      await usecase.call('spot-1', SpotStatus.visited);
      verify(mockRepo.updateSpotStatus('spot-1', SpotStatus.visited)).called(1);
    });

    test('wantToGo ステータスでも呼び出せる', () async {
      await usecase.call('spot-2', SpotStatus.wantToGo);
      verify(mockRepo.updateSpotStatus('spot-2', SpotStatus.wantToGo))
          .called(1);
    });
  });
}
