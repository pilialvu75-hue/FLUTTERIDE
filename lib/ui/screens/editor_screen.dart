import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/project.dart';
import '../../core/orchestrator.dart';
import 'file_explorer_screen.dart';

/// Full-screen code editor for a single [Project].
class EditorScreen extends StatefulWidget {
  final Project project;
  final ProjectOrchestrator orchestrator;

  const EditorScreen({
    super.key,
    required this.project,
    required this.orchestrator,
  });

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late final TextEditingController _controller;
  bool _hasUnsavedChanges = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.project.content);
    _controller.addListener(() {
      if (!_hasUnsavedChanges && _controller.text != widget.project.content) {
        setState(() => _hasUnsavedChanges = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await widget.orchestrator.saveContent(widget.project, _controller.text);
    setState(() {
      _saving = false;
      _hasUnsavedChanges = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saved locally ✓'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unsaved changes'),
        content: const Text('Do you want to save before leaving?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Discard'),
          ),
          TextButton(
            onPressed: () async {
              await _save();
              if (ctx.mounted) Navigator.of(ctx).pop(true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _copyAll() {
    Clipboard.setData(ClipboardData(text: _controller.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          final canLeave = await _onWillPop();
          if (canLeave && context.mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.project.name,
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                widget.project.language,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.folder_open_outlined),
              tooltip: 'Browse files',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        FileExplorerScreen(projectId: widget.project.id),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: 'Copy all',
              onPressed: _copyAll,
            ),
            if (_saving)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              IconButton(
                icon: Icon(
                  Icons.save,
                  color: _hasUnsavedChanges
                      ? theme.colorScheme.primary
                      : null,
                ),
                tooltip: 'Save (Ctrl+S)',
                onPressed: _save,
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: _controller,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            keyboardType: TextInputType.multiline,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
            ),
            decoration: const InputDecoration(
              hintText: '// Start coding here…',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
            // Allow Ctrl+S shortcut on desktop
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
          ),
        ),
        // Keyboard shortcut: Ctrl+S to save
        floatingActionButton: _hasUnsavedChanges
            ? FloatingActionButton.extended(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Save'),
              )
            : null,
      ),
    );
  }
}
