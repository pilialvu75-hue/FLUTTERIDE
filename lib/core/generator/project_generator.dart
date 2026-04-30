import '../ai/prompt_builder.dart';
import '../ai/step_executor.dart';
import '../../data/files/file_manager.dart';

class ProjectGenerator {
  final StepExecutor _executor = StepExecutor();
  final FileManager _files = FileManager();

  Future<void> generateProjectFiles({
    required String projectId,
    required String name,
    required String language,
  }) async {
    final steps = [
      PromptBuilder.createProjectPrompt(name, language),
      "Create UI layout",
      "Create logic files",
      "Add basic features",
    ];

    final results = await _executor.executeSteps(steps);
    final combined = results.join('\n\n');

    // Generate language-appropriate files
    final lang = language.toLowerCase();

    // Primary source file
    final primaryFile = _primaryFileName(lang, name);
    await _files.writeFile(
      projectId: projectId,
      fileName: primaryFile,
      content: combined,
    );

    // Secondary support files (only for web/scripted languages)
    if (_needsHtml(lang)) {
      await _files.writeFile(
        projectId: projectId,
        fileName: 'index.html',
        content: '<!DOCTYPE html>\n<html lang="en">\n<head>\n'
            '  <meta charset="UTF-8">\n  <title>$name</title>\n'
            '  <link rel="stylesheet" href="style.css">\n</head>\n'
            '<body>\n  <h1>$name</h1>\n  <script src="app.js"></script>\n'
            '</body>\n</html>\n',
      );
      await _files.writeFile(
        projectId: projectId,
        fileName: 'style.css',
        content:
            'body { font-family: system-ui, sans-serif; margin: 0; padding: 16px; }\n',
      );
      await _files.writeFile(
        projectId: projectId,
        fileName: 'app.js',
        content: "console.log('$name started');\n",
      );
    } else if (_needsReadme(lang)) {
      await _files.writeFile(
        projectId: projectId,
        fileName: 'README.md',
        content: '# $name\n\n> Generated locally — no internet required.\n',
      );
    }
  }

  /// Returns the primary source file name for a given language.
  String _primaryFileName(String lang, String name) {
    switch (lang) {
      case 'dart':
        return 'main.dart';
      case 'python':
        return 'main.py';
      case 'javascript':
        return 'app.js';
      case 'typescript':
        return 'app.ts';
      case 'kotlin':
        return 'Main.kt';
      case 'swift':
        return 'main.swift';
      case 'java':
        return 'Main.java';
      case 'rust':
        return 'main.rs';
      case 'go':
        return 'main.go';
      case 'c':
        return 'main.c';
      case 'c++':
        return 'main.cpp';
      case 'bash':
        return 'run.sh';
      case 'html':
        return 'index.html';
      case 'css':
        return 'style.css';
      case 'sql':
        return 'query.sql';
      default:
        // Use the lowercased language name so the file is clearly identifiable
        return 'main.${lang.replaceAll('+', 'p').replaceAll(' ', '_')}.txt';
    }
  }

  bool _needsHtml(String lang) =>
      lang == 'javascript' || lang == 'typescript' || lang == 'html';

  bool _needsReadme(String lang) =>
      lang == 'python' || lang == 'dart' || lang == 'kotlin' ||
      lang == 'swift' || lang == 'java' || lang == 'rust' || lang == 'go' ||
      lang == 'c' || lang == 'c++';
}
