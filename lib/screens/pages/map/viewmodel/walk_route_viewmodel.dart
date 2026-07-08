import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef SavedRouteItem = ({
  String date,
  String name,
  String distance,
  String time,
  String? walkSessionId,
});
typedef WalkLog = ({
  String sessionId,
  String date,
  String startEndTime,
  String duration,
  String distance,
  int spotCount,
  String dayLabel,
});

class WalkRouteState {
  const WalkRouteState({
    this.selectedRouteIndex = 0,
    this.selectedDay = 7,
    this.routes = const [],
    this.logs = _defaultLogs,
  });

  final int selectedRouteIndex;
  final int selectedDay;
  final List<SavedRouteItem> routes;
  final List<WalkLog> logs;

  static const _defaultLogs = <WalkLog>[
    (
      sessionId: '',
      date: '2026年02月01日(日)',
      startEndTime: '6:30~6:45',
      duration: '00:15',
      distance: '1.2km',
      spotCount: 1,
      dayLabel: '日',
    ),
    (
      sessionId: '',
      date: '2026年02月02日(月)',
      startEndTime: '7:05~7:20',
      duration: '00:15',
      distance: '1.2km',
      spotCount: 1,
      dayLabel: '月',
    ),
    (
      sessionId: '',
      date: '2026年02月03日(火)',
      startEndTime: '8:00~8:30',
      duration: '00:30',
      distance: '2.5km',
      spotCount: 2,
      dayLabel: '火',
    ),
    (
      sessionId: '',
      date: '2026年02月04日(水)',
      startEndTime: '7:00~7:15',
      duration: '00:15',
      distance: '1.2km',
      spotCount: 1,
      dayLabel: '水',
    ),
    (
      sessionId: '',
      date: '2026年02月05日(木)',
      startEndTime: '7:30~7:45',
      duration: '00:15',
      distance: '1.2km',
      spotCount: 1,
      dayLabel: '木',
    ),
    (
      sessionId: '',
      date: '2026年02月06日(金)',
      startEndTime: '8:10~8:40',
      duration: '00:30',
      distance: '2.5km',
      spotCount: 3,
      dayLabel: '金',
    ),
    (
      sessionId: '',
      date: '2026年02月07日(土)',
      startEndTime: '9:00~9:15',
      duration: '00:15',
      distance: '1.2km',
      spotCount: 1,
      dayLabel: '土',
    ),
  ];

  SavedRouteItem? get selectedRoute =>
      routes.isEmpty ? null : routes[selectedRouteIndex];

  WalkLog get selectedLog => logs[selectedDay - 1];

  String get defaultRouteName {
    final log = selectedLog;
    final match = RegExp(r'\d+年0?(\d+)月0?(\d+)日\((.+)\)').firstMatch(log.date);
    if (match == null) return log.date;
    final month = match.group(1)!;
    final day = match.group(2)!;
    final weekday = match.group(3)!;
    final startTime = log.startEndTime.split('~').first;
    final parts = startTime.split(':');
    final paddedTime =
        '${parts[0].padLeft(2, '0')}:${parts.length > 1 ? parts[1] : '00'}';
    return '$month月$day日（$weekday）$paddedTime~';
  }

  WalkRouteState copyWith({
    int? selectedRouteIndex,
    int? selectedDay,
    List<SavedRouteItem>? routes,
    List<WalkLog>? logs,
  }) =>
      WalkRouteState(
        selectedRouteIndex: selectedRouteIndex ?? this.selectedRouteIndex,
        selectedDay: selectedDay ?? this.selectedDay,
        routes: routes ?? this.routes,
        logs: logs ?? this.logs,
      );
}

class WalkRouteViewModel extends Notifier<WalkRouteState> {
  @override
  WalkRouteState build() => const WalkRouteState();

  void selectRoute(int index) {
    state = state.copyWith(selectedRouteIndex: index);
  }

  void selectDay(int day) {
    state = state.copyWith(selectedDay: day);
  }

  void saveRoute(SavedRouteItem route) {
    final updated = [...state.routes, route];
    state = state.copyWith(
      routes: updated,
      selectedRouteIndex: updated.length - 1,
    );
  }

  void setRoutes(List<SavedRouteItem> routes) {
    final index = routes.isEmpty ? 0 : routes.length - 1;
    state = state.copyWith(routes: routes, selectedRouteIndex: index);
  }

  void setLogs(List<WalkLog> logs) {
    state = state.copyWith(logs: logs);
  }
}

final walkRouteViewModelProvider =
    NotifierProvider<WalkRouteViewModel, WalkRouteState>(
  WalkRouteViewModel.new,
);
