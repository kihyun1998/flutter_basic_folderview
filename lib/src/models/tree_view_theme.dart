import 'package:flutter/material.dart';

/// 완전히 개선된 TreeView 테마 데이터
class TreeViewThemeData {
  // 스크롤바 설정
  final bool showVerticalScrollbar;
  final bool showHorizontalScrollbar;
  final double scrollbarWidth;
  final Color scrollbarColor;
  final Color scrollbarTrackColor;
  final bool scrollbarHoverOnly;
  final double scrollbarOpacity;
  final double scrollbarHoverOpacity;

  // 노드 스타일
  final double nodeVerticalPadding;
  final double nodeHorizontalPadding;
  final double iconSize;
  final double iconSpacing;
  final BorderRadius nodeBorderRadius;
  final Color? nodeHoverColor;
  final Color? nodeSelectedColor;
  final Color? nodeDisabledColor;
  final double nodeMinHeight;

  // 아이콘 색상
  final Color folderColor;
  final Color folderExpandedColor;
  final Color nodeColor;
  final Color nodeExpandedColor;
  final Color accountColor;
  final Color arrowColor;
  final Color disabledIconColor;

  // 전체 레이아웃
  final double indentSize;
  final double nodeSpacing;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final BorderRadius borderRadius;

  // 텍스트 스타일
  final TextStyle folderTextStyle;
  final TextStyle nodeTextStyle;
  final TextStyle accountTextStyle;
  final TextStyle disabledTextStyle;
  final TextStyle selectedTextStyle;

  // 애니메이션 설정
  final Duration expansionAnimationDuration;
  final Duration hoverAnimationDuration;
  final Curve expansionCurve;

  // 상호작용 설정
  final bool enableHoverEffects;
  final bool enableRippleEffects;
  final Color? rippleColor;

  const TreeViewThemeData({
    // 스크롤바 기본값
    this.showVerticalScrollbar = true,
    this.showHorizontalScrollbar = true,
    this.scrollbarWidth = 12.0,
    this.scrollbarColor = const Color(0xFF757575),
    this.scrollbarTrackColor = const Color(0x1A000000),
    this.scrollbarHoverOnly = true,
    this.scrollbarOpacity = 0.7,
    this.scrollbarHoverOpacity = 0.9,

    // 노드 스타일 기본값
    this.nodeVerticalPadding = 4.0,
    this.nodeHorizontalPadding = 8.0,
    this.iconSize = 20.0,
    this.iconSpacing = 8.0,
    this.nodeBorderRadius = const BorderRadius.all(Radius.circular(4.0)),
    this.nodeHoverColor,
    this.nodeSelectedColor,
    this.nodeDisabledColor,
    this.nodeMinHeight = 32.0,

    // 아이콘 색상 기본값
    this.folderColor = const Color(0xFFFFB300),
    this.folderExpandedColor = const Color(0xFFFFA000),
    this.nodeColor = const Color(0xFF1976D2),
    this.nodeExpandedColor = const Color(0xFF1565C0),
    this.accountColor = const Color(0xFF388E3C),
    this.arrowColor = const Color(0xFF757575),
    this.disabledIconColor = const Color(0xFFBDBDBD),

    // 레이아웃 기본값
    this.indentSize = 24.0,
    this.nodeSpacing = 4.0,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),

    // 텍스트 스타일 기본값
    this.folderTextStyle = const TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 14,
    ),
    this.nodeTextStyle = const TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 14,
    ),
    this.accountTextStyle = const TextStyle(
      fontSize: 14,
    ),
    this.disabledTextStyle = const TextStyle(
      fontSize: 14,
      color: Color(0xFF9E9E9E),
    ),
    this.selectedTextStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),

    // 애니메이션 설정
    this.expansionAnimationDuration = const Duration(milliseconds: 200),
    this.hoverAnimationDuration = const Duration(milliseconds: 150),
    this.expansionCurve = Curves.easeInOut,

    // 상호작용 설정
    this.enableHoverEffects = true,
    this.enableRippleEffects = true,
    this.rippleColor,
  });

  /// 기본 테마 생성
  factory TreeViewThemeData.defaultTheme() {
    return const TreeViewThemeData();
  }

  /// 다크 테마 생성
  factory TreeViewThemeData.darkTheme() {
    return const TreeViewThemeData(
      backgroundColor: Color(0xFF121212),
      borderColor: Color(0xFF333333),
      nodeHoverColor: Color(0xFF2C2C2C),
      nodeSelectedColor: Color(0xFF1976D2),
      folderColor: Color(0xFFFFCA28),
      folderExpandedColor: Color(0xFFFFB300),
      nodeColor: Color(0xFF64B5F6),
      nodeExpandedColor: Color(0xFF42A5F5),
      accountColor: Color(0xFF81C784),
      arrowColor: Color(0xFFBDBDBD),
      folderTextStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: Colors.white,
      ),
      nodeTextStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: Colors.white,
      ),
      accountTextStyle: TextStyle(
        fontSize: 14,
        color: Colors.white,
      ),
      scrollbarColor: Color(0xFF757575),
      scrollbarTrackColor: Color(0x1AFFFFFF),
    );
  }

  /// 컴팩트 테마 생성
  factory TreeViewThemeData.compactTheme() {
    return const TreeViewThemeData(
      nodeVerticalPadding: 2.0,
      nodeHorizontalPadding: 4.0,
      iconSize: 16.0,
      iconSpacing: 6.0,
      indentSize: 20.0,
      nodeSpacing: 2.0,
      nodeMinHeight: 24.0,
      folderTextStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      nodeTextStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      accountTextStyle: TextStyle(
        fontSize: 12,
      ),
    );
  }

  TreeViewThemeData copyWith({
    bool? showVerticalScrollbar,
    bool? showHorizontalScrollbar,
    double? scrollbarWidth,
    Color? scrollbarColor,
    Color? scrollbarTrackColor,
    bool? scrollbarHoverOnly,
    double? scrollbarOpacity,
    double? scrollbarHoverOpacity,
    double? nodeVerticalPadding,
    double? nodeHorizontalPadding,
    double? iconSize,
    double? iconSpacing,
    BorderRadius? nodeBorderRadius,
    Color? nodeHoverColor,
    Color? nodeSelectedColor,
    Color? nodeDisabledColor,
    double? nodeMinHeight,
    Color? folderColor,
    Color? folderExpandedColor,
    Color? nodeColor,
    Color? nodeExpandedColor,
    Color? accountColor,
    Color? arrowColor,
    Color? disabledIconColor,
    double? indentSize,
    double? nodeSpacing,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    BorderRadius? borderRadius,
    TextStyle? folderTextStyle,
    TextStyle? nodeTextStyle,
    TextStyle? accountTextStyle,
    TextStyle? disabledTextStyle,
    TextStyle? selectedTextStyle,
    Duration? expansionAnimationDuration,
    Duration? hoverAnimationDuration,
    Curve? expansionCurve,
    bool? enableHoverEffects,
    bool? enableRippleEffects,
    Color? rippleColor,
  }) {
    return TreeViewThemeData(
      showVerticalScrollbar:
          showVerticalScrollbar ?? this.showVerticalScrollbar,
      showHorizontalScrollbar:
          showHorizontalScrollbar ?? this.showHorizontalScrollbar,
      scrollbarWidth: scrollbarWidth ?? this.scrollbarWidth,
      scrollbarColor: scrollbarColor ?? this.scrollbarColor,
      scrollbarTrackColor: scrollbarTrackColor ?? this.scrollbarTrackColor,
      scrollbarHoverOnly: scrollbarHoverOnly ?? this.scrollbarHoverOnly,
      scrollbarOpacity: scrollbarOpacity ?? this.scrollbarOpacity,
      scrollbarHoverOpacity:
          scrollbarHoverOpacity ?? this.scrollbarHoverOpacity,
      nodeVerticalPadding: nodeVerticalPadding ?? this.nodeVerticalPadding,
      nodeHorizontalPadding:
          nodeHorizontalPadding ?? this.nodeHorizontalPadding,
      iconSize: iconSize ?? this.iconSize,
      iconSpacing: iconSpacing ?? this.iconSpacing,
      nodeBorderRadius: nodeBorderRadius ?? this.nodeBorderRadius,
      nodeHoverColor: nodeHoverColor ?? this.nodeHoverColor,
      nodeSelectedColor: nodeSelectedColor ?? this.nodeSelectedColor,
      nodeDisabledColor: nodeDisabledColor ?? this.nodeDisabledColor,
      nodeMinHeight: nodeMinHeight ?? this.nodeMinHeight,
      folderColor: folderColor ?? this.folderColor,
      folderExpandedColor: folderExpandedColor ?? this.folderExpandedColor,
      nodeColor: nodeColor ?? this.nodeColor,
      nodeExpandedColor: nodeExpandedColor ?? this.nodeExpandedColor,
      accountColor: accountColor ?? this.accountColor,
      arrowColor: arrowColor ?? this.arrowColor,
      disabledIconColor: disabledIconColor ?? this.disabledIconColor,
      indentSize: indentSize ?? this.indentSize,
      nodeSpacing: nodeSpacing ?? this.nodeSpacing,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      folderTextStyle: folderTextStyle ?? this.folderTextStyle,
      nodeTextStyle: nodeTextStyle ?? this.nodeTextStyle,
      accountTextStyle: accountTextStyle ?? this.accountTextStyle,
      disabledTextStyle: disabledTextStyle ?? this.disabledTextStyle,
      selectedTextStyle: selectedTextStyle ?? this.selectedTextStyle,
      expansionAnimationDuration:
          expansionAnimationDuration ?? this.expansionAnimationDuration,
      hoverAnimationDuration:
          hoverAnimationDuration ?? this.hoverAnimationDuration,
      expansionCurve: expansionCurve ?? this.expansionCurve,
      enableHoverEffects: enableHoverEffects ?? this.enableHoverEffects,
      enableRippleEffects: enableRippleEffects ?? this.enableRippleEffects,
      rippleColor: rippleColor ?? this.rippleColor,
    );
  }

  // 색상 계산 헬퍼들
  Color getEffectiveNodeHoverColor(BuildContext context) {
    return nodeHoverColor ?? Theme.of(context).hoverColor;
  }

  Color getEffectiveNodeSelectedColor(BuildContext context) {
    return nodeSelectedColor ?? Theme.of(context).primaryColor.withOpacity(0.1);
  }

  Color getEffectiveNodeDisabledColor(BuildContext context) {
    return nodeDisabledColor ??
        Theme.of(context).disabledColor.withOpacity(0.1);
  }

  Color getEffectiveRippleColor(BuildContext context) {
    return rippleColor ?? Theme.of(context).splashColor;
  }

  Color getEffectiveBorderColor(BuildContext context) {
    return borderColor ?? Theme.of(context).dividerColor;
  }
}
