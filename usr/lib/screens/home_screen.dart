import 'package:flutter/material.dart';
import '../models/animation_models.dart';
import 'editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Mock data for now
  List<AnimationProject> projects = [];

  void _createNewProject() {
    // In a real app, show a dialog to ask for name and FPS
    final newProject = AnimationProject(
      id: DateTime.now().toString(),
      name: 'Ninja Scroll ${projects.length + 1}',
      fps: 12,
    );

    setState(() {
      projects.add(newProject);
    });

    _openProject(newProject);
  }

  void _openProject(AnimationProject project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditorScreen(project: project),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DOJO DE ANIMAÇÃO'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: projects.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.brush, size: 80, color: Colors.grey[800]),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhum pergaminho encontrado',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Crie uma nova animação para começar seu treino.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Desktop friendly
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return _buildProjectCard(project);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewProject,
        icon: const Icon(Icons.add),
        label: const Text('NOVO PERGAMINHO'),
      ),
    );
  }

  Widget _buildProjectCard(AnimationProject project) {
    return Card(
      color: const Color(0xFF2C2C2C),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openProject(project),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: Colors.white10,
                child: const Center(
                  child: Icon(Icons.movie_creation_outlined, size: 48, color: Colors.white24),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${project.frames.length} Quadros • ${project.fps} FPS',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
