import 'package:flutter/material.dart';

class TeamShield extends StatelessWidget {
  final String teamShort;
  final double size;
  final Color primaryColor;
  final Color secondaryColor;

  const TeamShield({
    super.key,
    required this.teamShort,
    required this.size,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: ShieldPainter(
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          text: teamShort,
        ),
      ),
    );
  }
}

class ShieldPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final String text;

  ShieldPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.text,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [primaryColor, secondaryColor],
      ).createShader(Offset.zero & size);

    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.05);
    path.lineTo(size.width * 0.9, size.height * 0.2);
    path.lineTo(size.width * 0.9, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.9, size.height * 0.75, size.width * 0.5, size.height * 0.95);
    path.quadraticBezierTo(size.width * 0.1, size.height * 0.75, size.width * 0.1, size.height * 0.5);
    path.lineTo(size.width * 0.1, size.height * 0.2);
    path.close();

    canvas.drawPath(path, paint);

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(path, borderPaint);

    // Draw Text
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: size.width * 0.35,
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(color: Colors.black54, offset: Offset(0, 2), blurRadius: 4),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2 + 5),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
