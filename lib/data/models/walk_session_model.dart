import 'package:isar/isar.dart';
import 'package:tekushare/domain/entities/walk_session.dart';

part 'walk_session_model.g.dart';

@Collection()
class WalkSessionModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uid;

  @Enumerated(EnumType.name)
  late WalkStatus status;

  DateTime? startedAt;
  DateTime? finishedAt;
  late int elapsedSeconds;

  WalkSession toEntity() {
    return WalkSession(
      id: uid,
      status: status,
      startedAt: startedAt,
      finishedAt: finishedAt,
      elapsedSeconds: elapsedSeconds,
    );
  }

  static WalkSessionModel fromEntity(WalkSession session) {
    return WalkSessionModel()
      ..uid = session.id
      ..status = session.status
      ..startedAt = session.startedAt
      ..finishedAt = session.finishedAt
      ..elapsedSeconds = session.elapsedSeconds;
  }
}
