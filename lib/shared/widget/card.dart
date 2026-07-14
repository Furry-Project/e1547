import 'package:flutter/material.dart';

class ColoredCard extends StatefulWidget {
  const ColoredCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.color,
    this.onTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.leading,
    this.trailing,
  });

  final Widget child;
  final Color? backgroundColor;
  final Color? color;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onSecondaryTap;
  final Widget? leading;
  final Widget? trailing;

  @override
  State<ColoredCard> createState() => _ColoredCardState();
}

class _ColoredCardState extends State<ColoredCard> {
  bool _pressed = false;
  bool _held = false;
  int _pressToken = 0;

  void _press() {
    setState(() => _pressed = true);
    final token = ++_pressToken;
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted && _pressToken == token && !_held) {
        setState(() => _pressed = false);
      }
    });
  }

  void _hold() {
    _held = true;
    setState(() => _pressed = true);
  }

  void _release() {
    _held = false;
    _press();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.backgroundColor ?? Theme.of(context).cardColor;
    final brightness = Theme.of(context).brightness;
    final pressedColor = Color.lerp(
      baseColor,
      brightness == Brightness.dark ? Colors.white : Colors.black,
      0.1,
    )!;
    return Padding(
      padding: const EdgeInsets.all(2),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => _press(),
        onTapCancel: () => setState(() => _pressed = false),
        onLongPress: widget.onLongPress,
        onLongPressDown: (_) => _hold(),
        onLongPressUp: _release,
        onLongPressCancel: _release,
        onSecondaryTap: widget.onSecondaryTap,
        onSecondaryTapDown: (_) => _press(),
        onSecondaryTapCancel: () => setState(() => _pressed = false),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _pressed ? pressedColor : baseColor,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.color case final stripeColor?)
                Container(
                  height: 27,
                  decoration: BoxDecoration(
                    color: stripeColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                    ),
                  ),
                  child: widget.leading ?? const SizedBox(width: 5),
                ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 4,
                    bottom: 4,
                    right: 10,
                    left: 6,
                  ),
                  child: widget.child,
                ),
              ),
              if (widget.trailing case final trailing?) trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class IndentedCard extends StatelessWidget {
  const IndentedCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.color,
  });

  final Widget child;
  final Color? backgroundColor;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).cardColor,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Padding(padding: const EdgeInsets.only(left: 5), child: child),
            if (color != null)
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                child: Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
