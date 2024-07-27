import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

class GodRollPie extends StatelessWidget {
  final double percentage;

  const GodRollPie({Key? key, required this.percentage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (percentage == 100) {
      return SvgPicture.asset(
        'assets/icons/crown.svg',
        color: Colors.yellow,
        width: 100,
        height: 100,
      );
    } else {
      return CustomPaint(
        size: const Size(100, 100), // You can adjust the size as needed
        painter: PiePainter(percentage),
      );
    }
  }
}

class PiePainter extends CustomPainter {
  final double percentage;

  PiePainter(this.percentage);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = getColorForPercentage(percentage);

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);

    final sweepAngle = 2 * pi * (percentage / 100);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      true,
      paint,
    );
  }

  Color getColorForPercentage(double percentage) {
    final red = Colors.red;
    final yellow = Colors.yellow;

    if (percentage <= 50) {
      return red;
    } else {
      final factor = (percentage - 50) / 50;
      final redValue = red.red + ((yellow.red - red.red) * factor).toInt();
      final greenValue =
          red.green + ((yellow.green - red.green) * factor).toInt();
      final blueValue = red.blue + ((yellow.blue - red.blue) * factor).toInt();
      return Color.fromARGB(255, redValue, greenValue, blueValue);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
