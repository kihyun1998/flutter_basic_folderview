import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/tree_node.dart';
import '../models/tree_view_theme.dart';
import '../utils/tree_view_width_calculator.dart';
import 'account_widget.dart';
import 'folder_widget.dart';
import 'node_widget.dart';
import 'synced_scroll_controllers.dart';

/// TreeView에서 사용하는 플랫화된 노드 정보
class _FlattenedNode {
  final TreeNode node;
  final int depth;

  _FlattenedNode({required this.node, required this.depth});
}

class TreeView extends StatefulWidget {
  final List<TreeNode> rootNodes;
  final Set<String> expandedNodeIds;
  final Function(String nodeId, bool isExpanded)? onExpansionChanged;
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
    required this.expandedNodeIds,
    this.onExpansionChanged,
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
  final Map<String, AnimationController> _expansionControllers = {};
  late TreeViewWidthCalculator _widthCalculator;
  bool _isHovered = false;

  TreeViewThemeData get _currentTheme =>
      widget.theme ?? TreeViewThemeData.defaultTheme();

  @override
  void initState() {
    super.initState();
    _widthCalculator = TreeViewWidthCalculator(theme: _currentTheme);
    _initializeAnimationControllers();
  }

  @override
  void didUpdateWidget(TreeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.theme != oldWidget.theme) {
      _widthCalculator = TreeViewWidthCalculator(theme: _currentTheme);
    }

    // 확장 상태가 변경되었을 때 애니메이션 동기화
    if (widget.expandedNodeIds != oldWidget.expandedNodeIds) {
      _updateAnimationControllers();
    }

    if (widget.rootNodes != oldWidget.rootNodes) {
      _initializeAnimationControllers();
    }
  }

  @override
  void dispose() {
    for (var controller in _expansionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeAnimationControllers() {
    // 기존 컨트롤러들 정리
    for (var controller in _expansionControllers.values) {
      controller.dispose();
    }
    _expansionControllers.clear();

    // 모든 확장 가능한 노드에 대해 컨트롤러 생성
    _createControllersForNodes(widget.rootNodes);
  }

  void _createControllersForNodes(List<TreeNode> nodes) {
    for (var node in nodes) {
      if (node is Folder || node is Node) {
        final controller = AnimationController(
          duration: _currentTheme.expansionAnimationDuration,
          vsync: this,
        );

        // 현재 확장 상태에 맞게 초기값 설정
        if (widget.expandedNodeIds.contains(node.id)) {
          controller.value = 1.0;
        }

        _expansionControllers[node.id] = controller;

        if (node.children.isNotEmpty) {
          _createControllersForNodes(node.children.cast<TreeNode>());
        }
      }
    }
  }

  void _updateAnimationControllers() {
    for (var entry in _expansionControllers.entries) {
      final nodeId = entry.key;
      final controller = entry.value;
      final shouldBeExpanded = widget.expandedNodeIds.contains(nodeId);

      if (shouldBeExpanded && controller.value == 0.0) {
        controller.forward();
      } else if (!shouldBeExpanded && controller.value == 1.0) {
        controller.reverse();
      }
    }
  }

  void _handleExpansionToggle(String nodeId) {
    final isCurrentlyExpanded = widget.expandedNodeIds.contains(nodeId);
    widget.onExpansionChanged?.call(nodeId, !isCurrentlyExpanded);
  }

  void _handleNodeSelection(TreeNode node) {
    if (node.data.isEnabled) {
      widget.onSelectionChanged?.call(node.id);
      widget.onNodeTap?.call(node);
    }
  }

  List<_FlattenedNode> _getFlattenedNodes() {
    final List<_FlattenedNode> flattened = [];

    void traverse(List<TreeNode> nodes, int depth) {
      for (var node in nodes) {
        if (node.data.isVisible) {
          flattened.add(_FlattenedNode(node: node, depth: depth));

          if ((node is Folder || node is Node) &&
              node.children.isNotEmpty &&
              widget.expandedNodeIds.contains(node.id)) {
            traverse(node.children.cast<TreeNode>(), depth + 1);
          }
        }
      }
    }

    traverse(widget.rootNodes, 0);
    return flattened;
  }

  double _calculateCurrentContentWidth() {
    // expandedNodeIds를 Map 형태로 변환
    final expandedNodesMap = <String, bool>{};
    for (var nodeId in widget.expandedNodeIds) {
      expandedNodesMap[nodeId] = true;
    }

    return _widthCalculator.calculateVisibleContentWidth(
      widget.rootNodes,
      expandedNodesMap,
    );
  }

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

        final double contentWidth = math.max(
          _calculateCurrentContentWidth(),
          availableWidth,
        );
        final double contentHeight = _calculateContentHeight();

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
                      if (theme.showVerticalScrollbar && needsVerticalScroll)
                        _buildVerticalScrollbar(
                          verticalScrollbarController,
                          availableHeight,
                          contentHeight,
                          needsHorizontalScroll,
                          theme,
                        ),
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

  Widget _buildTreeNode(TreeNode node, int depth) {
    final isSelected = widget.selectedNodeId == node.id;
    final isExpanded = widget.expandedNodeIds.contains(node.id);

    if (node is Folder) {
      return FolderWidget(
        folder: node,
        depth: depth,
        theme: _currentTheme,
        isExpanded: isExpanded,
        isSelected: isSelected,
        expansionController: _expansionControllers[node.id],
        onSelection: () => _handleNodeSelection(node),
        onTap: () => _handleExpansionToggle(node.id),
      );
    } else if (node is Node) {
      return NodeWidget(
        node: node,
        depth: depth,
        theme: _currentTheme,
        isExpanded: isExpanded,
        isSelected: isSelected,
        expansionController: _expansionControllers[node.id],
        onSelection: () => _handleNodeSelection(node),
        onTap: () => _handleExpansionToggle(node.id),
      );
    } else if (node is Account) {
      return AccountWidget(
        account: node,
        depth: depth,
        theme: _currentTheme,
        isSelected: isSelected,
        onSelection: () => _handleNodeSelection(node),
        onDoubleClick: () => widget.onAccountDoubleClick?.call(node),
        onRightClick: () => widget.onAccountRightClick?.call(node),
      );
    }

    return const SizedBox.shrink();
  }

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
}
