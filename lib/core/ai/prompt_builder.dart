class PromptBuilder {
  static String createProjectPrompt(String name, String lang) {
    return """
Create a new project:

Name: $name
Language: $lang

Generate:
- folder structure
- base files
- starter code
""";
  }
}
