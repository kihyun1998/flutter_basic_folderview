import 'package:flutter/material.dart';

import '../models/tree_node.dart';
import '../models/tree_view_theme.dart';
import 'custom_inkwell.dart';

class AccountWidget extends StatelessWidget {
  final Account account;
  final int depth;
  final TreeViewThemeData theme;
  final bool isSelected;
  final VoidCallback onSelection;
  final VoidCallback? onDoubleClick;
  final VoidCallback? onRightClick;

  const AccountWidget({
    super.key,
    required this.account,
    required this.depth,
    required this.theme,
    required this.isSelected,
    required this.onSelection,
    this.onDoubleClick,
    this.onRightClick,
  });

  @override
  Widget build(BuildContext context) {
    final indent = theme.indentSize * depth;
    final isEnabled = account.data.isEnabled;

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
            const SizedBox(width: 20.0),
            Opacity(
              opacity: isEnabled ? 1.0 : 0.5,
              child: CustomInkwell(
                onDoubleTap: isEnabled ? onDoubleClick : null,
                onRightClick: isEnabled ? onRightClick : null,
                onTap: isEnabled ? onSelection : null,
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
                      _buildAccountIcon(),
                      SizedBox(width: theme.iconSpacing),
                      Text(
                        account.name,
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

  Widget _buildAccountIcon() {
    return Icon(
      Icons.account_circle,
      color:
          account.data.isEnabled ? theme.accountColor : theme.disabledIconColor,
      size: theme.iconSize,
    );
  }

  Color? _getBackgroundColor(BuildContext context) {
    if (!account.data.isEnabled) {
      return theme.getEffectiveNodeDisabledColor(context);
    }

    if (isSelected) {
      return theme.getEffectiveNodeSelectedColor(context);
    }

    return null;
  }

  TextStyle _getTextStyle() {
    if (!account.data.isEnabled) {
      return theme.disabledTextStyle;
    }

    if (isSelected) {
      return theme.selectedTextStyle;
    }

    return theme.accountTextStyle;
  }
}
