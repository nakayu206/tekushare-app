import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef WalkRoute = ({String date, String name, String distance, String time});
typedef WalkLog = ({
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
    this.selectedDay = 2,
    this.routes = _defaultRoutes,
    this.logs = _defaultLogs,
  });

  final int selectedRouteIndex;
  final int selectedDay;
  final List<WalkRoute> routes;
  final List<WalkLog> logs;

  static const _defaultRoutes = <WalkRoute>[
    (date: '2/7', name: '公園まわりコース（朝用）', distance: '1.2km', time: '約15分'),
    (date: '2/6', name: '川沿いコース（休日用）', distance: '2.5km', time: '約30分'),
    (date: '2/5', name: '商店街コース', distance: '1.2km', time: '約15分'),
    (date: '2/4', name: '公園まわりコース（朝用）', distance: '1.2km', time: '約15分'),
    (date: '2/3', name: '川沿いコース（休日用）', distance: '2.5km', time: '約30分'),
    (date: '2/2', name: '商店街コース', distance: '1.2km', time: '約15分'),
    (date: '2/1', name: '公園まわりコース（朝用）', distance: '1.2km', time: '約15分'),
  ];

  static const _defaultLogs = <WalkLog>[
    (
      date: '2026年02月01日(日)',
      startEndTime: '6:30~6:45',
      duration: '00:15',
      distance: '1.2km',
      spotCount: 1,
      dayLabel: '日',
    ),
    (
      date: '2026年02月02日(月)',
      startEndTime: '7:05~7:20',
      duration: '00:15',
      distance: '1.2km',
      spotCount: 1,
      dayLabel: '月',
    ),
    (
      date: '2026年02月03日(火)',
      startEndTime: '8:00~8:30',
      duration: '00:30',
      distance: '2.5km',
      spotCount: 2,
      dayLabel: '火',
    ),
    (
      date: '2026年02月04日(水)',
      startEndTime: '7:00~7:15',
      duration: '00:15',
      distance: '1.2km',
      spotCount: 1,
      dayLabel: '水',
    ),
    (
      date: '2026年02月05日(木)',
      startEndTime: '7:30~7:45',
      duration: '00:15',
      distance: '1.2km',
      spotCount: 1,
      dayLabel: '木',
    ),
    (
      date: '2026年02月06日(金)',
      startEndTime: '8:10~8:40',
      duration: '00:30',
      distance: '2.5km',
      spotCount: 3,
      dayLabel: '金',
    ),
    (
      date: '2026年02月07日(土)',
      startEndTime: '9:00~9:15',
      duration: '00:15',
      distance: '1.2km',
      spotCount: 1,
      dayLabel: '土',
    ),
  ];

  WalkRoute get selectedRoute => routes[selectedRouteIndex];
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
    List<WalkRoute>? routes,
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

  void saveRoute(WalkRoute route) {
    state = state.copyWith(routes: [route, ...state.routes]);
  }

  void setLogs(List<WalkLog> logs) {
    state = state.copyWith(logs: logs);
  }
}

final walkRouteViewModelProvider =
    NotifierProvider<WalkRouteViewModel, WalkRouteState>(
  WalkRouteViewModel.new,
);
