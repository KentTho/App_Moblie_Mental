import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mental_health_app/features/diary/core/constants.dart';
import 'package:mental_health_app/features/diary/widge/buildRow_newEdit.dart';
import 'package:mental_health_app/features/diary/widge/note_icon_button.dart';
import 'package:mental_health_app/features/diary/widge/note_icon_button_outlined.dart';
import 'package:mental_health_app/features/diary/widge/tag_show_row.dart';





class NewOrEditNotePage extends StatefulWidget {
  const NewOrEditNotePage({super.key});



  @override
  State<NewOrEditNotePage> createState() => _NewOrEditNotePageState();
}

class _NewOrEditNotePageState extends State<NewOrEditNotePage> {



  QuillController _controller = QuillController.basic();

  bool isInitialized = false;

  List<String> tags = [];


  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();
    setState(() {
      isInitialized = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
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
          onPressed: () {},
        ),
      ),
      title: Text('New note'),
      actions: [
        NoteIconButtonOutlined(
          icon: FontAwesomeIcons.pen,
          onPressed: () {},
        ),
        NoteIconButtonOutlined(
          icon: FontAwesomeIcons.check,
          onPressed: () {},
        ),
      ],
    ),
    body: SafeArea(
      child: Column(
        children: [
          // TIÊU ĐỀ
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: "Title Topic",
                hintStyle: TextStyle(color: gray300),
                border: InputBorder.none,
              ),
            ),
          ),

          // NGÀY
          BuildRowNewEdit(label: "Last Modified", value: "30 June 2025, 10:10"),
          BuildRowNewEdit(label: "Created", value: "29 June 2025, 18:45"),
          // TAGS
          TagShowRow(
            label: "Label", 
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

          // 🧠 PHẦN DƯỚI CÙNG: TOOLBAR + EDITOR
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: QuillEditor.basic(
                          controller: _controller,
                          config: QuillEditorConfig(
                            expands: true,
                            scrollable: true,
                            placeholder: "Note here ....",
                            autoFocus: false,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                QuillSimpleToolbar(
                  controller: _controller,
                  config: const QuillSimpleToolbarConfig(
                    showColorButton: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}



}