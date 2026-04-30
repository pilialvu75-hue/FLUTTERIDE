import '../data/models/project.dart';
import '../data/repositories/project_repository.dart';
import 'app_constants.dart';

// 🔥 IMPORT CORRETTO
import 'generator/project_generator.dart';

class ProjectOrchestrator {
  final ProjectRepository _repository;
  final ProjectGenerator _generator = ProjectGenerator();

  ProjectOrchestrator(this._repository);

  List<Project> getAllProjectsSorted() {
    final projects = _repository.getAllProjects();
    projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return projects;
  }

  /// 🔥 CREATE PROJECT + FILE REALI
  Future<Project> createProject({
    required String name,
    required String language,
    String content = '',
  }) async {
    final project = Project.create(
      name: name.trim().isEmpty ? kDefaultProjectName : name.trim(),
      language: language,
      content: content,
    );

    // 1️⃣ salva subito
    await _repository.saveProject(project);

    try {
      // 🔥 CREA FILE REALI
      await _generator.generateProjectFiles(
        projectId: project.id,
        name: project.name,
        language: project.language,
      );

      // 🔥 placeholder UI
      project.content = "// Files generated locally";
      project.updatedAt = DateTime.now();

      await _repository.saveProject(project);
    } catch (e) {
      project.content = "// ERROR: $e";
      await _repository.saveProject(project);
    }

    return project;
  }

  Future<void> saveContent(Project project, String content) async {
    project.content = content;
    project.updatedAt = DateTime.now();
    await _repository.saveProject(project);
  }

  Future<void> deleteProject(String id) async {
    await _repository.deleteProject(id);
  }

  Future<void> renameProject(Project project, String newName) async {
    project.name = newName.trim().isEmpty ? project.name : newName.trim();
    project.updatedAt = DateTime.now();
    await _repository.saveProject(project);
  }

  Map<String, int> getStats() {
    final projects = _repository.getAllProjects();
    final byLanguage = <String, int>{};

    for (final p in projects) {
      byLanguage[p.language] = (byLanguage[p.language] ?? 0) + 1;
    }

    return byLanguage;
  }
}
