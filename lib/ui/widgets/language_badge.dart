import 'package:flutter/material.dart';

/// A small coloured chip that shows the project's programming language.
class LanguageBadge extends StatelessWidget {
  final String language;

  const LanguageBadge({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    final color = _colorForLanguage(language);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(120)),
      ),
      child: Text(
        language,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _colorForLanguage(String lang) {
    switch (lang.toLowerCase()) {
      case 'dart':
        return const Color(0xFF00B4D8);
      case 'python':
        return const Color(0xFF3A86FF);
      case 'javascript':
        return const Color(0xFFF4A261);
      case 'typescript':
        return const Color(0xFF2E9CDB);
      case 'kotlin':
        return const Color(0xFF7B2FBE);
      case 'swift':
        return const Color(0xFFFA5C4B);
      case 'java':
        return const Color(0xFFE63946);
      case 'rust':
        return const Color(0xFFB07229);
      case 'go':
        return const Color(0xFF06D6A0);
      case 'c':
      case 'c++':
        return const Color(0xFF6A4C93);
      case 'html':
        return const Color(0xFFE44D26);
      case 'css':
        return const Color(0xFF264DE4);
      case 'bash':
        return const Color(0xFF4CAF50);
      case 'sql':
        return const Color(0xFFFF9F1C);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}
