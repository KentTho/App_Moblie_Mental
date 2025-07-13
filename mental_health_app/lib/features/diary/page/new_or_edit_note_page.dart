import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mental_health_app/change_notifiers/new_note_controller.dart';
import 'package:mental_health_app/features/diary/core/constants.dart';
import 'package:mental_health_app/features/diary/widge/buildRow_newEdit.dart';
import 'package:mental_health_app/features/diary/widge/note_icon_button_outlined.dart';
import 'package:mental_health_app/features/diary/widge/note_toolbar.dart';
import 'package:mental_health_app/features/diary/widge/tag_show_row.dart';
import 'package:mental_health_app/change_notifiers/notes_provider.dart';
import 'package:mental_health_app/models/note.dart';
import 'package:mental_health_app/services/note_service.dart';
import 'package:provider/provider.dart';

class NewOrEditNotePage extends StatefulWidget {
  final bool isNewNote;
  final Note? note;

  const NewOrEditNotePage({
    required this.isNewNote,
    this.note,
    super.key,
  });

  @override
  State<NewOrEditNotePage> createState() => _NewOrEditNotePageState();
}

class _NewOrEditNotePageState extends State<NewOrEditNotePage> {
  late final NewNoteController newNoteController;
  late QuillController _controller;
  late FocusNode focusNode;
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();

    newNoteController = context.read<NewNoteController>();
    _controller = QuillController.basic()..addListener(() {
      newNoteController.content = _controller.document;
    });

    focusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isNewNote) {
        newNoteController.readOnly = false;
        focusNode.requestFocus();
      } else {
        newNoteController.readOnly = true;
      }
    });

    if (!widget.isNewNote && widget.note != null) {
      _titleController.text = widget.note!.title;
      _controller = QuillController(
        document: Document()..insert(0, widget.note!.content ?? ''),
        selection: const TextSelection.collapsed(offset: 0),
      );
      for (var tag in widget.note!.tags) {
        newNoteController.addTag(tag);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    focusNode.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: NoteIconButtonOutlined(
            icon: FontAwesomeIcons.chevronLeft,
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        title: Text(widget.isNewNote ? 'New note' : 'Edit note'),
        titleTextStyle: const TextStyle(
          color: primaryColor,
          fontSize: 32,
          fontFamily: 'Fredo',
          fontWeight: FontWeight.bold,
        ),
        actions: [
          Selector<NewNoteController, bool>(
            selector: (_, controller) => controller.readOnly,
            builder: (context, readOnly, _) => NoteIconButtonOutlined(
              icon: readOnly ? FontAwesomeIcons.pen : FontAwesomeIcons.bookOpen,
              onPressed: () {
                newNoteController.readOnly = !readOnly;
                if (newNoteController.readOnly) {
                  FocusScope.of(context).unfocus();
                } else {
                  focusNode.requestFocus();
                }
              },
            ),
          ),
          NoteIconButtonOutlined(
            icon: FontAwesomeIcons.check,
            onPressed: () async {
              if (newNoteController.readOnly) return;

              final content = _controller.document.toPlainText().trim();
              final title = _titleController.text.trim();

              if (content.isEmpty) return;

              try {
                await NoteService.createNote(
                  userId: newNoteController.userId,
                  title: title,
                  content: content,
                  tags: newNoteController.tags,
                );

                await context.read<NotesProvider>().fetchNotes(
                    newNoteController.userId);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('📝 Ghi chú đã được tạo thành công!'),
                    ),
                  );
                  Navigator.pop(context);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Lỗi khi tạo ghi chú: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Selector<NewNoteController, bool>(
                selector: (_, controller) => controller.readOnly,
                builder: (_, readOnly, __) => TextField(
                  controller: _titleController,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    hintText: "Title Topic",
                    hintStyle: TextStyle(
                      color: Color.fromARGB(137, 128, 128, 128),
                    ),
                    border: InputBorder.none,
                  ),
                  canRequestFocus: !readOnly,
                  onChanged: (newValue) =>
                      newNoteController.title = newValue,
                ),
              ),
            ),

            if (!widget.isNewNote) ...[
              const BuildRowNewEdit(
                label: "Last Modified",
                value: "30 June 2025, 10:10",
              ),
              const BuildRowNewEdit(
                label: "Created",
                value: "29 June 2025, 18:45",
              ),
            ],

            TagShowRow(
              label: "Tags",
              tags: newNoteController.tags,
              onAddTag: (newTag) {
                setState(() {
                  newNoteController.addTag(newTag);
                });
              },
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(color: Colors.grey, thickness: 1),
            ),

            Expanded(
              child: Selector<NewNoteController, bool>(
                selector: (_, controller) => controller.readOnly,
                builder: (_, readOnly, __) => Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: QuillEditor(
                          controller: _controller,
                          scrollController: ScrollController(),
                          focusNode: focusNode,
                          config: QuillEditorConfig(
                            expands: true,
                            checkBoxReadOnly: readOnly,
                            scrollable: true,
                            placeholder: "Note here ....",
                            autoFocus: false,
                            padding: EdgeInsets.zero,
                            enableInteractiveSelection: true,
                            scrollBottomInset: 100,
                          ),
                        ),
                      ),
                    ),
                    if (!readOnly)
                      NoteToolbar(controller: _controller),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
