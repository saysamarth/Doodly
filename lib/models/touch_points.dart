import 'package:flutter/material.dart';
class TouchPoints {
  final Paint paint;
  final Offset points;
  final bool isNewStroke;
  
  // Add these properties to store normalized coordinates
  final double normalizedX;  // 0.0 to 1.0
  final double normalizedY;  // 0.0 to 1.0

  TouchPoints({
    required this.points, 
    required this.paint,
    this.isNewStroke = false,
    this.normalizedX = 0.0,
    this.normalizedY = 0.0,
  });

  // Create a factory constructor that normalizes coordinates
  factory TouchPoints.normalized({
    required Offset points,
    required Paint paint,
    required Size canvasSize,
    bool isNewStroke = false,
  }) {
    return TouchPoints(
      points: points,
      paint: paint,
      isNewStroke: isNewStroke,
      normalizedX: points.dx / canvasSize.width,
      normalizedY: points.dy / canvasSize.height,
    );
  }

  // Create a factory constructor that denormalizes coordinates
  factory TouchPoints.fromNormalized({
    required double normalizedX,
    required double normalizedY,
    required Paint paint,
    required Size canvasSize,
    bool isNewStroke = false,
  }) {
    return TouchPoints(
      points: Offset(
        normalizedX * canvasSize.width,
        normalizedY * canvasSize.height,
      ),
      paint: paint,
      isNewStroke: isNewStroke,
      normalizedX: normalizedX,
      normalizedY: normalizedY,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'point': {
        'dx': points.dx,
        'dy': points.dy,
        'normalizedX': normalizedX,
        'normalizedY': normalizedY,
      },
      'paint': {
        'color': paint.color.value,
        'strokeWidth': paint.strokeWidth,
      },
      'isNewStroke': isNewStroke,
    };
  }

  factory TouchPoints.fromJson(Map<String, dynamic> json) {
    return TouchPoints(
      points: Offset(
        (json['point']['dx'] as num).toDouble(),
        (json['point']['dy'] as num).toDouble(),
      ),
      paint: Paint()
        ..color = Color(json['paint']['color'] as int)
        ..strokeWidth = (json['paint']['strokeWidth'] as num).toDouble()
        ..strokeCap = StrokeCap.round,
      isNewStroke: json['isNewStroke'] ?? false,
      normalizedX: (json['point']['normalizedX'] as num?)?.toDouble() ?? 0.0,
      normalizedY: (json['point']['normalizedY'] as num?)?.toDouble() ?? 0.0,
    );
  }
}