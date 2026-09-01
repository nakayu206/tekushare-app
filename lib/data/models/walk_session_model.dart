import 'package:objectbox/objectbox.dart';
import 'package:tekushare/domain/entities/walk_session.dart';

@Entity()
class WalkSessionModel {
  @Id()
  int id = 0;

  @Index()
  @Unique()
  late String uid;

  @Index()
  String userUid = '';

  late String statusName;

  @Property(type: PropertyType.date)
  DateTime? startedAt;

  @Property(type: PropertyType.date)
  DateTime? finishedAt;

  late int elapsedSeconds;

  WalkSession toEntity() {
    return WalkSession(
      id: uid,
      status: WalkStatus.values.firstWhere(
        (e) => e.name == statusName,
        orElse: () => WalkStatus.idle,
      ),
      startedAt: startedAt,
      finishedAt: finishedAt,
      elapsedSeconds: elapsedSeconds,
    );
  }

  static WalkSessionModel fromEntity(WalkSession session, String userUid) {
    return WalkSessionModel()
      ..uid = session.id
      ..userUid = userUid
      ..statusName = session.status.name
      ..startedAt = session.startedAt
      ..finishedAt = session.finishedAt
      ..elapsedSeconds = session.elapsedSeconds;
  }
}
