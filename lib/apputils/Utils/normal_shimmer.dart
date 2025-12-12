import 'package:flutter/material.dart';

class SimpleShimmer extends StatefulWidget {
  final double width;
  final double height;

  const SimpleShimmer({
    Key? key,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  State<SimpleShimmer> createState() => _SimpleShimmerState();
}

class _SimpleShimmerState extends State<SimpleShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _controller.repeat();
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
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: [
                0.0,
                0.5,
                1.0,
              ],
              transform: GradientRotation(_controller.value * 6.28),
            ),
          ),
        );
      },
    );
  }
}