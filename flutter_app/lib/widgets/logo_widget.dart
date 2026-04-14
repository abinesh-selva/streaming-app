import 'package:flutter/material.dart';

class BoundaryCricLogo extends StatelessWidget {
  final double size;
  final Color color;

  const BoundaryCricLogo({super.key, this.size = 32, this.color = const Color(0xFF1AFFD5)});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: LogoPainter(color: color),
      ),
    );
  }
}

class LogoPainter extends CustomPainter {
  final Color color;

  LogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Draw stylized "B" which also looks like a cricket stadium boundary
    final path = Path();
    
    // Outer boundary circle (partial)
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      -0.5, 4.5,
      false, 
      paint..style = PaintingStyle.stroke
    );

    // Inner "B" / Sitching lines
    final innerPath = Path();
    innerPath.moveTo(size.width * 0.3, size.height * 0.2);
    innerPath.lineTo(size.width * 0.3, size.height * 0.8);
    innerPath.moveTo(size.width * 0.3, size.height * 0.2);
    innerPath.quadraticBezierTo(size.width * 0.8, size.height * 0.2, size.width * 0.3, size.height * 0.5);
    innerPath.quadraticBezierTo(size.width * 0.9, size.height * 0.5, size.width * 0.3, size.height * 0.8);

    canvas.drawPath(innerPath, paint);
    
    // Glow effect
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawPath(innerPath, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
