import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';

import 'package:mobile_ide/core/app_constants.dart';
import 'package:mobile_ide/data/models/project.dart';
import 'package:mobile_ide/data/repositories/project_repository.dart';
import 'package:mobile_ide/core/orchestrator.dart';

void main() {
  setUp(() async {
    await setUpTestHive();
    Hive.registerAdapter(ProjectAdapter());
    await Hive.openBox<Project>(kProjectsBoxName);
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  group('ProjectRepository', () {
    test('saves and retrieves a project', () async {
      final repo = ProjectRepository();
      final project = Project.create(name: 'Test', language: 'Dart');

      await repo.saveProject(project);

      final all = repo.getAllProjects();
      expect(all.length, 1);
      expect(all.first.name, 'Test');
      expect(all.first.language, 'Dart');
    });

    test('deletes a project by id', () async {
      final repo = ProjectRepository();
      final project = Project.create(name: 'ToDelete', language: 'Python');
      await repo.saveProject(project);
      expect(repo.getAllProjects().length, 1);

      await repo.deleteProject(project.id);
      expect(repo.getAllProjects().isEmpty, isTrue);
    });
  });

  group('ProjectOrchestrator', () {
    test('creates a project with trimmed name', () async {
      final repo = ProjectRepository();
      final orch = ProjectOrchestrator(repo);

      final p = await orch.createProject(name: '  Hello  ', language: 'Go');
      expect(p.name, 'Hello');
    });

    test('falls back to default name when blank', () async {
      final repo = ProjectRepository();
      final orch = ProjectOrchestrator(repo);

      final p = await orch.createProject(name: '   ', language: 'Rust');
      expect(p.name, 'Untitled Project');
    });

    test('updates content and updatedAt on saveContent', () async {
      final repo = ProjectRepository();
      final orch = ProjectOrchestrator(repo);
      final p = await orch.createProject(name: 'Edit Me', language: 'Dart');

      final before = p.updatedAt;
      await Future.delayed(const Duration(milliseconds: 10));
      await orch.saveContent(p, 'void main() {}');

      expect(p.content, 'void main() {}');
      expect(p.updatedAt.isAfter(before), isTrue);
    });

    test('getAllProjectsSorted returns most recent first', () async {
      final repo = ProjectRepository();
      final orch = ProjectOrchestrator(repo);

      final p1 = await orch.createProject(name: 'First', language: 'Dart');
      await Future.delayed(const Duration(milliseconds: 5));
      await orch.createProject(name: 'Second', language: 'Dart');

      final sorted = orch.getAllProjectsSorted();
      expect(sorted.first.name, 'Second');
      expect(sorted.last.id, p1.id);
    });
  });
}
