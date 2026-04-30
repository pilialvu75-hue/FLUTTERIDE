import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileManager {
  /// 📁 Root directory app
  Future<Directory> _getRoot() async {
    final dir = await getApplicationDocumentsDirectory();
    final root = Directory('${dir.path}/projects');

    if (!await root.exists()) {
      await root.create(recursive: true);
    }

    return root;
  }

  /// 📁 Directory progetto
  Future<Directory> getProjectDir(String projectId) async {
    final root = await _getRoot();
    final projectDir = Directory('${root.path}/$projectId');

    if (!await projectDir.exists()) {
      await projectDir.create(recursive: true);
    }

    return projectDir;
  }

  /// 📝 Scrive file
  Future<void> writeFile({
    required String projectId,
    required String fileName,
    required String content,
  }) async {
    final dir = await getProjectDir(projectId);
    final file = File('${dir.path}/$fileName');

    await file.writeAsString(content);
  }

  /// 📖 Legge file
  Future<String> readFile({
    required String projectId,
    required String fileName,
  }) async {
    final dir = await getProjectDir(projectId);
    final file = File('${dir.path}/$fileName');

    if (await file.exists()) {
      return await file.readAsString();
    }

    return "";
  }

  /// 📂 Lista file progetto (async — never blocks the UI thread)
  Future<List<FileSystemEntity>> listFiles(String projectId) async {
    final dir = await getProjectDir(projectId);
    return dir.list().toList();
  }
}
