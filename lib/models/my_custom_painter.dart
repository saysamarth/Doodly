import 'package:flutter/material.dart';
import 'package:skribble/models/touch_points.dart';

class MyCustomPainter extends CustomPainter {
  MyCustomPainter({required this.paths, required this.currentPoints});

  final List<TouchPoints> paths;
  final List<TouchPoints> currentPoints;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );
    List<TouchPoints> allPoints = [...paths, ...currentPoints];

    if (allPoints.isEmpty) return;

    List<TouchPoints> currentStroke = [];

    for (int i = 0; i < allPoints.length; i++) {
      final point = allPoints[i];
      if (point.isNewStroke && currentStroke.isNotEmpty) {
        _drawStroke(canvas, currentStroke);
        currentStroke = [point];
      } else {
        currentStroke.add(point);
      }
      if (i == allPoints.length - 1 && currentStroke.isNotEmpty) {
        _drawStroke(canvas, currentStroke);
      }
    }
  }

  @override
  bool shouldRepaint(covariant MyCustomPainter oldDelegate) => true;
}

void _drawStroke(Canvas canvas, List<TouchPoints> points) {
  if (points.isEmpty) return;
  if (points.length == 1) {
    canvas.drawCircle(
      points[0].points,
      points[0].paint.strokeWidth / 2,
      points[0].paint,
    );
    return;
  }
  for (int i = 0; i < points.length - 1; i++) {
    final current = points[i];
    final next = points[i + 1];
    canvas.drawLine(current.points, next.points, current.paint);
  }
}
