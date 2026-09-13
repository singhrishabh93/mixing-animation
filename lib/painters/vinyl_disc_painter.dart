import 'dart:math' as math;
import 'package:flutter/material.dart';

class VinylDiscPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final outerRadius = radius;
    final secondRingRadius = radius * 0.813;
    final grooveRadius = radius * 0.64;
    final centerAreaRadius = radius * 0.5;
    final centerDotRadius = radius * 0.077;
    final borderWidth = radius * 0.023;

    // Outer disc fill — dark gradient
    final outerFill = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF1D1934),
          const Color(0xFF151225),
          const Color(0xFF0F0D1B),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: outerRadius));
    canvas.drawCircle(center, outerRadius, outerFill);

    // Top-light sheen overlay for depth
    final sheenPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.fromRGBO(255, 255, 255, 0.06),
          Color.fromRGBO(255, 255, 255, 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: outerRadius));
    canvas.drawCircle(center, outerRadius, sheenPaint);

    // Outer white border
    final outerBorder = Paint()
      ..color = Color.fromRGBO(255, 255, 255, 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawCircle(center, outerRadius - borderWidth / 2, outerBorder);

    // Second ring border
    final secondBorder = Paint()
      ..color = Color.fromRGBO(255, 255, 255, 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawCircle(center, secondRingRadius, secondBorder);

    // Groove lines between second ring and inner grooves area
    final groovePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (double r = secondRingRadius - 2; r > grooveRadius + 2; r -= 2.5) {
      final t = (secondRingRadius - r) / (secondRingRadius - grooveRadius);
      groovePaint.color = Color.fromRGBO(
        255,
        255,
        255,
        0.03 + 0.02 * math.sin(t * math.pi),
      );
      canvas.drawCircle(center, r, groovePaint);
    }

    // A few grooves in the outer ring area too
    for (double r = outerRadius - 3; r > secondRingRadius + 2; r -= 3.0) {
      groovePaint.color = Color.fromRGBO(255, 255, 255, 0.02);
      canvas.drawCircle(center, r, groovePaint);
    }

    // Inner grooves circle fill
    final innerFill = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF1D1934),
          Color.fromRGBO(29, 25, 52, 0.45),
          Color.fromRGBO(29, 25, 52, 0.0),
        ],
        stops: const [0.0, 0.19, 0.55],
      ).createShader(Rect.fromCircle(center: center, radius: grooveRadius));
    canvas.drawCircle(center, grooveRadius, innerFill);

    // Inner ring dark border
    final innerBorder = Paint()
      ..color = const Color(0xFF0A0A14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth * 3.5;
    canvas.drawCircle(center, grooveRadius - borderWidth * 1.5, innerBorder);

    // Album art — three layered radial gradients (Figma aurora)
    final auroraRadius = radius * 0.48;

    // Layer 1: Orange (top-right, vivid)
    final orangeGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.6, -0.35),
        radius: 0.7,
        colors: [
          const Color(0xFFFE6545),
          Color.fromRGBO(254, 101, 69, 0.9),
          Color.fromRGBO(200, 80, 60, 0.4),
          Color.fromRGBO(29, 25, 52, 0.0),
        ],
        stops: const [0.0, 0.25, 0.55, 0.9],
      ).createShader(Rect.fromCircle(center: center, radius: auroraRadius));
    canvas.drawCircle(center, auroraRadius, orangeGlow);

    // Layer 2: Purple (center-left)
    final purpleGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.1, -0.1),
        radius: 0.85,
        colors: [
          Color.fromRGBO(170, 111, 255, 0.95),
          Color.fromRGBO(130, 80, 200, 0.6),
          Color.fromRGBO(80, 50, 140, 0.25),
          Color.fromRGBO(29, 25, 52, 0.0),
        ],
        stops: const [0.0, 0.3, 0.55, 0.9],
      ).createShader(Rect.fromCircle(center: center, radius: auroraRadius));
    canvas.drawCircle(center, auroraRadius, purpleGlow);

    // Layer 3: Blue (bottom-center)
    final blueGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.15, 0.45),
        radius: 0.7,
        colors: [
          Color.fromRGBO(25, 151, 255, 0.9),
          Color.fromRGBO(40, 120, 200, 0.5),
          Color.fromRGBO(29, 25, 52, 0.0),
        ],
        stops: const [0.0, 0.3, 0.8],
      ).createShader(Rect.fromCircle(center: center, radius: auroraRadius));
    canvas.drawCircle(center, auroraRadius, blueGlow);

    // Center dot
    final centerDot = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.black,
          Color.fromRGBO(64, 64, 101, 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: centerDotRadius));
    canvas.drawCircle(center, centerDotRadius, centerDot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
