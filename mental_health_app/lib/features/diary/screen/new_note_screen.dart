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

class _NewNoteScreenState extends State<NewNoteScreen>
    with TickerProviderStateMixin {
  late QuillController _quillController;
  late TextEditingController _titleController;
  late TextEditingController _tagController;
  late NewNoteController _noteController;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> suggestedTopics = [
    'Công việc',
    'Tình cảm',
    'Gia đình',
    'Học tập',
    'Sức khỏe',
    'Tài chính',
    'Mối quan hệ',
    'Khác',
  ];
  final TextEditingController _customTagController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();

    _noteController = NewNoteController();
    _titleController = TextEditingController();
    _tagController = TextEditingController();

    final authProvider = context.read<AuthProvider>();
    _noteController.userId = authProvider.userId!;

    if (widget.note != null) {
      _noteController.note = widget.note;
      _titleController.text = widget.note!.title;
      _noteController.resetNotes(
        widget.note!.tags,
        [widget.note!.title],
      );
      _quillController = QuillController(
        document: Document.fromJson(widget.note!.content as List),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } else {
      _noteController.clear();
      _quillController = QuillController.basic();
    }

    _quillController.addListener(() {
      _noteController.content = _quillController.document;
    });

    _titleController.addListener(() {
      _noteController.title = _titleController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NewNoteController>(
      create: (_) => _noteController,
      child: Theme(
        data: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
          scaffoldBackgroundColor: Colors.grey[100],
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
          ),
        ),
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              widget.note != null ? 'Edit Note ✏️' : 'New Note 📝',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              Consumer<NewNoteController>(
                builder: (context, controller, child) {
                  return TextButton(
                    onPressed: controller.canSaveNote ? _saveNote : null,
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: controller.canSaveNote
                            ? primaryColor
                            : Colors.grey,
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // Title input
                    Container(
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
                          contentPadding: EdgeInsets.all(12),
                          hintText: 'Note title...',
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: null,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tags section
                    Expanded(
                      child: SingleChildScrollView(
                        child: Consumer<NewNoteController>(
                          builder: (context, controller, child) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _tagController,
                                        decoration: InputDecoration(
                                          hintText: 'Add tag...',
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 8),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide.none,
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
                                        if (_tagController.text
                                            .trim()
                                            .isNotEmpty) {
                                          controller.addTag(
                                              _tagController.text.trim());
                                          _tagController.clear();
                                        }
                                      },
                                      icon: const Icon(Icons.add,
                                          color: primaryColor),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Suggested topics
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 4.0,
                                  children: suggestedTopics.map((topic) {
                                    return ChoiceChip(
                                      label: Text(topic),
                                      selected:
                                          controller.tags.contains(topic),
                                      onSelected: (bool selected) {
                                        if (selected) {
                                          controller.addTag(topic);
                                        } else {
                                          controller.tags.remove(topic);
                                          controller.notifyListeners();
                                        }
                                      },
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 8),

                                // Custom tag input
                                TextField(
                                  controller: _customTagController,
                                  decoration: InputDecoration(
                                    labelText:
                                        'Tự nhập tag (nếu không có trong danh sách)',
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        final newTag =
                                            _customTagController.text.trim();
                                        if (newTag.isNotEmpty &&
                                            !controller.tags
                                                .contains(newTag)) {
                                          controller.addTag(newTag);
                                          _customTagController.clear();
                                        }
                                      },
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  onSubmitted: (value) {
                                    final newTag = value.trim();
                                    if (newTag.isNotEmpty &&
                                        !controller.tags.contains(newTag)) {
                                      controller.addTag(newTag);
                                      _customTagController.clear();
                                    }
                                  },
                                ),

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
                                        deleteIcon: const Icon(Icons.close,
                                            size: 18),
                                        onDeleted: () =>
                                            controller.removeTag(index),
                                        backgroundColor:
                                            primaryColor.withOpacity(0.1),
                                      );
                                    }).toList(),
                                  ),
                                ],
                                const SizedBox(height: 12),

                                // Quill editor
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
                                SizedBox(
                                  height: 300,
                                  child: QuillEditor.basic(
                                    controller: _quillController,
                                    config: const QuillEditorConfig(
                                      placeholder:
                                          'Start writing your thoughts...',
                                      autoFocus: false,
                                      expands: false,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveNote() async {
    try {
      if (widget.note != null) {
        await _noteController.updateNote(context, widget.note!.id!);
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
    _customTagController.dispose();
    super.dispose();
  }
}
