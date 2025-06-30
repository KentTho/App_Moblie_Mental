import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mental_health_app/features/diary/core/constants.dart';
import 'package:mental_health_app/features/diary/page/new_or_edit_note_page.dart';
import 'package:mental_health_app/features/diary/widge/note_fab.dart';
import 'package:mental_health_app/features/diary/page/search_field.dart';
import 'package:mental_health_app/features/diary/widge/note_icon_button.dart';
import 'package:mental_health_app/features/diary/widge/note_icon_button_outlined.dart';
import 'package:mental_health_app/features/home/homepage.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../widge/note_grid.dart';
import '../widge/notes_list.dart';




class EmotionEntry extends StatefulWidget{
  const EmotionEntry({super.key});

  @override
  State<EmotionEntry> createState() => _EmotionEntryState();
}


class _EmotionEntryState extends State<EmotionEntry> {


  final List<String> dropdownOptions = ['Data modified', 'Date created'];
  late String dropdownValue = dropdownOptions.first;

  bool isDescending = true;

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
          title: const Text("Emotion Entry 📒"),
          backgroundColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: primaryColor,
            fontSize: 32,
            fontFamily: 'Fredo',
            fontWeight: FontWeight.bold,
          ),
          actions: [
            NoteIconButtonOutlined(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const Homepage()),
                );
              },
            icon: FontAwesomeIcons.rightFromBracket,),
          ],
        ),
        floatingActionButton:NoteFab(
          onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => NewOrEditNotePage()
                ),
              );
          },
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SearchField(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    NoteIconButton(
                      icon: isDescending ? FontAwesomeIcons.arrowDown : FontAwesomeIcons.arrowUp, 
                      size: 18, 
                      onPressed: () {
                        setState(() {
                          isDescending = !isDescending;
                        });
                      }
                    ),
                    SizedBox(width: 16),
                    DropdownButton(
                      value: dropdownValue,
                      icon: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: FaIcon(
                          FontAwesomeIcons.arrowDownWideShort,
                          size: 18,
                          color: gray700,
                        ),
                      ),
                      underline: SizedBox.shrink(),
                      borderRadius: BorderRadius.circular(16),
                      isDense: true,
                      items: dropdownOptions
                          .map((e) =>
                          DropdownMenuItem(
                            value: e,
                            child: Row(
                              children: [
                                Text(e),
                                if( e == dropdownValue) ...[
                                  SizedBox(width: 8),
                                  Icon(Icons.check, color: primaryColor)
                                ],
                              ],
                            ),
                          ))
                          .toList(),
                      selectedItemBuilder: (context) => dropdownOptions.map((e) => Text(e)).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          dropdownValue = newValue!;
                        });
                      },
                    ),
                    Spacer(),
                    NoteIconButton(
                      icon: isGrid
                          ? FontAwesomeIcons.tableCellsLarge
                          : FontAwesomeIcons.bars, 
                      size: 18, 
                      onPressed: () {
                        setState(() {
                          isGrid = !isGrid;
                        });
                      }
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isGrid ? NotesGrid() : NotesList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}













