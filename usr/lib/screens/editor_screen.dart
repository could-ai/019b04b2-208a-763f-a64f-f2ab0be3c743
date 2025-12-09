import 'dart:async';
import 'package:flutter/material.dart';
import '../models/animation_models.dart';
import '../widgets/canvas_painter.dart';

class EditorScreen extends StatefulWidget {
  final AnimationProject project;

  const EditorScreen({super.key, required this.project});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late AnimationProject project;
  int currentFrameIndex = 0;
  bool isPlaying = false;
  Timer? _playbackTimer;

  // Drawing state
  Color selectedColor = Colors.black;
  double strokeWidth = 3.0;
  bool isEraser = false;
  
  // Onion skin
  bool onionSkinEnabled = true;

  @override
  void initState() {
    super.initState();
    project = widget.project;
    // Ensure at least one frame
    if (project.frames.isEmpty) {
      project.frames.add(Frame(id: DateTime.now().toString()));
    }
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  void _togglePlayback() {
    if (isPlaying) {
      _playbackTimer?.cancel();
      setState(() {
        isPlaying = false;
      });
    } else {
      setState(() {
        isPlaying = true;
      });
      final duration = Duration(milliseconds: (1000 / project.fps).round());
      _playbackTimer = Timer.periodic(duration, (timer) {
        setState(() {
          currentFrameIndex = (currentFrameIndex + 1) % project.frames.length;
        });
      });
    }
  }

  void _addFrame() {
    setState(() {
      project.frames.insert(currentFrameIndex + 1, Frame(id: DateTime.now().toString()));
      currentFrameIndex++;
    });
  }

  void _deleteFrame() {
    if (project.frames.length <= 1) return;
    setState(() {
      project.frames.removeAt(currentFrameIndex);
      if (currentFrameIndex >= project.frames.length) {
        currentFrameIndex = project.frames.length - 1;
      }
    });
  }

  void _duplicateFrame() {
    final currentFrame = project.frames[currentFrameIndex];
    // Deep copy strokes
    final newStrokes = currentFrame.strokes.map((s) => Stroke(
      points: List.from(s.points),
      color: s.color,
      width: s.width,
    )).toList();

    setState(() {
      project.frames.insert(currentFrameIndex + 1, Frame(
        id: DateTime.now().toString(),
        strokes: newStrokes,
      ));
      currentFrameIndex++;
    });
  }

  void _onDrawingPanStart(DragStartDetails details, BuildContext context) {
    if (isPlaying) return;
    
    final RenderBox box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);

    setState(() {
      project.frames[currentFrameIndex].strokes.add(Stroke(
        points: [point],
        color: isEraser ? Colors.white : selectedColor, // Simple eraser implementation (paint white)
        width: strokeWidth,
      ));
    });
  }

  void _onDrawingPanUpdate(DragUpdateDetails details, BuildContext context) {
    if (isPlaying) return;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);

    setState(() {
      final strokes = project.frames[currentFrameIndex].strokes;
      if (strokes.isNotEmpty) {
        strokes.last.points.add(point);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(project.name),
        actions: [
          IconButton(
            icon: Icon(onionSkinEnabled ? Icons.layers : Icons.layers_clear),
            tooltip: 'Onion Skin (Pele de Cebola)',
            onPressed: () {
              setState(() {
                onionSkinEnabled = !onionSkinEnabled;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: _togglePlayback,
            color: isPlaying ? Colors.green : null,
          ),
        ],
      ),
      body: Column(
        children: [
          // Toolbar
          _buildToolbar(),
          
          // Canvas Area
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: ClipRect(
                    child: Builder(
                      builder: (context) {
                        return GestureDetector(
                          onPanStart: (d) => _onDrawingPanStart(d, context),
                          onPanUpdate: (d) => _onDrawingPanUpdate(d, context),
                          child: CustomPaint(
                            painter: CanvasPainter(
                              currentFrame: project.frames[currentFrameIndex],
                              previousFrame: (onionSkinEnabled && currentFrameIndex > 0) 
                                  ? project.frames[currentFrameIndex - 1] 
                                  : null,
                            ),
                            size: Size.infinite,
                          ),
                        );
                      }
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Timeline
          _buildTimeline(),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: const Color(0xFF1E1E1E),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _toolButton(Icons.brush, !isEraser, () => setState(() => isEraser = false)),
          const SizedBox(width: 8),
          _toolButton(Icons.cleaning_services, isEraser, () => setState(() => isEraser = true)), // Eraser icon
          const SizedBox(width: 16),
          // Color picker (simplified)
          Wrap(
            spacing: 8,
            children: [Colors.black, Colors.red, Colors.blue, Colors.green].map((c) {
              return GestureDetector(
                onTap: () => setState(() {
                  selectedColor = c;
                  isEraser = false;
                }),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selectedColor == c && !isEraser ? Colors.white : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(width: 16),
          Slider(
            value: strokeWidth,
            min: 1.0,
            max: 20.0,
            activeColor: Colors.red,
            onChanged: (v) => setState(() => strokeWidth = v),
          ),
        ],
      ),
    );
  }

  Widget _toolButton(IconData icon, bool isActive, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon),
      color: isActive ? Colors.red : Colors.grey,
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: isActive ? Colors.red.withOpacity(0.1) : null,
      ),
    );
  }

  Widget _buildTimeline() {
    return Container(
      height: 120,
      color: const Color(0xFF1E1E1E),
      child: Column(
        children: [
          // Timeline Controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quadro ${currentFrameIndex + 1} / ${project.frames.length}',
                  style: const TextStyle(color: Colors.white70),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: _deleteFrame,
                      tooltip: 'Apagar Quadro',
                    ),
                    IconButton(
                      icon: const Icon(Icons.content_copy, size: 20),
                      onPressed: _duplicateFrame,
                      tooltip: 'Duplicar Quadro',
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_box),
                      onPressed: _addFrame,
                      tooltip: 'Novo Quadro',
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Frames List
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: project.frames.length,
              itemBuilder: (context, index) {
                final isSelected = index == currentFrameIndex;
                return GestureDetector(
                  onTap: () => setState(() => currentFrameIndex = index),
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: isSelected 
                          ? Border.all(color: Colors.red, width: 3) 
                          : Border.all(color: Colors.grey[800]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: CustomPaint(
                      painter: ThumbnailPainter(frame: project.frames[index]),
                      size: Size.infinite,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
