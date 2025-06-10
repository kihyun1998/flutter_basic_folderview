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
    for (var controller in _expansionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeExpandedStates(List<TreeNode> nodes) {
    for (var node in nodes) {
      if (node is Folder || node is Node) {
        _expandedNodes[node.id] ??= node.data.isExpanded;

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

  double _calculateCurrentContentWidth() {
    return _widthCalculator.calculateVisibleContentWidth(
      widget.rootNodes,
      _expandedNodes,
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

    if (node is Folder) {
      return FolderWidget(
        folder: node,
        depth: depth,
        theme: _currentTheme,
        isExpanded: _expandedNodes[node.id] ?? false,
        isSelected: isSelected,
        expansionController: _expansionControllers[node.id],
        onSelection: () => _handleNodeSelection(node),
        onTap: () => _toggleExpansion(node.id),
      );
    } else if (node is Node) {
      return NodeWidget(
        node: node,
        depth: depth,
        theme: _currentTheme,
        isExpanded: _expandedNodes[node.id] ?? false,
        isSelected: isSelected,
        expansionController: _expansionControllers[node.id],
        onSelection: () => _handleNodeSelection(node),
        onTap: () => _toggleExpansion(node.id),
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
