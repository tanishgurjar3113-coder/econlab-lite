import 'package:flutter/material.dart';
import '../utils/currency_formatter.dart';

class AnimatedNumber extends StatefulWidget {
  final double value;
  final TextStyle? style;

  const AnimatedNumber({super.key, required this.value, this.style});

  @override
  State<AnimatedNumber> createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<AnimatedNumber>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _numberAnimation;
  late Animation<double> _hoverAnimation;

  double _previousValue = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _createAnimations();

    _controller.forward();
  }

  void _createAnimations() {
    _numberAnimation = Tween<double>(
      begin: _previousValue,
      end: widget.value,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutQuart,
      ),
    );

    _hoverAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: 0,
        ),
        weight: 55,
      ),

      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: -3,
        ).chain(CurveTween(curve: Curves.easeOut),
        ),
        weight: 15,
      ),

      TweenSequenceItem(
        tween: Tween<double>(
          begin: -3,
          end: -3,
        ),
        weight: 10,
      ),

      TweenSequenceItem(
        tween: Tween<double>(
          begin: -3,
          end: 0,
        ).chain(CurveTween(curve: Curves.easeInOut),
        ),
        weight: 20,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant AnimatedNumber oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;

      _controller.reset();

      _createAnimations();

      _controller.forward();
    }
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
        return Transform.translate(
          offset: Offset(0, _hoverAnimation.value),
          child: Text(
            CurrencyFormatter.format(_numberAnimation.value),
            style: widget.style,
          ),
        );
      },
    );
  }
}
