import 'package:flutter/material.dart';

import '../models/tree_node.dart';
import '../models/tree_view_theme.dart';
import 'custom_inkwell.dart';

class FolderWidget extends StatelessWidget {
  final Folder folder;
  final int depth;
  final TreeViewThemeData theme;
  final bool isExpanded;
  final bool isSelected;
  final AnimationController? expansionController;
  final VoidCallback? onTap;
  final VoidCallback onSelection;

  const FolderWidget({
    super.key,
    required this.folder,
    required this.depth,
    required this.theme,
    required this.isExpanded,
    required this.isSelected,
    required this.onSelection,
    this.expansionController,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final indent = theme.indentSize * depth;
    final isEnabled = folder.data.isEnabled;

    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Container(
        constraints: BoxConstraints(minHeight: theme.nodeMinHeight),
        padding: EdgeInsets.symmetric(
          horizontal: theme.nodeHorizontalPadding,
          vertical: theme.nodeVerticalPadding,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20.0,
              child: _buildArrowIcon(),
            ),
            Opacity(
              opacity: isEnabled ? 1.0 : 0.5,
              child: CustomInkwell(
                onTap: isEnabled
                    ? () {
                        onSelection();
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
                  decoration: BoxDecoration(
                    color: _getBackgroundColor(context),
                    borderRadius: theme.nodeBorderRadius,
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: theme.nodeSpacing,
                    horizontal: 8.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildFolderIcon(),
                      SizedBox(width: theme.iconSpacing),
                      Text(
                        folder.name,
                        style: _getTextStyle(),
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

  Widget _buildArrowIcon() {
    if (expansionController != null) {
      return RotationTransition(
        turns: Tween(begin: 0.0, end: 0.25).animate(
          CurvedAnimation(
            parent: expansionController!,
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
      );
    }

    return Icon(
      Icons.keyboard_arrow_right,
      size: 16,
      color: folder.data.isEnabled ? theme.arrowColor : theme.disabledIconColor,
    );
  }

  Widget _buildFolderIcon() {
    return Icon(
      isExpanded ? Icons.folder_open : Icons.folder,
      color: folder.data.isEnabled
          ? (isExpanded ? theme.folderExpandedColor : theme.folderColor)
          : theme.disabledIconColor,
      size: theme.iconSize,
    );
  }

  Color? _getBackgroundColor(BuildContext context) {
    if (!folder.data.isEnabled) {
      return theme.getEffectiveNodeDisabledColor(context);
    }

    if (isSelected) {
      return theme.getEffectiveNodeSelectedColor(context);
    }

    return null;
  }

  TextStyle _getTextStyle() {
    if (!folder.data.isEnabled) {
      return theme.disabledTextStyle;
    }

    if (isSelected) {
      return theme.selectedTextStyle;
    }

    return theme.folderTextStyle;
  }
}
