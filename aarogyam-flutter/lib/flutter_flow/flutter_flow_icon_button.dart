// flutter_flow_icon_button.dart — compatibility shim.
// FlutterFlowIconButton maps to standard Material IconButton.

import 'package:flutter/material.dart';

/// Drop-in replacement for FF's FlutterFlowIconButton.
class FlutterFlowIconButton extends StatelessWidget {
  const FlutterFlowIconButton({
    super.key,
    required this.borderRadius,
    this.buttonSize,
    this.fillColor,
    this.icon,
    this.onPressed,
    this.disabledColor,
    this.hoverColor,
    this.iconSize,
    this.borderColor,
    this.borderWidth,
    this.showLoadingIndicator = false,
  });

  final double borderRadius;
  final double? buttonSize;
  final Color? fillColor;
  final Widget? icon;
  final VoidCallback? onPressed;
  final Color? disabledColor;
  final Color? hoverColor;
  final double? iconSize;
  final Color? borderColor;
  final double? borderWidth;
  final bool showLoadingIndicator;

  @override
  Widget build(BuildContext context) {
    final size = buttonSize ?? 40.0;
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: fillColor ?? Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: borderColor != null
              ? BorderSide(color: borderColor!, width: borderWidth ?? 1)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onPressed,
          hoverColor: hoverColor,
          child: Center(
            child: showLoadingIndicator && onPressed == null
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : icon ?? const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
