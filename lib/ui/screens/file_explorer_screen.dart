import 'dart:io';
import 'package:flutter/material.dart';

import '../../data/files/file_manager.dart';

// ── File Explorer ──────────────────────────────────────────────────────────

class FileExplorerScreen extends StatefulWidget {
  final String projectId;

  const FileExplorerScreen({super.key, required this.projectId});

  @override
  State<FileExplorerScreen> createState() => _FileExplorerScreenState();
}

class _FileExplorerScreenState extends State<FileExplorerScreen> {
  final FileManager _files = FileManager();
  List<File> _items = [];

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    final entities = await _files.listFiles(widget.projectId);
    // Only surface regular files — directories are not yet supported in the
    // file editor, so they are intentionally excluded here.
    setState(() => _items = entities.whereType<File>().toList());
  }

  void _openFile(File file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FileEditorScreen(
          projectId: widget.projectId,
          file: file,
        ),
      ),
    ).then((_) => _loadFiles());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Project Files')),
      body: _items.isEmpty
          ? const Center(child: Text('No files yet.'))
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final name = _items[i].path.split('/').last;
                return ListTile(
                  leading: const Icon(Icons.insert_drive_file_outlined),
                  title: Text(name),
                  onTap: () => _openFile(_items[i]),
                );
              },
            ),
    );
  }
}

// ── File Editor ────────────────────────────────────────────────────────────

class FileEditorScreen extends StatefulWidget {
  final String projectId;
  final File file;

  const FileEditorScreen({
    super.key,
    required this.projectId,
    required this.file,
  });

  @override
  State<FileEditorScreen> createState() => _FileEditorScreenState();
}

class _FileEditorScreenState extends State<FileEditorScreen> {
  final FileManager _files = FileManager();
  late final TextEditingController _controller;

  bool _loading = true;
  bool _hasChanges = false;
  bool _saving = false;

  String get _fileName => widget.file.path.split('/').last;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _loadContent();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    final content = await _files.readFile(
      projectId: widget.projectId,
      fileName: _fileName,
    );
    if (!mounted) return;
    setState(() {
      _controller.text = content;
      _loading = false;
    });
    _controller.addListener(() {
      if (!_hasChanges) setState(() => _hasChanges = true);
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await _files.writeFile(
      projectId: widget.projectId,
      fileName: _fileName,
      content: _controller.text,
    );
    if (!mounted) return;
    setState(() {
      _saving = false;
      _hasChanges = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saved ✓'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_fileName),
        actions: [
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
                color: _hasChanges ? theme.colorScheme.primary : null,
              ),
              tooltip: 'Save',
              onPressed: _save,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                  hintText: '// Edit file here…',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),
      floatingActionButton: _hasChanges
          ? FloatingActionButton(
              onPressed: _save,
              child: const Icon(Icons.save),
            )
          : null,
    );
  }
}
