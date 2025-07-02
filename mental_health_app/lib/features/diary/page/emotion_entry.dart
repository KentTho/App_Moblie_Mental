import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mental_health_app/features/diary/core/constants.dart';
import 'package:mental_health_app/features/diary/page/new_or_edit_note_page.dart';
import 'package:mental_health_app/features/diary/widge/note_fab.dart';
import 'package:mental_health_app/features/diary/page/search_field.dart';
import 'package:mental_health_app/features/diary/widge/note_icon_button.dart';
import 'package:mental_health_app/features/diary/widge/note_icon_button_outlined.dart';
import 'package:mental_health_app/features/home/homepage.dart';
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NewOrEditNotePage(isNewNote: true),
              ),
            );
          },
        ),

        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Ô tìm kiếm
              const SearchField(),

              const SizedBox(height: 8),

              // Hàng chứa nút sắp xếp, dropdown lọc, chuyển chế độ grid/list
              Row(
                children: [
                  // Nút đổi thứ tự sắp xếp
                  NoteIconButton(
                    icon: isDescending
                        ? FontAwesomeIcons.arrowDown
                        : FontAwesomeIcons.arrowUp,
                    size: 18,
                    onPressed: () {
                      setState(() {
                        isDescending = !isDescending;
                      });
                    },
                  ),

                  const SizedBox(width: 16),

                  // Dropdown chọn tiêu chí sắp xếp
                  DropdownButton(
                    value: dropdownValue,
                    underline: const SizedBox.shrink(),
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
                    selectedItemBuilder: (context) => dropdownOptions
                        .map((e) => Text(e))
                        .toList(),
                    onChanged: (newValue) {
                      setState(() {
                        dropdownValue = newValue!;
                      });
                    },
                  ),

                  const Spacer(),

                  // Nút chuyển đổi giữa chế độ Grid và List
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

              // Hiển thị danh sách note dạng lưới hoặc danh sách
              Expanded(
                child: isGrid ? const NotesGrid() : const NotesList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
