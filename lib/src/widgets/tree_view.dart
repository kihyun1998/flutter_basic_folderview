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
  final Function(TreeNode)? onNodeTap;
  final Function(TreeNode)? onNodeDoubleClick;
  final Function(TreeNode)? onNodeRightClick;
  final TreeViewThemeData? theme;
  final String? selectedNodeId;
  final Function(String?)? onSelectionChanged;

  const TreeView({
    super.key,
    required this.rootNodes,
    this.onAccountDoubleClick,
    this.onAccountRightClick,
    this.onNodeTap,
    this.onNodeDoubleClick,
    this.onNodeRightClick,
    this.theme,
    this.selectedNodeId,
    this.onSelectionChanged,
  });

  @override
  State<TreeView> createState() => _TreeViewState();
}

class _TreeViewState extends State<TreeView> with TickerProviderStateMixin {
  final Map<String, bool> _expandedNodes = {};
  final Map<String, AnimationController> _expansionControllers = {};
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

  @override
  void dispose() {
    // 모든 애니메이션 컨트롤러 dispose
    for (var controller in _expansionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeExpandedStates(List<TreeNode> nodes) {
    for (var node in nodes) {
      if (node is Folder || node is Node) {
        // 노드의 초기 확장 상태를 TreeNodeState에서 가져와서 적용
        _expandedNodes[node.id] ??= node.data.isExpanded;

        // 애니메이션 컨트롤러 생성
        if (!_expansionControllers.containsKey(node.id)) {
          final controller = AnimationController(
            duration: _currentTheme.expansionAnimationDuration,
            vsync: this,
          );
          if (_expandedNodes[node.id] ?? false) {
            controller.value = 1.0;
          }
          _expansionControllers[node.id] = controller;
        }

        if (node.children.isNotEmpty) {
          _initializeExpandedStates(node.children.cast<TreeNode>());
        }
      }
    }
  }

  void _toggleExpansion(String nodeId) {
    setState(() {
      final isExpanded = _expandedNodes[nodeId] ?? false;
      _expandedNodes[nodeId] = !isExpanded;

      final controller = _expansionControllers[nodeId];
      if (controller != null) {
        if (!isExpanded) {
          controller.forward();
        } else {
          controller.reverse();
        }
      }
    });
  }

  void _handleNodeSelection(TreeNode node) {
    if (node.data.isEnabled) {
      widget.onSelectionChanged?.call(node.id);
      widget.onNodeTap?.call(node);
    }
  }

  /// 플랫화된 노드 리스트 생성 (현재 표시되는 노드들만)
  List<_FlattenedNode> _getFlattenedNodes() {
    final List<_FlattenedNode> flattened = [];

    void traverse(List<TreeNode> nodes, int depth) {
      for (var node in nodes) {
        if (node.data.isVisible) {
          flattened.add(_FlattenedNode(node: node, depth: depth));

          if ((node is Folder || node is Node) &&
              node.children.isNotEmpty &&
              (_expandedNodes[node.id] ?? false)) {
            traverse(node.children.cast<TreeNode>(), depth + 1);
          }
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
    return flattenedNodes.length * _currentTheme.nodeMinHeight;
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
              color: theme.getEffectiveBorderColor(context),
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

                      // 세로 스크롤바
                      if (theme.showVerticalScrollbar && needsVerticalScroll)
                        _buildVerticalScrollbar(
                          verticalScrollbarController,
                          availableHeight,
                          contentHeight,
                          needsHorizontalScroll,
                          theme,
                        ),

                      // 가로 스크롤바
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

  /// 개선된 세로 스크롤바
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
        opacity: theme.scrollbarHoverOnly
            ? (_isHovered ? theme.scrollbarHoverOpacity : 0.0)
            : theme.scrollbarOpacity,
        duration: theme.hoverAnimationDuration,
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

  /// 개선된 가로 스크롤바
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
        opacity: theme.scrollbarHoverOnly
            ? (_isHovered ? theme.scrollbarHoverOpacity : 0.0)
            : theme.scrollbarOpacity,
        duration: theme.hoverAnimationDuration,
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

  /// 노드 상태에 따른 색상 계산
  Color? _getNodeBackgroundColor(TreeNode node) {
    final theme = _currentTheme;

    if (!node.data.isEnabled) {
      return theme.getEffectiveNodeDisabledColor(context);
    }

    if (widget.selectedNodeId == node.id) {
      return theme.getEffectiveNodeSelectedColor(context);
    }

    return null;
  }

  /// 노드 상태에 따른 텍스트 스타일 계산
  TextStyle _getNodeTextStyle(TreeNode node, TextStyle baseStyle) {
    final theme = _currentTheme;

    if (!node.data.isEnabled) {
      return theme.disabledTextStyle;
    }

    if (widget.selectedNodeId == node.id) {
      return theme.selectedTextStyle;
    }

    return baseStyle;
  }

  /// 확장 가능한 아이템 레이아웃 (완전히 테마 적용)
  Widget _buildExpandableItemLayout({
    required TreeNode node,
    required int depth,
    required Widget arrowIcon,
    required Widget mainIcon,
    required String text,
    required TextStyle textStyle,
    VoidCallback? onTap,
  }) {
    final theme = _currentTheme;
    final indent = theme.indentSize * depth;
    final isSelected = widget.selectedNodeId == node.id;
    final isEnabled = node.data.isEnabled;

    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Container(
        constraints: BoxConstraints(minHeight: theme.nodeMinHeight),
        padding: EdgeInsets.symmetric(
          horizontal: theme.nodeHorizontalPadding,
          vertical: theme.nodeVerticalPadding,
        ),
        decoration: BoxDecoration(
          color: _getNodeBackgroundColor(node),
          borderRadius: theme.nodeBorderRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20.0,
              child: arrowIcon,
            ),
            Opacity(
              opacity: isEnabled ? 1.0 : 0.5,
              child: CustomInkwell(
                onTap: isEnabled
                    ? () {
                        _handleNodeSelection(node);
                        onTap?.call();
                      }
                    : null,
                borderRadius: theme.nodeBorderRadius,
                hoverColor: theme.enableHoverEffects
                    ? theme.getEffectiveNodeHoverColor(context)
                    : null,
                splashColor: theme.enableRippleEffects
                    ? theme.getEffectiveRippleColor(context)
                    : null,
                child: AnimatedContainer(
                  duration: theme.hoverAnimationDuration,
                  padding: EdgeInsets.symmetric(
                    vertical: theme.nodeSpacing,
                    horizontal: 8.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      mainIcon,
                      SizedBox(width: theme.iconSpacing),
                      Text(
                        text,
                        style: _getNodeTextStyle(node, textStyle),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Account 아이템 레이아웃 (완전히 테마 적용)
  Widget _buildAccountItemLayout({
    required TreeNode node,
    required int depth,
    required Widget mainIcon,
    required String text,
    required TextStyle textStyle,
    VoidCallback? onDoubleTap,
    VoidCallback? onRightClick,
  }) {
    final theme = _currentTheme;
    final indent = theme.indentSize * depth;
    final isEnabled = node.data.isEnabled;

    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Container(
        constraints: BoxConstraints(minHeight: theme.nodeMinHeight),
        padding: EdgeInsets.symmetric(
          horizontal: theme.nodeHorizontalPadding,
          vertical: theme.nodeVerticalPadding,
        ),
        decoration: BoxDecoration(
          color: _getNodeBackgroundColor(node),
          borderRadius: theme.nodeBorderRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 20.0),
            Opacity(
              opacity: isEnabled ? 1.0 : 0.5,
              child: CustomInkwell(
                onDoubleTap: isEnabled
                    ? () {
                        if (node is Account) {
                          widget.onAccountDoubleClick?.call(node);
                        }
                        onDoubleTap?.call();
                      }
                    : null,
                onRightClick: isEnabled
                    ? () {
                        if (node is Account) {
                          widget.onAccountRightClick?.call(node);
                        }
                        onRightClick?.call();
                      }
                    : null,
                onTap: isEnabled ? () => _handleNodeSelection(node) : null,
                borderRadius: theme.nodeBorderRadius,
                hoverColor: theme.enableHoverEffects
                    ? theme.getEffectiveNodeHoverColor(context)
                    : null,
                splashColor: theme.enableRippleEffects
                    ? theme.getEffectiveRippleColor(context)
                    : null,
                child: AnimatedContainer(
                  duration: theme.hoverAnimationDuration,
                  padding: EdgeInsets.symmetric(
                    vertical: theme.nodeSpacing,
                    horizontal: 8.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      mainIcon,
                      SizedBox(width: theme.iconSpacing),
                      Text(
                        text,
                        style: _getNodeTextStyle(node, textStyle),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 폴더 노드 빌드 (완전히 테마 적용)
  Widget _buildFolderNode(Folder folder, int depth) {
    final theme = _currentTheme;
    final isExpanded = _expandedNodes[folder.id] ?? false;
    final controller = _expansionControllers[folder.id];

    return _buildExpandableItemLayout(
      node: folder,
      depth: depth,
      arrowIcon: controller != null
          ? RotationTransition(
              turns: Tween(begin: 0.0, end: 0.25).animate(
                CurvedAnimation(
                  parent: controller,
                  curve: theme.expansionCurve,
                ),
              ),
              child: Icon(
                Icons.keyboard_arrow_right,
                size: 16,
                color: folder.data.isEnabled
                    ? theme.arrowColor
                    : theme.disabledIconColor,
              ),
            )
          : Icon(
              Icons.keyboard_arrow_right,
              size: 16,
              color: folder.data.isEnabled
                  ? theme.arrowColor
                  : theme.disabledIconColor,
            ),
      mainIcon: Icon(
        isExpanded ? Icons.folder_open : Icons.folder,
        color: folder.data.isEnabled
            ? (isExpanded ? theme.folderExpandedColor : theme.folderColor)
            : theme.disabledIconColor,
        size: theme.iconSize,
      ),
      text: folder.name,
      textStyle: theme.folderTextStyle,
      onTap: folder.data.isEnabled ? () => _toggleExpansion(folder.id) : null,
    );
  }

  /// 노드 아이템 빌드 (완전히 테마 적용)
  Widget _buildNodeItem(Node node, int depth) {
    final theme = _currentTheme;
    final isExpanded = _expandedNodes[node.id] ?? false;
    final controller = _expansionControllers[node.id];

    return _buildExpandableItemLayout(
      node: node,
      depth: depth,
      arrowIcon: controller != null
          ? RotationTransition(
              turns: Tween(begin: 0.0, end: 0.25).animate(
                CurvedAnimation(
                  parent: controller,
                  curve: theme.expansionCurve,
                ),
              ),
              child: Icon(
                Icons.keyboard_arrow_right,
                size: 16,
                color: node.data.isEnabled
                    ? theme.arrowColor
                    : theme.disabledIconColor,
              ),
            )
          : Icon(
              Icons.keyboard_arrow_right,
              size: 16,
              color: node.data.isEnabled
                  ? theme.arrowColor
                  : theme.disabledIconColor,
            ),
      mainIcon: Icon(
        isExpanded ? Icons.dns : Icons.storage,
        color: node.data.isEnabled
            ? (isExpanded ? theme.nodeExpandedColor : theme.nodeColor)
            : theme.disabledIconColor,
        size: theme.iconSize,
      ),
      text: node.name,
      textStyle: theme.nodeTextStyle,
      onTap: node.data.isEnabled ? () => _toggleExpansion(node.id) : null,
    );
  }

  /// Account 아이템 빌드 (완전히 테마 적용)
  Widget _buildAccountItem(Account account, int depth) {
    final theme = _currentTheme;

    return _buildAccountItemLayout(
      node: account,
      depth: depth,
      mainIcon: Icon(
        Icons.account_circle,
        color: account.data.isEnabled
            ? theme.accountColor
            : theme.disabledIconColor,
        size: theme.iconSize,
      ),
      text: account.name,
      textStyle: theme.accountTextStyle,
      onDoubleTap: () => widget.onAccountDoubleClick?.call(account),
      onRightClick: () => widget.onAccountRightClick?.call(account),
    );
  }
}
