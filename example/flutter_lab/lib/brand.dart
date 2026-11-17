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

/// Locally drawn, stylized national flags; no remote images or emoji glyphs.
class LanguageFlag extends StatelessWidget {
  const LanguageFlag(
      {super.key, required this.language, required this.selected});
  final String language;
  final bool selected;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
          child: Stack(clipBehavior: Clip.none, children: [
        Container(
            width: 36,
            height: 36,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: selected
                        ? const Color(0xFF5DE4C7)
                        : const Color(0xFF8294A6),
                    width: selected ? 3 : 1)),
            child:
                ClipOval(child: CustomPaint(painter: _FlagPainter(language)))),
        if (selected)
          const Positioned(
              right: -2,
              bottom: -2,
              child:
                  Icon(Icons.check_circle, size: 14, color: Color(0xFF5DE4C7))),
      ]));
}

class _FlagPainter extends CustomPainter {
  const _FlagPainter(this.language);
  final String language;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 36, size.height / 36);
    if (language == 'pt') {
      canvas.drawRect(const Rect.fromLTWH(0, 0, 36, 36),
          Paint()..color = const Color(0xFF009B3A));
      canvas.drawPath(
          Path()
            ..moveTo(18, 4)
            ..lineTo(34, 18)
            ..lineTo(18, 32)
            ..lineTo(2, 18)
            ..close(),
          Paint()..color = const Color(0xFFFFDF00));
      canvas.drawCircle(
          const Offset(18, 18), 8.5, Paint()..color = const Color(0xFF002776));
      canvas.save();
      canvas.clipPath(Path()..addOval(const Rect.fromLTWH(9.5, 9.5, 17, 17)));
      canvas.drawArc(
          const Rect.fromLTWH(5, 14, 27, 17),
          3.4,
          2.5,
          false,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.3);
      canvas.restore();
      final star = Paint()..color = Colors.white;
      for (final p in [
        const Offset(16, 21),
        const Offset(21, 22),
        const Offset(19, 25),
        const Offset(23, 18)
      ]) {
        canvas.drawCircle(p, .65, star);
      }
    } else {
      canvas.drawRect(const Rect.fromLTWH(0, 0, 36, 36),
          Paint()..color = const Color(0xFF012169));
      for (final color in [Colors.white, const Color(0xFFC8102E)]) {
        final p = Paint()
          ..color = color
          ..strokeWidth = color == Colors.white ? 9 : 4;
        canvas.drawLine(const Offset(-2, 0), const Offset(38, 36), p);
        canvas.drawLine(const Offset(38, 0), const Offset(-2, 36), p);
      }
      canvas.drawRect(
          const Rect.fromLTWH(0, 12, 36, 12), Paint()..color = Colors.white);
      canvas.drawRect(
          const Rect.fromLTWH(12, 0, 12, 36), Paint()..color = Colors.white);
      canvas.drawRect(const Rect.fromLTWH(0, 15, 36, 6),
          Paint()..color = const Color(0xFFC8102E));
      canvas.drawRect(const Rect.fromLTWH(15, 0, 6, 36),
          Paint()..color = const Color(0xFFC8102E));
    }
  }

  @override
  bool shouldRepaint(_FlagPainter old) => language != old.language;
}
