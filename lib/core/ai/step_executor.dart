import 'ai_engine.dart';

class StepExecutor {
  final AIEngine _ai = AIEngine();

  Future<List<String>> executeSteps(List<String> steps) async {
    List<String> results = [];

    for (final step in steps) {
      final result = await _ai.generate(step);
      results.add(result);
    }

    return results;
  }
}
