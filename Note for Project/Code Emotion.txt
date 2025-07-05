import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mental_health_app/features/diary/core/constants.dart';
import 'package:mental_health_app/features/diary/widge/note_icon_button.dart';
import 'package:mental_health_app/features/diary/widge/note_icon_button_outlined.dart';




class NewOrEditNotePage extends StatefulWidget {
  const NewOrEditNotePage({super.key});



  @override
  State<NewOrEditNotePage> createState() => _NewOrEditNotePageState();
}

class _NewOrEditNotePageState extends State<NewOrEditNotePage> {



  QuillController _controller = QuillController.basic();
  bool isInitialized = false;


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


  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: 
          Padding(
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
      body: Column(
        children: [
          TextField(
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
            decoration: InputDecoration(
              hintText: "Title Topic",
              hintStyle: TextStyle(color: gray300),
              border: InputBorder.none,
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Last Modified', 
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: gray500
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: 
                  Text('08 December 2024, 03:32',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Created',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: gray500
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: 
                  Text('08 December 2024, 03:32',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Text('Tags',
                      style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: gray500
                      ),
                    ),
                    NoteIconButton(
                      icon: FontAwesomeIcons.circlePlus, 
                      size: 24, 
                      onPressed: (){}
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: 
                Text('No tags added',
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                    ),
                )
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(
                color: gray500,
                thickness: 2,
            ),
          ),
          // 👇 PHẦN NÀY GIÚP TOOLBAR + EDITOR Ở DƯỚI VÀ CHIẾM TOÀN BỘ DIỆN TÍCH CÒN LẠI
          Expanded(
            child: Column(
              children: [
                QuillSimpleToolbar(
                  controller: _controller,
                  config: const QuillSimpleToolbarConfig(),
                ),
                Expanded(
                  child: QuillEditor.basic(
                    controller: _controller,
                    config: const QuillEditorConfig(
                      placeholder: 'Note here...',
                      expands: true,
                      scrollable: true, // 👈 có thể có hoặc không
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}