import 'package:flutter/material.dart';
import '../models/animation_models.dart';
import 'dart:ui';

class CanvasPainter extends CustomPainter {
  final Frame currentFrame;
  final Frame? previousFrame; // For onion skin

  CanvasPainter({required this.currentFrame, this.previousFrame});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Onion Skin (Previous Frame) if available
    if (previousFrame != null) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      for (final stroke in previousFrame!.strokes) {
        if (stroke.points.isEmpty) continue;
        
        // Onion skin style: semi-transparent red or blue usually
        paint.color = Colors.red.withOpacity(0.2); 
        paint.strokeWidth = stroke.width;

        final path = Path();
        path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
        for (int i = 1; i < stroke.points.length; i++) {
          path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }

    // 2. Draw Current Frame
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final stroke in currentFrame.strokes) {
      if (stroke.points.isEmpty) continue;

      paint.color = stroke.color;
      paint.strokeWidth = stroke.width;

      final path = Path();
      path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (int i = 1; i < stroke.points.length; i++) {
        path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) {
    return true; // Always repaint for drawing updates
  }
}

class ThumbnailPainter extends CustomPainter {
  final Frame frame;

  ThumbnailPainter({required this.frame});

  @override
  void paint(Canvas canvas, Size size) {
    // Scale down the drawing to fit the thumbnail
    // Assuming original canvas was roughly 16:9 or similar, we just scale to fit
    // For a real app, we'd need to know the original canvas size to scale correctly.
    // Here we'll just apply a generic scale assuming the drawing is within bounds.
    
    canvas.save();
    canvas.scale(0.1, 0.1); // Rough scaling for thumbnail

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final stroke in frame.strokes) {
      if (stroke.points.isEmpty) continue;

      paint.color = stroke.color;
      paint.strokeWidth = stroke.width * 2; // Make lines thicker in thumbnail

      final path = Path();
      path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (int i = 1; i < stroke.points.length; i++) {
        path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
      }
      canvas.drawPath(path, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ThumbnailPainter oldDelegate) {
    return true;
  }
}
