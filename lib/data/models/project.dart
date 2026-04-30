import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'project.g.dart';

@HiveType(typeId: 0)
class Project extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String language;

  @HiveField(3)
  String content;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  Project({
    required this.id,
    required this.name,
    required this.language,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory that generates a new project with a fresh UUID and timestamps.
  factory Project.create({
    required String name,
    required String language,
    String content = '',
  }) {
    final now = DateTime.now();
    return Project(
      id: const Uuid().v4(),
      name: name,
      language: language,
      content: content,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  String toString() => 'Project(id: $id, name: $name, lang: $language)';
}
