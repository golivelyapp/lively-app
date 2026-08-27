import 'dart:math' as math;
import 'package:flutter/material.dart';

class ConstellationGraphic extends StatefulWidget {
  const ConstellationGraphic({super.key, this.size = 260});

  final double size;

  @override
  State<ConstellationGraphic> createState() => _ConstellationGraphicState();
}

class _ConstellationGraphicState extends State<ConstellationGraphic>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          return Transform.rotate(
            angle: _controller.value * 2 * math.pi,
            child: child,
          );
        },
        child: CustomPaint(
          size: Size.square(widget.size),
          painter: _ConstellationPainter(),
        ),
      ),
    );
  }
}

class _ConstellationPainter extends CustomPainter {
  static const int _spokeCount = 6;
  static const double _centerRadius = 15;
  static const double _outerRadius = 8;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double orbit = size.shortestSide / 2 - _outerRadius - 6;

    final List<Offset> nodes = List<Offset>.generate(_spokeCount, (int i) {
      final double angle = (2 * math.pi / _spokeCount) * i - math.pi / 2;
      return center + Offset(math.cos(angle), math.sin(angle)) * orbit;
    });

    final Paint linePaint = Paint()
      ..color = const Color(0x48FFFFFF)
      ..strokeWidth = 1.2;
    for (final Offset node in nodes) {
      canvas.drawLine(center, node, linePaint);
    }

    for (int i = 0; i < nodes.length; i++) {
      final Color dotColor = i.isEven
          ? const Color(0xDDFFFFFF)
          : const Color(0xAAFFD6E8);
      canvas.drawCircle(nodes[i], _outerRadius, Paint()..color = dotColor);
    }

    canvas.drawCircle(
      center,
      _centerRadius + 6,
      Paint()
        ..color = const Color(0x30FFFFFF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawCircle(center, _centerRadius, Paint()..color = const Color(0xEEFFFFFF));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
