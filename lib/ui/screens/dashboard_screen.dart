import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/orchestrator.dart';
import '../../data/models/project.dart';
import '../../data/repositories/project_repository.dart';
import '../../core/app_constants.dart';
import '../widgets/project_card.dart';

import 'editor_screen.dart';
import 'file_explorer_screen.dart';
import 'new_project_screen.dart';

class DashboardScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  const DashboardScreen({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _repository = ProjectRepository();
  late final ProjectOrchestrator _orchestrator;

  @override
  void initState() {
    super.initState();
    _orchestrator = ProjectOrchestrator(_repository);
  }

  // ── ACTIONS ─────────────────────────────────────────────

  Future<void> _openNewProjectScreen() async {
    final result = await Navigator.of(context).push<Map<String, String>>(
      MaterialPageRoute(builder: (_) => const NewProjectScreen()),
    );

    if (result != null) {
      await _orchestrator.createProject(
        name: result['name']!,
        language: result['language']!,
      );
    }
  }

  Future<void> _openEditor(Project project) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditorScreen(
          project: project,
          orchestrator: _orchestrator,
        ),
      ),
    );
  }

  Future<void> _deleteProject(Project project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete project'),
        content: Text('Delete "${project.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _orchestrator.deleteProject(project.id);
    }
  }

  Future<void> _renameProject(Project project) async {
    final controller = TextEditingController(text: project.name);

    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename project'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (newName != null && newName.trim().isNotEmpty) {
      await _orchestrator.renameProject(project, newName);
    }
  }

  // ── UI ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Project>(kProjectsBoxName).listenable(),
      builder: (context, box, _) {
        final projects = _orchestrator.getAllProjectsSorted();
        final stats = _orchestrator.getStats();

        return Scaffold(
          appBar: AppBar(
            title: const Text('MobileIde'),
            actions: [
              IconButton(
                icon: Icon(
                  widget.themeMode == ThemeMode.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                tooltip: 'Toggle theme',
                onPressed: widget.onToggleTheme,
              ),
            ],
          ),

          // 🔥 FIX PRINCIPALE QUI
          body: SafeArea(
            child: Column(
              children: [
                // ── Stats ─────────────────────────────
                if (projects.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        _StatChip(
                          icon: Icons.folder_copy_outlined,
                          label: '${projects.length} project'
                              '${projects.length == 1 ? '' : 's'}',
                        ),
                        const SizedBox(width: 8),
                        _StatChip(
                          icon: Icons.code,
                          label: '${stats.keys.length} language'
                              '${stats.keys.length == 1 ? '' : 's'}',
                        ),
                      ],
                    ),
                  ),

                // ── LISTA ─────────────────────────────
                Expanded(
                  child: projects.isEmpty
                      ? _EmptyState(onCreateTap: _openNewProjectScreen)
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: projects.length,
                          itemBuilder: (ctx, i) {
                            final project = projects[i];

                            return ProjectCard(
                              project: project,
                              onTap: () => _openEditor(project),
                              onDelete: () => _deleteProject(project),
                              onRename: () => _renameProject(project),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openNewProjectScreen,
            icon: const Icon(Icons.add),
            label: const Text('New Project'),
          ),
        );
      },
    );
  }
}

// ── Private helpers ───────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      avatar: Icon(icon, size: 16, color: theme.colorScheme.primary),
      label: Text(label, style: theme.textTheme.bodySmall),
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateTap;

  const _EmptyState({required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 72,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No projects yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap "New Project" to get started.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCreateTap,
              icon: const Icon(Icons.add),
              label: const Text('New Project'),
            ),
          ],
        ),
      ),
    );
  }
}
