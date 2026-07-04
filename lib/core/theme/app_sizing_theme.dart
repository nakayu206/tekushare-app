import 'package:flutter/material.dart';

/// 画面幅に応じてスケーリングされるサイズ値を保持する ThemeExtension。
/// MaterialApp.builder で一度だけ計算し、全ウィジェットで Theme.of(context) を通じて共有する。
@immutable
class AppSizingTheme extends ThemeExtension<AppSizingTheme> {
  const AppSizingTheme({
    required this.primaryBtnHeight,
    required this.primaryBtnFontSize,
    required this.primaryBtnRadius,
    required this.actionBtnHeight,
    required this.actionBtnFontSize,
    required this.actionBtnIconSize,
    required this.actionBtnRadius,
    required this.largeBtnHeight,
    required this.detailBtnHeight,
    required this.detailBtnFontSize,
    required this.detailBtnRadius,
    required this.clockFontSize,
    required this.clockLabelFontSize,
    required this.chipWidth,
    required this.chipHeight,
    required this.locationAreaHeight,
    required this.photoBoxWidth,
    required this.photoBoxHeight,
    required this.walkInfoPhotoHeight,
    required this.mapPlaceholderHeight,
    required this.dialogBtnHeight,
    required this.tabLabelFontSize,
    required this.listItemFontSize,
    required this.sectionSpacing,
    required this.foot2Width,
    required this.foot2Height,
    required this.segmentBtnWidth,
    required this.calendarUnderlineWidth,
    required this.routeTagFontSize,
    required this.routeListHeadingFontSize,
    required this.routeItemNameFontSize,
    required this.routeItemSubFontSize,
  });

  /// プライマリボタン（散歩を始める / 散歩を終了するなど）
  final double primaryBtnHeight;
  final double primaryBtnFontSize;
  final double primaryBtnRadius;

  /// 散歩アクションボタン（写真を撮る / 行きたいリストに保存）
  final double actionBtnHeight;
  final double actionBtnFontSize;
  final double actionBtnIconSize;
  final double actionBtnRadius;

  /// 行きたい！保存ボタン（大サイズ）
  final double largeBtnHeight;

  /// 詳細ページの操作ボタン（上書き保存 / 削除）
  final double detailBtnHeight;
  final double detailBtnFontSize;
  final double detailBtnRadius;

  /// ClockHeader の時刻・片道ラベル
  final double clockFontSize;
  final double clockLabelFontSize;

  /// カテゴリチップ
  final double chipWidth;
  final double chipHeight;

  /// 位置情報エリア・写真エリア（スポット詳細 / 行きたい！ / 散歩ルート）
  final double locationAreaHeight;
  final double photoBoxWidth;
  final double photoBoxHeight;
  final double walkInfoPhotoHeight;

  /// ルートページの地図プレースホルダー
  final double mapPlaceholderHeight;

  /// 汎用ダイアログボタン
  final double dialogBtnHeight;

  /// タブラベル・リストアイテム文字サイズ
  final double tabLabelFontSize;
  final double listItemFontSize;

  /// セクション間スペーサー（34dp 系）
  final double sectionSpacing;

  /// 終了画面の足あと SVG
  final double foot2Width;
  final double foot2Height;

  /// 設定画面セグメントボタン幅
  final double segmentBtnWidth;

  /// カレンダー行のアンダーライン幅
  final double calendarUnderlineWidth;

  /// ルートタグの文字サイズ
  final double routeTagFontSize;

  /// 保存済みルート一覧の見出し・アイテム文字サイズ
  final double routeListHeadingFontSize;
  final double routeItemNameFontSize;
  final double routeItemSubFontSize;

  /// デザイン基準幅 390dp を起点に clamp 付きでスケーリングして生成する。
  factory AppSizingTheme.fromScreenWidth(double sw) {
    double s(double design, double min, double max) =>
        (sw * (design / 390.0)).clamp(min, max);

    return AppSizingTheme(
      primaryBtnHeight: s(120, 72, 120),
      primaryBtnFontSize: s(28, 18, 28),
      primaryBtnRadius: s(60, 36, 60),
      actionBtnHeight: s(105, 64, 105),
      actionBtnFontSize: s(20, 14, 20),
      actionBtnIconSize: s(30, 20, 30),
      actionBtnRadius: s(52, 32, 52),
      largeBtnHeight: s(94, 64, 94),
      detailBtnHeight: s(56, 44, 56),
      detailBtnFontSize: s(18, 14, 18),
      detailBtnRadius: s(47, 32, 47),
      clockFontSize: s(96, 64, 96),
      clockLabelFontSize: s(32, 22, 32),
      chipWidth: s(108, 80, 108),
      chipHeight: s(48, 36, 48),
      locationAreaHeight: s(161, 120, 161),
      photoBoxWidth: s(176, 130, 176),
      photoBoxHeight: s(100, 72, 100),
      walkInfoPhotoHeight: s(90, 64, 90),
      mapPlaceholderHeight: s(160, 120, 160),
      dialogBtnHeight: s(52, 40, 52),
      tabLabelFontSize: s(24, 16, 24),
      listItemFontSize: s(20, 14, 20),
      sectionSpacing: s(34, 24, 34),
      foot2Width: s(33, 22, 33),
      foot2Height: s(49, 33, 49),
      segmentBtnWidth: s(80, 60, 80),
      calendarUnderlineWidth: s(46, 28, 46),
      routeTagFontSize: s(13, 11, 13),
      routeListHeadingFontSize: s(18, 14, 18),
      routeItemNameFontSize: s(16, 13, 16),
      routeItemSubFontSize: s(13, 11, 13),
    );
  }

  /// `Theme.of(context).extension<AppSizingTheme>()!` の糖衣構文
  static AppSizingTheme of(BuildContext context) =>
      Theme.of(context).extension<AppSizingTheme>()!;

  @override
  AppSizingTheme copyWith({
    double? primaryBtnHeight,
    double? primaryBtnFontSize,
    double? primaryBtnRadius,
    double? actionBtnHeight,
    double? actionBtnFontSize,
    double? actionBtnIconSize,
    double? actionBtnRadius,
    double? largeBtnHeight,
    double? detailBtnHeight,
    double? detailBtnFontSize,
    double? detailBtnRadius,
    double? clockFontSize,
    double? clockLabelFontSize,
    double? chipWidth,
    double? chipHeight,
    double? locationAreaHeight,
    double? photoBoxWidth,
    double? photoBoxHeight,
    double? walkInfoPhotoHeight,
    double? mapPlaceholderHeight,
    double? dialogBtnHeight,
    double? tabLabelFontSize,
    double? listItemFontSize,
    double? sectionSpacing,
    double? foot2Width,
    double? foot2Height,
    double? segmentBtnWidth,
    double? calendarUnderlineWidth,
    double? routeTagFontSize,
    double? routeListHeadingFontSize,
    double? routeItemNameFontSize,
    double? routeItemSubFontSize,
  }) =>
      AppSizingTheme(
        primaryBtnHeight: primaryBtnHeight ?? this.primaryBtnHeight,
        primaryBtnFontSize: primaryBtnFontSize ?? this.primaryBtnFontSize,
        primaryBtnRadius: primaryBtnRadius ?? this.primaryBtnRadius,
        actionBtnHeight: actionBtnHeight ?? this.actionBtnHeight,
        actionBtnFontSize: actionBtnFontSize ?? this.actionBtnFontSize,
        actionBtnIconSize: actionBtnIconSize ?? this.actionBtnIconSize,
        actionBtnRadius: actionBtnRadius ?? this.actionBtnRadius,
        largeBtnHeight: largeBtnHeight ?? this.largeBtnHeight,
        detailBtnHeight: detailBtnHeight ?? this.detailBtnHeight,
        detailBtnFontSize: detailBtnFontSize ?? this.detailBtnFontSize,
        detailBtnRadius: detailBtnRadius ?? this.detailBtnRadius,
        clockFontSize: clockFontSize ?? this.clockFontSize,
        clockLabelFontSize: clockLabelFontSize ?? this.clockLabelFontSize,
        chipWidth: chipWidth ?? this.chipWidth,
        chipHeight: chipHeight ?? this.chipHeight,
        locationAreaHeight: locationAreaHeight ?? this.locationAreaHeight,
        photoBoxWidth: photoBoxWidth ?? this.photoBoxWidth,
        photoBoxHeight: photoBoxHeight ?? this.photoBoxHeight,
        walkInfoPhotoHeight: walkInfoPhotoHeight ?? this.walkInfoPhotoHeight,
        mapPlaceholderHeight: mapPlaceholderHeight ?? this.mapPlaceholderHeight,
        dialogBtnHeight: dialogBtnHeight ?? this.dialogBtnHeight,
        tabLabelFontSize: tabLabelFontSize ?? this.tabLabelFontSize,
        listItemFontSize: listItemFontSize ?? this.listItemFontSize,
        sectionSpacing: sectionSpacing ?? this.sectionSpacing,
        foot2Width: foot2Width ?? this.foot2Width,
        foot2Height: foot2Height ?? this.foot2Height,
        segmentBtnWidth: segmentBtnWidth ?? this.segmentBtnWidth,
        calendarUnderlineWidth:
            calendarUnderlineWidth ?? this.calendarUnderlineWidth,
        routeTagFontSize: routeTagFontSize ?? this.routeTagFontSize,
        routeListHeadingFontSize:
            routeListHeadingFontSize ?? this.routeListHeadingFontSize,
        routeItemNameFontSize:
            routeItemNameFontSize ?? this.routeItemNameFontSize,
        routeItemSubFontSize: routeItemSubFontSize ?? this.routeItemSubFontSize,
      );

  @override
  AppSizingTheme lerp(AppSizingTheme? other, double t) => this;
}
