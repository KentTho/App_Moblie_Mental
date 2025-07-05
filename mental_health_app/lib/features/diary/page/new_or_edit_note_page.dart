import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mental_health_app/features/diary/core/constants.dart';
import 'package:mental_health_app/features/diary/widge/buildRow_newEdit.dart';
import 'package:mental_health_app/features/diary/widge/note_icon_button_outlined.dart';
import 'package:mental_health_app/features/diary/widge/note_toolbar.dart';
import 'package:mental_health_app/features/diary/widge/tag_show_row.dart';

class NewOrEditNotePage extends StatefulWidget {
  const NewOrEditNotePage({
    required this.isNewNote,
    super.key,
  });

  final bool isNewNote;

  @override
  State<NewOrEditNotePage> createState() => _NewOrEditNotePageState();
}

class _NewOrEditNotePageState extends State<NewOrEditNotePage> {
  late QuillController _controller;
  late FocusNode focusNode;

  bool isInitialized = false;
  bool readOnly = true;

  List<String> tags = [];

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();
    focusNode = FocusNode();

    // Nếu là note mới → focus & editable
    if (widget.isNewNote) {
      focusNode.requestFocus();
      readOnly = false;
    }

    isInitialized = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Nút quay lại
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: NoteIconButtonOutlined(
            icon: FontAwesomeIcons.chevronLeft,
            onPressed: () {
              Navigator.maybePop(context);
            },
          ),
        ),

        // Tiêu đề AppBar
        title: Text(widget.isNewNote ? 'New note' : 'Edit note'),
        titleTextStyle: TextStyle(
          color: primaryColor,
          fontSize: 32,
          fontFamily: 'Fredo',
          fontWeight: FontWeight.bold,
        ),

        // Các nút điều khiển trạng thái đọc / lưu
        actions: [
          NoteIconButtonOutlined(
            icon: readOnly ? FontAwesomeIcons.pen : FontAwesomeIcons.bookOpen,
            onPressed: () {
              setState(() {
                readOnly = !readOnly;
                if (readOnly) {
                  FocusScope.of(context).unfocus();
                } else {
                  focusNode.requestFocus();
                }
              });
            },
          ),
          NoteIconButtonOutlined(
            icon: FontAwesomeIcons.check,
            onPressed: () {
              // TODO: implement save note logic
            },
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            // 📝 TIÊU ĐỀ NOTE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: "Title Topic",
                  hintStyle: TextStyle(
                    color: const Color.fromARGB(137, 128, 128, 128),
                  ),
                  border: InputBorder.none,
                ),
                canRequestFocus: !readOnly,
              ),
            ),

            // 🗓️ NGÀY GIỜ CHỈ KHI EDIT NOTE
            if (!widget.isNewNote) ...[
              BuildRowNewEdit(
                label: "Last Modified",
                value: "30 June 2025, 10:10",
              ),
              BuildRowNewEdit(
                label: "Created",
                value: "29 June 2025, 18:45",
              ),
            ],

            // 🏷️ TAGS
            TagShowRow(
              label: "Tags",
              tags: tags,
              onAddTag: () {
                setState(() {
                  tags.add("NewTag");
                });
              },
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(color: Colors.grey, thickness: 1),
            ),

            // ✏️ TRÌNH SOẠN THẢO NOTE
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Padding(
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
                      ],
                    ),
                  ),

                  // 📌 THANH CÔNG CỤ CHỈ HIỆN KHI CHỈNH SỬA
                  if (!readOnly)
                    NoteToolbar(controller: _controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
