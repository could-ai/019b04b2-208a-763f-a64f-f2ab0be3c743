import 'package:flutter/material.dart';

// Basic data models for the animation app

class Stroke {
  final List<Offset> points;
  final Color color;
  final double width;

  Stroke({
    required this.points,
    this.color = Colors.white,
    this.width = 2.0,
  });
}

class Frame {
  final String id;
  final List<Stroke> strokes;
  // Could add background color, layer info here later

  Frame({
    required this.id,
    List<Stroke>? strokes,
  }) : strokes = strokes ?? [];
}

class AnimationProject {
  String id;
  String name;
  int fps;
  List<Frame> frames;
  DateTime lastModified;

  AnimationProject({
    required this.id,
    required this.name,
    this.fps = 12,
    List<Frame>? frames,
    DateTime? lastModified,
  })  : frames = frames ?? [Frame(id: DateTime.now().toString())],
        lastModified = lastModified ?? DateTime.now();
}
