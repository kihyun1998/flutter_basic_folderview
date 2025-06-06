import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/tree_node.dart';
import '../models/tree_view_theme.dart';
import '../utils/tree_view_width_calculator.dart';
import 'custom_inkwell.dart';
import 'synced_scroll_controllers.dart';

/// TreeView에서 사용하는 플랫화된 노드 정보
class _FlattenedNode {
  final TreeNode node;
  final int depth;

  _FlattenedNode({required this.node, required this.depth});
}

class TreeView extends StatefulWidget {
  final List<TreeNode> rootNodes;
  final Function(Account)? onAccountDoubleClick;
  final Function(Account)? onAccountRightClick;
  final TreeViewThemeData? theme;

  const TreeView({
    super.key,
    required this.rootNodes,
    this.onAccountDoubleClick,
    this.onAccountRightClick,
    this.theme,
  });

  @override
  State<TreeView> createState() => _TreeViewState();
}

class _TreeViewState extends State<TreeView> {
  final Map<String, bool> _expandedNodes = {};
  late TreeViewWidthCalculator _widthCalculator;
  bool _isHovered = false;

  /// 현재 사용할 테마
  TreeViewThemeData get _currentTheme =>
      widget.theme ?? TreeViewThemeData.defaultTheme();

  @override
  void initState() {
    super.initState();
    _initializeExpandedStates(widget.rootNodes);
    _widthCalculator = TreeViewWidthCalculator(theme: _currentTheme);
  }

  @override
  void didUpdateWidget(TreeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.theme != oldWidget.theme) {
      _widthCalculator = TreeViewWidthCalculator(theme: _currentTheme);
    }
    if (widget.rootNodes != oldWidget.rootNodes) {
      _initializeExpandedStates(widget.rootNodes);
    }
  }

  void _initializeExpandedStates(List<TreeNode> nodes) {
    for (var node in nodes) {
      if (node is Folder || node is Node) {
        _expandedNodes[node.id] ??= false;
        if (node.children.isNotEmpty) {
          _initializeExpandedStates(node.children.cast<TreeNode>());
        }
      }
    }
  }

  void _toggleExpansion(String nodeId) {
    setState(() {
      _expandedNodes[nodeId] = !(_expandedNodes[nodeId] ?? false);
    });
  }

  /// 플랫화된 노드 리스트 생성 (현재 표시되는 노드들만)
  List<_FlattenedNode> _getFlattenedNodes() {
    final List<_FlattenedNode> flattened = [];

    void traverse(List<TreeNode> nodes, int depth) {
      for (var node in nodes) {
        flattened.add(_FlattenedNode(node: node, depth: depth));

        if ((node is Folder || node is Node) &&
            node.children.isNotEmpty &&
            (_expandedNodes[node.id] ?? false)) {
          traverse(node.children.cast<TreeNode>(), depth + 1);
        }
      }
    }

    traverse(widget.rootNodes, 0);
    return flattened;
  }

  /// 현재 표시되는 콘텐츠의 너비 계산
  double _calculateCurrentContentWidth() {
    return _widthCalculator.calculateVisibleContentWidth(
      widget.rootNodes,
      _expandedNodes,
    );
  }

  /// 전체 콘텐츠 높이 계산
  double _calculateContentHeight() {
    final flattenedNodes = _getFlattenedNodes();
    return flattenedNodes.length * _getNodeHeight();
  }

  /// 개별 노드의 높이
  double _getNodeHeight() {
    return _currentTheme.nodeVerticalPadding * 2 +
        _currentTheme.nodeSpacing * 2 +
        _currentTheme.iconSize;
  }

  @override
  Widget build(BuildContext context) {
    final theme = _currentTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableHeight = constraints.maxHeight;
        final double availableWidth = constraints.maxWidth;

        // 콘텐츠 크기 계산
        final double contentWidth = math.max(
          _calculateCurrentContentWidth(),
          availableWidth,
        );
        final double contentHeight = _calculateContentHeight();

        // 스크롤 필요 여부
        final bool needsVerticalScroll = contentHeight > availableHeight;
        final bool needsHorizontalScroll = contentWidth > availableWidth;

        return Container(
          decoration: BoxDecoration(
            color: theme.backgroundColor,
            border: Border.all(
              color: theme.borderColor ?? Colors.grey.shade300,
              width: theme.borderWidth,
            ),
            borderRadius: theme.borderRadius,
          ),
          child: SyncedScrollControllers(
            builder: (
              context,
              verticalController,
              verticalScrollbarController,
              horizontalController,
              horizontalScrollbarController,
            ) {
              return MouseRegion(
                onEnter: (_) => setState(() => _isHovered = true),
                onExit: (_) => setState(() => _isHovered = false),
                child: ScrollConfiguration(
                  // Flutter 기본 스크롤바 숨기기
                  behavior: ScrollConfiguration.of(context).copyWith(
                    scrollbars: false,
                  ),
                  child: Stack(
                    children: [
                      // 메인 스크롤 영역
                      SingleChildScrollView(
                        controller: horizontalController,
                        scrollDirection: Axis.horizontal,
                        physics: const ClampingScrollPhysics(),
                        child: SizedBox(
                          width: contentWidth,
                          child: ListView.builder(
                            controller: verticalController,
                            itemCount: _getFlattenedNodes().length,
                            itemBuilder: (context, index) {
                              final flattenedNode = _getFlattenedNodes()[index];
                              return _buildTreeNode(
                                flattenedNode.node,
                                flattenedNode.depth,
                              );
                            },
                          ),
                        ),
                      ),

                      // 세로 스크롤바 (우측 오버레이)
                      if (theme.showVerticalScrollbar && needsVerticalScroll)
                        _buildVerticalScrollbar(
                          verticalScrollbarController,
                          availableHeight,
                          contentHeight,
                          needsHorizontalScroll,
                          theme,
                        ),

                      // 가로 스크롤바 (하단 오버레이)
                      if (theme.showHorizontalScrollbar &&
                          needsHorizontalScroll)
                        _buildHorizontalScrollbar(
                          horizontalScrollbarController,
                          availableWidth,
                          contentWidth,
                          theme,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// 세로 스크롤바 위젯 생성
  Widget _buildVerticalScrollbar(
    ScrollController controller,
    double availableHeight,
    double contentHeight,
    bool needsHorizontalScroll,
    TreeViewThemeData theme,
  ) {
    return Positioned(
      top: 0,
      right: 0,
      bottom: needsHorizontalScroll ? theme.scrollbarWidth : 0,
      child: AnimatedOpacity(
        opacity: theme.scrollbarHoverOnly ? (_isHovered ? 0.7 : 0.0) : 0.7,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: theme.scrollbarWidth,
          decoration: BoxDecoration(
            color: theme.scrollbarTrackColor,
            borderRadius: BorderRadius.circular(theme.scrollbarWidth / 2),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              scrollbarTheme: ScrollbarThemeData(
                thumbColor: WidgetStateProperty.all(theme.scrollbarColor),
                trackColor: WidgetStateProperty.all(Colors.transparent),
                radius: Radius.circular(theme.scrollbarWidth / 2),
                thickness: WidgetStateProperty.all(theme.scrollbarWidth - 4),
              ),
            ),
            child: Scrollbar(
              controller: controller,
              thumbVisibility: true,
              trackVisibility: false,
              child: SingleChildScrollView(
                controller: controller,
                scrollDirection: Axis.vertical,
                child: SizedBox(
                  height: contentHeight,
                  width: theme.scrollbarWidth,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 가로 스크롤바 위젯 생성
  Widget _buildHorizontalScrollbar(
    ScrollController controller,
    double availableWidth,
    double contentWidth,
    TreeViewThemeData theme,
  ) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedOpacity(
        opacity: theme.scrollbarHoverOnly ? (_isHovered ? 0.7 : 0.0) : 0.7,
        duration: const Duration(milliseconds: 200),
        child: Container(
          height: theme.scrollbarWidth,
          decoration: BoxDecoration(
            color: theme.scrollbarTrackColor,
            borderRadius: BorderRadius.circular(theme.scrollbarWidth / 2),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              scrollbarTheme: ScrollbarThemeData(
                thumbColor: WidgetStateProperty.all(theme.scrollbarColor),
                trackColor: WidgetStateProperty.all(Colors.transparent),
                radius: Radius.circular(theme.scrollbarWidth / 2),
                thickness: WidgetStateProperty.all(theme.scrollbarWidth - 4),
              ),
            ),
            child: Scrollbar(
              controller: controller,
              thumbVisibility: true,
              trackVisibility: false,
              child: SingleChildScrollView(
                controller: controller,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: contentWidth,
                  height: theme.scrollbarWidth,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// TreeNode 타입에 따른 위젯 빌드
  Widget _buildTreeNode(TreeNode node, int depth) {
    if (node is Folder) {
      return _buildFolderNode(node, depth);
    } else if (node is Node) {
      return _buildNodeItem(node, depth);
    } else if (node is Account) {
      return _buildAccountItem(node, depth);
    }
    return const SizedBox.shrink();
  }

  /// 확장 가능한 아이템 레이아웃
  Widget _buildExpandableItemLayout({
    required int depth,
    required Widget arrowIcon,
    required Widget mainIcon,
    required String text,
    required TextStyle textStyle,
    VoidCallback? onTap,
  }) {
    final theme = _currentTheme;
    final indent = theme.indentSize * depth;

    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: theme.nodeHorizontalPadding,
          vertical: theme.nodeVerticalPadding,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20.0, // 화살표 아이콘 너비 고정
              child: arrowIcon,
            ),
            CustomInkwell(
              onTap: onTap,
              borderRadius: theme.nodeBorderRadius,
              hoverColor: theme.nodeHoverColor,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: theme.nodeSpacing,
                  horizontal: 8.0, // 콘텐츠 패딩 고정
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    mainIcon,
                    SizedBox(width: theme.iconSpacing),
                    Text(text, style: textStyle),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Account 아이템 레이아웃
  Widget _buildAccountItemLayout({
    required int depth,
    required Widget mainIcon,
    required String text,
    required TextStyle textStyle,
    VoidCallback? onDoubleTap,
    VoidCallback? onRightClick,
  }) {
    final theme = _currentTheme;
    final indent = theme.indentSize * depth;

    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: theme.nodeHorizontalPadding,
          vertical: theme.nodeVerticalPadding,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 20.0), // 화살표 아이콘 공간
            CustomInkwell(
              onDoubleTap: onDoubleTap,
              onRightClick: onRightClick,
              borderRadius: theme.nodeBorderRadius,
              hoverColor: theme.nodeHoverColor,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: theme.nodeSpacing,
                  horizontal: 8.0, // 콘텐츠 패딩 고정
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    mainIcon,
                    SizedBox(width: theme.iconSpacing),
                    Text(text, style: textStyle),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 폴더 노드 빌드
  Widget _buildFolderNode(Folder folder, int depth) {
    final theme = _currentTheme;
    final isExpanded = _expandedNodes[folder.id] ?? false;

    return _buildExpandableItemLayout(
      depth: depth,
      arrowIcon: RotationTransition(
        turns: AlwaysStoppedAnimation(isExpanded ? 0.25 : 0.0),
        child: Icon(
          Icons.keyboard_arrow_right,
          size: 16,
          color: theme.arrowColor,
        ),
      ),
      mainIcon: Icon(
        isExpanded ? Icons.folder_open : Icons.folder,
        color: theme.folderColor,
        size: theme.iconSize,
      ),
      text: folder.name,
      textStyle: theme.folderTextStyle,
      onTap: () => _toggleExpansion(folder.id),
    );
  }

  /// 노드 아이템 빌드
  Widget _buildNodeItem(Node node, int depth) {
    final theme = _currentTheme;
    final isExpanded = _expandedNodes[node.id] ?? false;

    return _buildExpandableItemLayout(
      depth: depth,
      arrowIcon: RotationTransition(
        turns: AlwaysStoppedAnimation(isExpanded ? 0.25 : 0.0),
        child: Icon(
          Icons.keyboard_arrow_right,
          size: 16,
          color: theme.arrowColor,
        ),
      ),
      mainIcon: Icon(
        isExpanded ? Icons.dns : Icons.storage,
        color: theme.nodeColor,
        size: theme.iconSize,
      ),
      text: node.name,
      textStyle: theme.nodeTextStyle,
      onTap: () => _toggleExpansion(node.id),
    );
  }

  /// Account 아이템 빌드
  Widget _buildAccountItem(Account account, int depth) {
    final theme = _currentTheme;

    return _buildAccountItemLayout(
      depth: depth,
      mainIcon: Icon(
        Icons.account_circle,
        color: theme.accountColor,
        size: theme.iconSize,
      ),
      text: account.name,
      textStyle: theme.accountTextStyle,
      onDoubleTap: () => widget.onAccountDoubleClick?.call(account),
      onRightClick: () => widget.onAccountRightClick?.call(account),
    );
  }
}
