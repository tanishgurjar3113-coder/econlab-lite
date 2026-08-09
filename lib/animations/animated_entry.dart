import 'package:flutter/material.dart';

class AnimatedEntry extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const AnimatedEntry({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<AnimatedEntry> createState() => _AnimatedEntryState();
}

class _AnimatedEntryState extends State<AnimatedEntry>
    with SingleTickerProviderStateMixin {
      late final AnimationController _controller;
      late final Animation<double> _opacity;
      late final Animation<Offset> _slide;

      @override
      void initState() {
        super.initState();

        _controller = AnimationController(vsync: this,
        duration: widget.duration,
        );

        _opacity = CurvedAnimation(parent: _controller,
         curve: Curves.easeOut,
         );

         _slide = Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
         ).animate(
          CurvedAnimation(parent: _controller,
           curve: Curves.easeOutCubic,
           ),
         );

         Future.delayed(widget.delay, () {
          if (mounted) {
            _controller.forward();
          }
         });
      }

      @override
      void dispose() {
        _controller.dispose();
        super.dispose();
      }

      @override
      Widget build(BuildContext context) {
        return FadeTransition(opacity: _opacity,
        child: SlideTransition(position: _slide,
        child: widget.child,
      ),
    );
  }
}