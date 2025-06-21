import 'dart:math';
import 'package:flutter/material.dart';

class CurvedText extends StatelessWidget {
  final String text;
  final double radius;
  final Shader shader;
  final TextStyle textStyle;

  const CurvedText({
    super.key,
    required this.text,
    required this.radius,
    required this.shader,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final characters = text.characters.toList();
    final totalAngle = pi; // 180° → nach unten gekrümmt
    final anglePerChar = totalAngle / (characters.length - 1);
    final offsetAngle = -pi / 2; // Start oben (12 Uhr)

    return CustomPaint(
      painter: CurvedTextPainter(
        characters: characters,
        radius: radius,
        anglePerChar: anglePerChar,
        offsetAngle: offsetAngle,
        shader: shader,
        textStyle: textStyle,
      ),
    );
  }
}

class CurvedTextPainter extends CustomPainter {
  final List<String> characters;
  final double radius;
  final double anglePerChar;
  final double offsetAngle;
  final Shader shader;
  final TextStyle textStyle;

  CurvedTextPainter({
    required this.characters,
    required this.radius,
    required this.anglePerChar,
    required this.offsetAngle,
    required this.shader,
    required this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, radius);

    for (int i = 0; i < characters.length; i++) {
      final angle = offsetAngle + (anglePerChar * i);
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: characters[i],
          style: textStyle.copyWith(foreground: Paint()..shader = shader),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle + pi / 2); // Drehen, damit der Text senkrecht steht
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
