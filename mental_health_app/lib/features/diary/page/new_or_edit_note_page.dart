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

class _NewOrEditNotePageState extends State<NewOrEditNotePage>
    with TickerProviderStateMixin {
  late QuillController _quillController;
  late TextEditingController _titleController;
  late TextEditingController _tagController;
  late NewNoteController _noteController;

  // Animation: đồng bộ hiệu ứng với các màn trước (fade + slide)
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    // Animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // nền đồng bộ
      appBar: AppBar(
        backgroundColor: Colors.white, // AppBar trắng
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          widget.isNewNote ? 'New Note' : 'Edit Note',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20, // đồng bộ với các màn
            fontWeight: FontWeight.bold,
          ),
        ),
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
                    color: controller.canSaveNote ? primaryColor : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Title input (card trắng + shadow nhẹ)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Note title...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 18, color: gray500),
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: null,
                ),
              ),

              // Tags section
              Consumer<NewNoteController>(
                builder: (context, controller, child) {
                  return Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Add tag input + button (đồng bộ style, bo góc)
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
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  hintStyle: const TextStyle(color: gray500),
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

                            // Add tag button
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 14),
                                textStyle: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),

                        // Display tags (Chip màu nhẹ)
                        if (controller.tags.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: controller.tags
                                .asMap()
                                .entries
                                .map((entry) {
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
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Toolbar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: QuillSimpleToolbar(
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
              ),

              const Divider(height: 1),

              // Content editor (card trắng + shadow nhẹ)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: QuillEditor(
                    controller: _quillController,
                    config: const QuillEditorConfig(
                      placeholder: 'Start writing your thoughts...',
                      autoFocus: false,
                      expands: true,
                    ),
                    focusNode: FocusNode(),
                    scrollController: ScrollController(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // (Giữ nguyên — hiện không được gọi trong AppBar nhưng có thể dùng lại nếu bạn muốn)
  void _saveNote() async {
    try {
      if (!widget.isNewNote) {
        await _noteController.updateNote(context, _noteController.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note updated successfully')),
          );
        }
      } else {
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
    _animationController.dispose();
    _quillController.dispose();
    _titleController.dispose();
    _tagController.dispose();
    // _noteController.dispose(); // Controller is provided by parent, don't dispose here
    super.dispose();
  }
}
