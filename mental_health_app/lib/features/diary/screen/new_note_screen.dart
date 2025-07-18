import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:mental_health_app/change_notifiers/auth_provider.dart';
import 'package:mental_health_app/change_notifiers/new_note_controller.dart';
import 'package:mental_health_app/features/diary/core/constants.dart';
import 'package:mental_health_app/models/note.dart';
import 'package:provider/provider.dart';

class NewNoteScreen extends StatefulWidget {
  final Note? note;
  
  const NewNoteScreen({super.key, this.note});

  @override
  State<NewNoteScreen> createState() => _NewNoteScreenState();
}

class _NewNoteScreenState extends State<NewNoteScreen> {
  late QuillController _quillController;
  late TextEditingController _titleController;
  late TextEditingController _tagController;
  late NewNoteController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = NewNoteController();
    _titleController = TextEditingController();
    _tagController = TextEditingController();
    
    // Set userId from AuthProvider
    final authProvider = context.read<AuthProvider>();
    _noteController.userId = authProvider.userId;
    
    // If editing existing note
    if (widget.note != null) {
      _noteController.note = widget.note;
      _titleController.text = widget.note!.title;
    }
    
    _quillController = QuillController(
      document: _noteController.content,
      selection: const TextSelection.collapsed(offset: 0),
    );
    
    // Listen to content changes
    _quillController.addListener(() {
      _noteController.content = _quillController.document;
    });
    
    // Listen to title changes
    _titleController.addListener(() {
      _noteController.title = _titleController.text;
    });
  }

  @override
Widget build(BuildContext context) {
  return ChangeNotifierProvider.value(
    value: _noteController,
    child: Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.note != null ? 'Edit Note ✏️' : 'New Note 📝',
            style: const TextStyle(
              color: primaryColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Fredo',
            ),
          ),
          centerTitle: false,
          actions: [
            Consumer<NewNoteController>(
              builder: (context, controller, child) {
                return TextButton(
                  onPressed: controller.canSaveNote ? _saveNote : null,
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: controller.canSaveNote ? primaryColor : gray500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // Title input
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Note title...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 24, color: gray500),
                ),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: null,
              ),
              const SizedBox(height: 8),
              // Tags
              Consumer<NewNoteController>(
                builder: (context, controller, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _tagController,
                              decoration: const InputDecoration(
                                hintText: 'Add tag...',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              onSubmitted: (value) {
                                if (value.trim().isNotEmpty) {
                                  controller.addTag(value.trim());
                                  _tagController.clear();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              if (_tagController.text.trim().isNotEmpty) {
                                controller.addTag(_tagController.text.trim());
                                _tagController.clear();
                              }
                            },
                            icon: const Icon(Icons.add, color: primaryColor),
                          ),
                        ],
                      ),
                      if (controller.tags.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: controller.tags.asMap().entries.map((entry) {
                            final index = entry.key;
                            final tag = entry.value;
                            return Chip(
                              label: Text(tag),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () => controller.removeTag(index),
                              backgroundColor: primaryColor.withOpacity(0.1),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              QuillSimpleToolbar(
                controller: _quillController,
                config: const QuillSimpleToolbarConfig(
                  showBoldButton: true,
                  showItalicButton: true,
                  showUnderLineButton: true,
                  showListNumbers: true,
                  showListBullets: true,
                  showUndo: true,
                  showRedo: true,
                ),
              ),
              const Divider(),
              Expanded(
                child: QuillEditor.basic(
                  controller: _quillController,
                  config: const QuillEditorConfig(
                    placeholder: 'Start writing your thoughts...',
                    autoFocus: false,
                    expands: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}


  void _saveNote() async {
    try {
      if (widget.note != null) {
        // Update existing note
        await _noteController.updateNote(context, widget.note!.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note updated successfully')),
          );
        }
      } else {
        // Create new note
        _noteController.saveNote(context);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note saved successfully')),
          );
        }
      }
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving note: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _quillController.dispose();
    _titleController.dispose();
    _tagController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
