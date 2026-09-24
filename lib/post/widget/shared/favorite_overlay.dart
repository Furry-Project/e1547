import 'package:flutter/material.dart';

class AnimatedHeartOverlay extends StatefulWidget {
  const AnimatedHeartOverlay({
    super.key,
    required this.trigger,
  });

  final ValueNotifier<int> trigger;

  @override
  State<AnimatedHeartOverlay> createState() => _AnimatedHeartOverlayState();
}

class _AnimatedHeartOverlayState extends State<AnimatedHeartOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  );

  late final Animation<double> _scaleAnimation = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0, end: 1.2), weight: 30),
    TweenSequenceItem(tween: Tween(begin: 1.2, end: 1), weight: 30),
    TweenSequenceItem(tween: Tween(begin: 1, end: 1), weight: 20),
    TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 20),
  ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  late final Animation<double> _opacityAnimation = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 20),
    TweenSequenceItem(tween: Tween(begin: 1, end: 1), weight: 60),
    TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 20),
  ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    widget.trigger.addListener(_onTrigger);
  }

  @override
  void didUpdateWidget(AnimatedHeartOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger != widget.trigger) {
      oldWidget.trigger.removeListener(_onTrigger);
      widget.trigger.addListener(_onTrigger);
    }
  }

  @override
  void dispose() {
    widget.trigger.removeListener(_onTrigger);
    _controller.dispose();
    super.dispose();
  }

  void _onTrigger() {
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            if (_controller.isDismissed) {
              return const SizedBox.shrink();
            }
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 100,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
