import 'package:flutter/material.dart';

class PulseQuestionMark extends StatefulWidget {
  final double size;

  const PulseQuestionMark({super.key, this.size = 120});

  @override
  State<PulseQuestionMark> createState() => _PulseQuestionMarkState();
}

class _PulseQuestionMarkState extends State<PulseQuestionMark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade500, width: 2),
            ),
            child: Center(
              child: Text(
                '?',
                style: TextStyle(
                  fontSize: widget.size * 0.15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
