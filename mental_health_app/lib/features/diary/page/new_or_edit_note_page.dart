import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart'; // Editor rich-text
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Icon đẹp mắt
import 'package:mental_health_app/change_notifiers/new_note_controller.dart'; // Quản lý trạng thái ghi chú
import 'package:mental_health_app/features/diary/core/constants.dart'; // Chứa các giá trị hằng
// Hiển thị thông tin tạo/sửa ghi chú
import 'package:mental_health_app/features/diary/widge/confirmation_dialog.dart';
import 'package:mental_health_app/features/diary/widge/dialog_tags_card.dart'; // Hộp thoại xác nhận
// Nút bấm tuỳ chỉnh
import 'package:mental_health_app/features/diary/widge/note_icon_button_outlined.dart'; // Nút icon có viền
import 'package:mental_health_app/features/diary/widge/note_metadata_section.dart';
import 'package:mental_health_app/features/diary/widge/note_toolbar.dart'; // Thanh công cụ cho QuillEditor
import 'package:mental_health_app/change_notifiers/notes_provider.dart'; // Provider lưu danh sách ghi chú
import 'package:mental_health_app/models/note.dart'; // Model ghi chú
import 'package:mental_health_app/services/note_service.dart'; // Giao tiếp với backend
import 'package:provider/provider.dart'; // State management
import 'package:another_flushbar/flushbar.dart'; // Hiển thị thông báo dạng toast
// Định dạng thời gian

class NewOrEditNotePage extends StatefulWidget {
  final bool isNewNote; // true = ghi chú mới, false = chỉnh sửa
  final Note? note; // Nếu là chỉnh sửa thì truyền note

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
  TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();

    newNoteController = context.read<NewNoteController>();


    _titleController = TextEditingController(
      text: newNoteController.title,
    );
    // Khởi tạo controller cho nội dung ghi chú
    _controller = QuillController(
  document: Document()..insert(0, widget.note!.content ?? ''),
  selection: const TextSelection.collapsed(offset: 0),
)
..addListener(() {
  if (mounted) {
    newNoteController.content = _controller.document;
  }
});




    focusNode = FocusNode();

    // Sau khi widget dựng xong, quyết định trạng thái focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isNewNote) {
        newNoteController.readOnly = false;
        focusNode.requestFocus(); // Tự động focus nếu là ghi chú mới
      } else {
        newNoteController.readOnly = true;
        _controller.document = newNoteController.content;
      }
    });

    // // Nếu là chỉnh sửa ghi chú cũ, load nội dung và tag
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
    return PopScope(
      canPop: false,
      // Khi bấm back, sẽ hỏi người dùng có lưu ghi chú không
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if(!newNoteController.canSaveNote) {
          Navigator.pop(context);
          return;
        }
        final bool? shouldSave = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => DialogCard(
            onTagAdded: (tag) {},
            child: const Padding(
              padding: const EdgeInsets.all(16.0),
              child: ConfirmationDialog(),
            ),
          ),
        );


        if (shouldSave == null) return;
        if (!context.mounted) return;

        if (shouldSave) {
          newNoteController.saveNote(context);
        }

        Navigator.pop(context);
      },
      child: Scaffold(
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
            // Nút chuyển đổi chế độ chỉnh sửa / chỉ đọc
            Selector<NewNoteController, bool>(
              selector: (_, controller) => controller.readOnly,
              builder: (context, readOnly, _) => NoteIconButtonOutlined(
                icon: readOnly
                    ? FontAwesomeIcons.pen
                    : FontAwesomeIcons.bookOpen,
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

            // Nút lưu ghi chú
            Selector<NewNoteController, bool>(
              selector: (_, controller) => controller.canSaveNote,
              builder: (_, canSaveNote, __) => NoteIconButtonOutlined(
                icon: FontAwesomeIcons.check,
                onPressed: canSaveNote
                    ? () async {
                        // 1. Kiểm tra nếu đang ở chế độ chỉ đọc
                        if (newNoteController.readOnly) return;

                        // 2. Hiển thị hộp thoại xác nhận lưu
                        final shouldSave = await showDialog<bool>(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => DialogCard(
                              onTagAdded: (_) {},
                              child: const ConfirmationDialog(),
                            ),
                          );

                        // 3. Nếu người dùng chọn "No" thì không làm gì cả
                        if (shouldSave != true) return; // ❌ Không lưu nếu người dùng nhấn "No"


                         // 4. Lấy nội dung và tiêu đề ghi chú
                        final content =
                            _controller.document.toPlainText().trim();
                        final title = _titleController.text.trim();
                        if (content.isEmpty) return;

                        try {
                          // 5. Nếu là ghi chú mới → tạo mới
                          if (widget.isNewNote) {
                            await NoteService.createNote(
                              userId: newNoteController.userId,
                              title: title,
                              content: content,
                              contentJson: jsonEncode(_controller.document.toDelta().toJson()), // ✅ đúng định dạng JSON
                              tags: newNoteController.tags,
                            );
                            
                          }
                          // 6. Nếu là ghi chú cũ → cập nhật 
                          else {
                            await NoteService.updateNote(
                              noteId: widget.note!.id!, // ⚠️ Lấy id ghi chú cũ
                              title: title,
                              content: content,
                              tags: newNoteController.tags,
                            );
                          }

                          // 7. Tải lại danh sách ghi chú
                          // Refresh danh sách ghi chú
                          await context
                              .read<NotesProvider>()
                              .fetchNotes(newNoteController.userId);


                          // 8. Thông báo thành công
                          if (mounted) {
                            await Flushbar(
                              message: widget.isNewNote
                                  ? "📝 Ghi chú đã được tạo thành công!"
                                  : "✏️ Ghi chú đã được cập nhật!",
                              duration: const Duration(seconds: 2),
                              margin: const EdgeInsets.all(12),
                              borderRadius: BorderRadius.circular(8),
                              backgroundColor: Colors.green.shade600,
                              flushbarPosition: FlushbarPosition.TOP,
                              icon: const Icon(Icons.check_circle,
                                  color: Colors.white),
                            ).show(context);
                            // 9. Quay về màn trước đó
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          // 10. Nếu có lỗi → hiện thông báo lỗi
                          if (mounted) {
                            await Flushbar(
                              message: "❌ Lỗi khi lưu ghi chú: $e",
                              duration: const Duration(seconds: 3),
                              margin: const EdgeInsets.all(12),
                              borderRadius: BorderRadius.circular(8),
                              backgroundColor: Colors.red.shade700,
                              flushbarPosition: FlushbarPosition.TOP,
                              icon: const Icon(Icons.error,
                                  color: Colors.white),
                            ).show(context);
                          }
                        }
                      }
                    : null,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Ô nhập tiêu đề
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
                      hintStyle:
                          TextStyle(color: Color.fromARGB(137, 128, 128, 128)),
                      border: InputBorder.none,
                    ),
                    canRequestFocus: !readOnly,
                    onChanged: (newValue) =>
                        newNoteController.title = newValue,
                  ),
                ),
              ),

              // Chỉ hiện khi sửa ghi chú cũ
              NoteMetadataSection(
                isNewNote: widget.isNewNote,
                note: widget.note,
                tags: newNoteController.tags,
                onAddTag: (newTag) {
                  setState(() {
                    newNoteController.addTag(newTag);
                  });
                },
              ),

              // Phần nội dung ghi chú
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
                      // Hiện thanh công cụ nếu đang chỉnh sửa
                      if (!readOnly) NoteToolbar(controller: _controller),
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
}
