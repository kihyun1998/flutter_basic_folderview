import 'package:flutter/material.dart';

/// 간소화된 TreeView 테마 데이터
class TreeViewThemeData {
  // 스크롤바 설정
  final bool showVerticalScrollbar;
  final bool showHorizontalScrollbar;
  final double scrollbarWidth;
  final Color scrollbarColor;
  final Color scrollbarTrackColor;
  final bool scrollbarHoverOnly;

  // 노드 스타일
  final double nodeVerticalPadding;
  final double nodeHorizontalPadding;
  final double iconSize;
  final double iconSpacing;
  final BorderRadius nodeBorderRadius;
  final Color? nodeHoverColor;

  // 아이콘 색상
  final Color folderColor;
  final Color nodeColor;
  final Color accountColor;
  final Color arrowColor;

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

  const TreeViewThemeData({
    // 스크롤바 기본값
    this.showVerticalScrollbar = true,
    this.showHorizontalScrollbar = true,
    this.scrollbarWidth = 12.0,
    this.scrollbarColor = const Color(0xFF757575),
    this.scrollbarTrackColor = const Color(0x1A000000),
    this.scrollbarHoverOnly = true,

    // 노드 스타일 기본값
    this.nodeVerticalPadding = 4.0,
    this.nodeHorizontalPadding = 8.0,
    this.iconSize = 20.0,
    this.iconSpacing = 8.0,
    this.nodeBorderRadius = const BorderRadius.all(Radius.circular(4.0)),
    this.nodeHoverColor,

    // 아이콘 색상 기본값
    this.folderColor = const Color(0xFFFFB300),
    this.nodeColor = const Color(0xFF1976D2),
    this.accountColor = const Color(0xFF388E3C),
    this.arrowColor = const Color(0xFF757575),

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
  });

  /// 기본 테마 생성
  factory TreeViewThemeData.defaultTheme() {
    return const TreeViewThemeData();
  }

  TreeViewThemeData copyWith({
    bool? showVerticalScrollbar,
    bool? showHorizontalScrollbar,
    double? scrollbarWidth,
    Color? scrollbarColor,
    Color? scrollbarTrackColor,
    bool? scrollbarHoverOnly,
    double? nodeVerticalPadding,
    double? nodeHorizontalPadding,
    double? iconSize,
    double? iconSpacing,
    BorderRadius? nodeBorderRadius,
    Color? nodeHoverColor,
    Color? folderColor,
    Color? nodeColor,
    Color? accountColor,
    Color? arrowColor,
    double? indentSize,
    double? nodeSpacing,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    BorderRadius? borderRadius,
    TextStyle? folderTextStyle,
    TextStyle? nodeTextStyle,
    TextStyle? accountTextStyle,
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
      nodeVerticalPadding: nodeVerticalPadding ?? this.nodeVerticalPadding,
      nodeHorizontalPadding:
          nodeHorizontalPadding ?? this.nodeHorizontalPadding,
      iconSize: iconSize ?? this.iconSize,
      iconSpacing: iconSpacing ?? this.iconSpacing,
      nodeBorderRadius: nodeBorderRadius ?? this.nodeBorderRadius,
      nodeHoverColor: nodeHoverColor ?? this.nodeHoverColor,
      folderColor: folderColor ?? this.folderColor,
      nodeColor: nodeColor ?? this.nodeColor,
      accountColor: accountColor ?? this.accountColor,
      arrowColor: arrowColor ?? this.arrowColor,
      indentSize: indentSize ?? this.indentSize,
      nodeSpacing: nodeSpacing ?? this.nodeSpacing,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      folderTextStyle: folderTextStyle ?? this.folderTextStyle,
      nodeTextStyle: nodeTextStyle ?? this.nodeTextStyle,
      accountTextStyle: accountTextStyle ?? this.accountTextStyle,
    );
  }
}
