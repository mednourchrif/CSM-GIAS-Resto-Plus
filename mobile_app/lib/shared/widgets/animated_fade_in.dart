import 'package:flutter/material.dart';
import '../../../core/theme/spacing.dart';

/// Staggered fade-in animation for list items and page content.
///
/// Wraps a child in a fade + slide-up animation that triggers when the
/// widget first appears. Set [delay] to stagger multiple items.
class AnimatedFadeIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset slideOffset;

  const AnimatedFadeIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppDurations.normal,
    this.slideOffset = const Offset(0, 20),
  });

  @override
  State<AnimatedFadeIn> createState() => _AnimatedFadeInState();
}

class _AnimatedFadeInState extends State<AnimatedFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.enter),
    );

    _slide = Tween<Offset>(
      begin: widget.slideOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.enter),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _opacity,
          child: Transform.translate(
            offset: _slide.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Staggered list of [AnimatedFadeIn] wrappers.
///
/// Use to animate a list of items one after another.
class StaggeredFadeInList extends StatelessWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Duration itemDuration;
  final Axis scrollDirection;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final ScrollPhysics? physics;

  const StaggeredFadeInList({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 60),
    this.itemDuration = AppDurations.normal,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.controller,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: scrollDirection,
      padding: padding,
      controller: controller,
      physics: physics,
      itemCount: children.length,
      itemBuilder: (context, i) => AnimatedFadeIn(
        delay: staggerDelay * i,
        duration: itemDuration,
        child: children[i],
      ),
    );
  }
}
