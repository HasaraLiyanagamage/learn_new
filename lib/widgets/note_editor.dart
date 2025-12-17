import 'package:flutter/material.dart';
import '../core/models/note_model.dart';

class NoteEditor extends StatefulWidget {
  final NoteModel? note;
  final Function(String title, String content) onSave;

  const NoteEditor({
    super.key,
    this.note,
    required this.onSave,
  });

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Content field
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
                maxLines: 15,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Formatting toolbar
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.format_bold),
                        onPressed: () => _insertFormatting('**', '**'),
                        tooltip: 'Bold',
                      ),
                      IconButton(
                        icon: const Icon(Icons.format_italic),
                        onPressed: () => _insertFormatting('_', '_'),
                        tooltip: 'Italic',
                      ),
                      IconButton(
                        icon: const Icon(Icons.format_list_bulleted),
                        onPressed: () => _insertFormatting('• ', ''),
                        tooltip: 'Bullet List',
                      ),
                      IconButton(
                        icon: const Icon(Icons.format_list_numbered),
                        onPressed: () => _insertFormatting('1. ', ''),
                        tooltip: 'Numbered List',
                      ),
                      IconButton(
                        icon: const Icon(Icons.code),
                        onPressed: () => _insertFormatting('`', '`'),
                        tooltip: 'Code',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _insertFormatting(String prefix, String suffix) {
    final text = _contentController.text;
    final selection = _contentController.selection;
    final selectedText = text.substring(selection.start, selection.end);
    
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      '$prefix$selectedText$suffix',
    );
    
    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + prefix.length + selectedText.length + suffix.length,
      ),
    );
  }

  void _saveNote() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(_titleController.text, _contentController.text);
      Navigator.pop(context);
    }
  }
}
