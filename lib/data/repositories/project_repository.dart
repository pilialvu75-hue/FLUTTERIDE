import 'package:hive/hive.dart';

import '../models/project.dart';
import '../../core/app_constants.dart';

/// Low-level CRUD operations on the local Hive [Project] box.
/// Higher-level business logic lives in [ProjectOrchestrator].
class ProjectRepository {
  Box<Project> get _box => Hive.box<Project>(kProjectsBoxName);

  // ── Read ──────────────────────────────────────────────────────────────────

  List<Project> getAllProjects() => _box.values.toList();

  Project? getProjectById(String id) {
    try {
      return _box.values.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Upserts a project using its [Project.id] as the Hive key.
  Future<void> saveProject(Project project) async {
    await _box.put(project.id, project);
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteProject(String id) async {
    await _box.delete(id);
  }

  Future<void> deleteAllProjects() async {
    await _box.clear();
  }
}
