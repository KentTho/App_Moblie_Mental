import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mental_health_app/change_notifiers/new_note_controller.dart';
import 'package:mental_health_app/change_notifiers/notes_provider.dart';
import 'package:mental_health_app/features/diary/core/constants.dart';
import 'package:mental_health_app/features/diary/page/new_or_edit_note_page.dart';
import 'package:mental_health_app/features/diary/widge/no_notes.dart';
import 'package:mental_health_app/features/diary/widge/note_fab.dart';
import 'package:mental_health_app/features/diary/page/search_field.dart';
import 'package:mental_health_app/features/diary/widge/note_icon_button.dart';
import 'package:mental_health_app/features/diary/widge/note_icon_button_outlined.dart';
import 'package:mental_health_app/features/home/homepage.dart';
import 'package:mental_health_app/models/note.dart';
import 'package:provider/provider.dart';
import '../widge/note_grid.dart';
import '../widge/notes_list.dart';

class EmotionEntry extends StatefulWidget {
  const EmotionEntry({super.key});

  @override
  
  State<EmotionEntry> createState() => _EmotionEntryState();


}

class _EmotionEntryState extends State<EmotionEntry> {
  // Danh sách tùy chọn cho dropdown menu
  final List<String> dropdownOptions = ['Data modified', 'Date created'];

  // Giá trị được chọn mặc định
  late String dropdownValue = dropdownOptions.first;

  // Trạng thái sắp xếp giảm dần
  bool isDescending = true;

  // Hiển thị dạng lưới hoặc danh sách
  bool isGrid = true;


@override
void initState() {
  super.initState();

  // ✅ Gọi fetchNotes tại đây (userId = 1 ví dụ)
  Future.microtask(() {
    final provider = context.read<NotesProvider>();
    provider.fetchNotes("1"); // Truyền đúng userId của người dùng đang đăng nhập
  });

  
}

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: background,
      ),
      child: Scaffold(
        
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          title: const Text("Emotion Entry 📒"),
          titleTextStyle: TextStyle(
            color: primaryColor,
            fontSize: 32,
            fontFamily: 'Fredo',
            fontWeight: FontWeight.bold,
          ),
          actions: [
            // Nút đăng xuất → về trang chính
            NoteIconButtonOutlined(
              icon: FontAwesomeIcons.rightFromBracket,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const Homepage()),
                );
              },
            ),
          ],
        ),

        // Nút tạo note mới
        floatingActionButton: NoteFab(
          onPressed: () {
            final controller = NewNoteController();
            controller.userId = "1"; // ✅ Giả sử đây là user hiện tại, cần truyền đúng ID

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                  ChangeNotifierProvider.value(
                    value: controller,
                    child: const NewOrEditNotePage(isNewNote: true),
                  ),
              ),
            );
          },
        ),


        body: Consumer<NotesProvider>(
          builder: (context, provider, child) {
            final List<Note> notes = provider.notes;
            return notes.isEmpty ? const NoNotes() : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // Ô tìm kiếm
                  const SearchField(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      NoteIconButton(
                        icon: isDescending
                            ? FontAwesomeIcons.arrowDown
                            : FontAwesomeIcons.arrowUp,
                        size: 18,
                        onPressed: () {
                          setState(() {
                            isDescending = !isDescending;
                          });
                          context.read<NotesProvider>().isDescending = isDescending;
                        },
                      ),
                      const SizedBox(width: 16),
                      DropdownButton(
                        value: dropdownValue,
                        borderRadius: BorderRadius.circular(16),
                        isDense: true,
                        icon: const Padding(
                          padding: EdgeInsets.only(left: 16.0),
                          child: FaIcon(
                            FontAwesomeIcons.arrowDownWideShort,
                            size: 18,
                            color: gray700,
                          ),
                        ),
                        items: dropdownOptions.map((e) {
                          return DropdownMenuItem(
                            value: e,
                            child: Row(
                              children: [
                                Text(e),
                                if (e == dropdownValue) ...[
                                  const SizedBox(width: 8),
                                  Icon(Icons.check, color: primaryColor),
                                ],
                              ],
                            ),
                          );
                        }).toList(),
                        selectedItemBuilder: (context) =>
                            dropdownOptions.map((e) => Text(e)).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            dropdownValue = newValue!;
                          });
                          context.read<NotesProvider>().sortOption = newValue!;
                        },
                      ),
                      const Spacer(),
                      NoteIconButton(
                        icon: isGrid
                            ? FontAwesomeIcons.tableCellsLarge
                            : FontAwesomeIcons.bars,
                        size: 18,
                        onPressed: () {
                          setState(() {
                            isGrid = !isGrid;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Expanded(
                    child: isGrid ? NotesGrid(notes: notes,) : NotesList(notes: notes,),
                  ),
                ],
              ),
            );
          }
        ),
      ),
    );
  }
}

