import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';

class PrimaryButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final double elevation;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool isFullWidth;
  final TextStyle? textStyle;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.elevation = 4.0,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
    this.isFullWidth = true,
    this.textStyle,
    this.isLoading = false,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;

    final style = ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      padding: widget.padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      elevation: widget.elevation,
      shadowColor: Theme.of(context).primaryColor.withValues(alpha: 0.3),
      minimumSize: widget.isFullWidth ? const Size.fromHeight(50) : null,
    );

    Widget button;
    if (widget.icon != null) {
      button = ElevatedButton.icon(
        onPressed: widget.isLoading ? null : widget.onPressed,
        icon: widget.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(widget.icon),
        label: Text(
          widget.label,
          style: widget.textStyle,
        ),
        style: style,
      );
    } else {
      button = ElevatedButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        style: style,
        child: widget.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                widget.label,
                style: widget.textStyle,
              ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Listener(
        onPointerDown: (_) {
          if (enabled) setState(() => _pressed = true);
        },
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: AppDurations.fast,
          curve: AppDurations.ease,
          child: button,
        ),
      ),
    );
  }
}
