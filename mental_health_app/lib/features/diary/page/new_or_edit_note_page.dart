import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:mental_health_app/features/diary/core/constants.dart';
import 'package:provider/provider.dart';
import 'package:mental_health_app/change_notifiers/new_note_controller.dart';
// Import constants

class NewOrEditNotePage extends StatefulWidget {
  final bool isNewNote;

  const NewOrEditNotePage({super.key, required this.isNewNote});

  @override
  State<NewOrEditNotePage> createState() => _NewOrEditNotePageState();
}

class _NewOrEditNotePageState extends State<NewOrEditNotePage> {
  late QuillController _quillController;
  late TextEditingController _titleController;
  late TextEditingController _tagController;
  late NewNoteController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = context.read<NewNoteController>(); // Get existing controller from provider
    _titleController = TextEditingController(text: _noteController.title);
    _tagController = TextEditingController(
      text: _noteController.tags.isNotEmpty ? _noteController.tags.first : '',
    );


    _quillController = QuillController(
      document: _noteController.content,
      selection: const TextSelection.collapsed(offset: 0),
    );

    _quillController.addListener(() {
      _noteController.content = _quillController.document;
    });

    _titleController.addListener(() {
      _noteController.title = _titleController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNewNote ? 'New Note' : 'Edit Note'),
        backgroundColor: primaryColor, // Consistent with EmotionEntry
        foregroundColor: Colors.white,
        actions: [
          Consumer<NewNoteController>(
            builder: (context, controller, child) {
              return TextButton(
                onPressed: controller.canSaveNote
                    ? () async {
                        if (widget.isNewNote) {
                          controller.saveNote(context);
                        } else {
                          await controller.updateNote(context, controller.id!);
                        }

                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    : null,
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: controller.canSaveNote ? Colors.white : Colors.white54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Title input
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Note title...',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 24, color: gray500), // Consistent with EmotionEntry
              ),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              maxLines: null,
            ),
          ),

          // Tags section
          Consumer<NewNoteController>(
            builder: (context, controller, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Add tag input
                    Row(
                    children: [
                      // Input tag
                      Expanded(
                        child: TextField(
                          controller: _tagController,
                          decoration: InputDecoration(
                            labelText: 'Thêm thẻ (tag)',
                            hintText: 'Ví dụ: stress, công việc',
                            prefixIcon: const Icon(Icons.tag),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            hintStyle: TextStyle(color: gray500),
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

                      // Add tag button - redesigned
                      FilledButton.icon(
                        onPressed: () {
                          if (_tagController.text.trim().isNotEmpty) {
                            controller.addTag(_tagController.text.trim());
                            _tagController.clear();
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm'),
                        style: FilledButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          textStyle: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                    // Display tags
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
                            backgroundColor: primaryColor.withOpacity(0.1), // Consistent
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 16),
          QuillSimpleToolbar(
            controller: _quillController,
            config: QuillSimpleToolbarConfig(
              multiRowsDisplay: false,
            showFontFamily: false,
            showFontSize: false,
            showBoldButton: true,
            showItalicButton: true,
            showUnderLineButton: true,
            showStrikeThrough: false,
            showInlineCode: false,
            showColorButton: false,
            showBackgroundColorButton: false,
            showClearFormat: false,
            showAlignmentButtons: false,
            showLeftAlignment: false,
            showCenterAlignment: false,
            showRightAlignment: false,
            showJustifyAlignment: false,
            showHeaderStyle: false,
            showListNumbers: true,
            showListBullets: true,
            showListCheck: false,
            showCodeBlock: false,
            showQuote: false,
            showIndent: false,
            showLink: false,
            showUndo: true,
            showRedo: true,
            showDirection: false,
            showSearchButton: false,
            ),
          ),     

          const Divider(height: 1),

          // Content editor
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: QuillEditor(
                controller: _quillController,
                config: QuillEditorConfig(
                   placeholder: 'Start writing your thoughts...',
                autoFocus: false,
                expands: true,
                ), focusNode: FocusNode(), scrollController: ScrollController(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveNote() async {
    try {
      if (!widget.isNewNote) { // If editing existing note
        await _noteController.updateNote(context, _noteController.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note updated successfully')),
          );
        }
      } else { // If creating new note
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
    // _noteController.dispose(); // Controller is provided by parent, don't dispose here
    super.dispose();
  }
}
