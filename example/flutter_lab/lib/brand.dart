// Compatibility with the lab's Flutter >=3.35 minimum.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

/// Original three-criteria mark: inputs converge into an ascending decision.
class DecisionMark extends StatelessWidget {
  const DecisionMark({super.key, this.size = 36});
  final double size;
  @override
  Widget build(BuildContext context) => Semantics(
      label: 'Decision Engine',
      image: true,
      child: CustomPaint(size: Size.square(size), painter: _MarkPainter()));
}

class _MarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 48, size.height / 48);
    final background = Paint()..color = const Color(0xFF123D40);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(0, 0, 48, 48), const Radius.circular(12)),
        background);
    final line = Paint()
      ..color = const Color(0xFF5DE4C7)
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
        Path()
          ..moveTo(11, 13)
          ..lineTo(24, 25)
          ..lineTo(36, 12)
          ..moveTo(11, 25)
          ..lineTo(24, 25)
          ..lineTo(36, 12)
          ..moveTo(11, 37)
          ..lineTo(24, 25)
          ..moveTo(29, 12)
          ..lineTo(36, 12)
          ..lineTo(36, 19),
        line);
    final node = Paint()..color = const Color(0xFFB7FAE8);
    for (final y in [13.0, 25.0, 37.0]) {
      canvas.drawCircle(Offset(11, y), 3.2, node);
    }
  }

  @override
  bool shouldRepaint(_MarkPainter old) => false;
}
