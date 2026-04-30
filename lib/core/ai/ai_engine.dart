/// AI engine — fully offline.
/// Generates boilerplate code locally based on the prompt.
/// No HTTP calls, no external dependencies.
class AIEngine {
  Future<String> generate(String prompt) async {
    return _offlineGenerate(prompt);
  }

  String _offlineGenerate(String prompt) {
    final lower = prompt.toLowerCase();

    // Project creation prompt from PromptBuilder
    if (lower.contains('create') || lower.contains('project')) {
      final langMatch = RegExp(r'language:\s*(\w+)', caseSensitive: false)
          .firstMatch(prompt);
      final lang = langMatch?.group(1) ?? 'code';
      return _stubForLanguage(lang.toLowerCase());
    }

    if (lower.contains('ui') || lower.contains('layout')) {
      return _uiStub();
    }

    if (lower.contains('logic') || lower.contains('feature')) {
      return '// Logic placeholder\n// Implement your business logic here.\n';
    }

    return '// Generated locally — no internet required.\n';
  }

  String _stubForLanguage(String lang) {
    switch (lang) {
      case 'dart':
        return 'void main() {\n  print(\'Hello, World!\');\n}\n';
      case 'python':
        return 'def main():\n    print("Hello, World!")\n\nif __name__ == "__main__":\n    main()\n';
      case 'javascript':
      case 'typescript':
        return 'function main() {\n  console.log("Hello, World!");\n}\n\nmain();\n';
      case 'kotlin':
        return 'fun main() {\n    println("Hello, World!")\n}\n';
      case 'swift':
        return 'import Foundation\n\nprint("Hello, World!")\n';
      case 'java':
        return 'public class Main {\n    public static void main(String[] args) {\n        System.out.println("Hello, World!");\n    }\n}\n';
      case 'rust':
        return 'fn main() {\n    println!("Hello, World!");\n}\n';
      case 'go':
        return 'package main\n\nimport "fmt"\n\nfunc main() {\n    fmt.Println("Hello, World!")\n}\n';
      case 'c':
        return '#include <stdio.h>\n\nint main() {\n    printf("Hello, World!\\n");\n    return 0;\n}\n';
      case 'c++':
        return '#include <iostream>\n\nint main() {\n    std::cout << "Hello, World!" << std::endl;\n    return 0;\n}\n';
      case 'html':
        return '<!DOCTYPE html>\n<html lang="en">\n<head>\n  <meta charset="UTF-8">\n  <title>My App</title>\n</head>\n<body>\n  <h1>Hello, World!</h1>\n</body>\n</html>\n';
      case 'bash':
        return '#!/bin/bash\necho "Hello, World!"\n';
      default:
        return '// Hello, World! — $lang project\n// Add your code here.\n';
    }
  }

  String _uiStub() {
    return '<!-- UI layout placeholder -->\n<div id="app">\n  <header>Header</header>\n  <main>Content</main>\n  <footer>Footer</footer>\n</div>\n';
  }
}
