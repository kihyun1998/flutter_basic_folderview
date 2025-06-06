import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CustomInkwell extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onRightClick;
  final BorderRadius? borderRadius;
  final Color? hoverColor;
  final Color? splashColor;

  const CustomInkwell({
    super.key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onRightClick,
    this.borderRadius,
    this.hoverColor,
    this.splashColor,
  });

  @override
  State<CustomInkwell> createState() => _CustomInkwellState();
}

class _CustomInkwellState extends State<CustomInkwell> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Listener(
        onPointerDown: (PointerDownEvent event) {
          // 우클릭 처리
          if (event.kind == PointerDeviceKind.mouse &&
              event.buttons == kSecondaryMouseButton) {
            widget.onRightClick?.call();
          }
        },
        child: InkWell(
          onTap: widget.onTap,
          onDoubleTap: widget.onDoubleTap,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
          hoverColor: widget.hoverColor ?? Theme.of(context).hoverColor,
          splashColor: widget.splashColor ?? Theme.of(context).splashColor,
          child: Container(
            decoration: BoxDecoration(
              color: _isHovered
                  ? (widget.hoverColor ??
                      Theme.of(context).hoverColor.withOpacity(0.1))
                  : Colors.transparent,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
