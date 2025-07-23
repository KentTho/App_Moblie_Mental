import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mental_health_app/change_notifiers/auth_provider.dart';
import 'package:mental_health_app/change_notifiers/new_note_controller.dart';
import 'package:mental_health_app/change_notifiers/notes_provider.dart';
import 'package:mental_health_app/features/diary/widge/note_fad.dart';
import 'package:mental_health_app/features/diary/widge/search_field.dart';
import 'package:mental_health_app/features/home/homepage.dart';
import 'package:provider/provider.dart';// Import NewNoteController
import '../core/constants.dart'; // Import constants
import '../widge/note_icon_button.dart';
import '../widge/note_icon_button_outlined.dart';
import '../widge/no_notes.dart';
import '../widge/notes_grid.dart';
import '../widge/notes_list.dart';
import '../page/new_or_edit_note_page.dart'; // Import the new page

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  // These states are now managed by NotesProvider, but we keep them for UI interaction
  // and to update the provider.
  late String _sortOption;
  late bool _isDescending;
  bool _isGrid = true; // State for toggling between grid and list view

  @override
  void initState() {
    super.initState();
    // Initialize local states from provider
    final notesProvider = context.read<NotesProvider>();
    _sortOption = notesProvider.sortOption;
    _isDescending = notesProvider.isDescending;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotes();
    });
  }

  void _loadNotes() {
  final authProvider = context.read<AuthProvider>();
  final userId = authProvider.userId;

  if (userId == null) {
    print("⚠️ userId is null, cannot load notes.");
    return;
  }

  final notesProvider = context.read<NotesProvider>();
  notesProvider.fetchNotes(userId);
}


  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent, // AppBar background from EmotionEntry
          elevation: 0,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // As in EmotionEntry
          title: const Text("Emotion Entry 📒"), // Title from EmotionEntry
          titleTextStyle: const TextStyle(
            color: primaryColor,
            fontSize: 32,
            fontFamily: 'Fredo', // Assuming 'Fredo' font is available
            fontWeight: FontWeight.bold,
          ),
          actions: [
            // Logout button from EmotionEntry
            NoteIconButtonOutlined(
              icon: FontAwesomeIcons.rightFromBracket,
              onPressed: () {
                //Navigate to Homepage or logout logic
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Homepage()));
                // ScaffoldMessenger.of(context).showSnackBar(
                //   const SnackBar(content: Text('Logout functionality here')),
                // );
              },
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: Consumer<NotesProvider>(
          builder: (context, notesProvider, child) {
            final notes = notesProvider.filteredNotes;

            return notes.isEmpty
                ? const NoNotes() // Use NoNotes widget from EmotionEntry
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        // Search Field from EmotionEntry
                        const SearchField(),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Sort order button from EmotionEntry
                            NoteIconButton(
                              icon: notesProvider.isDescending
                                  ? FontAwesomeIcons.arrowDown
                                  : FontAwesomeIcons.arrowUp,
                              size: 18,
                              onPressed: () {
                                setState(() {
                                  notesProvider.isDescending = !notesProvider.isDescending;
                                  _isDescending = notesProvider.isDescending; // Update local state
                                });
                              },
                            ),
                            const SizedBox(width: 16),
                            // Sort option dropdown from EmotionEntry
                            DropdownButton<String>(
                              value: notesProvider.sortOption,
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
                              items: ['Date modified', 'Date created'].map((e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: Row(
                                    children: [
                                      Text(e),
                                      if (e == notesProvider.sortOption) ...[
                                        const SizedBox(width: 8),
                                        const Icon(Icons.check, color: primaryColor),
                                      ],
                                    ],
                                  ),
                                );
                              }).toList(),
                              selectedItemBuilder: (context) =>
                                  ['Date modified', 'Date created'].map((e) => Text(e)).toList(),
                              onChanged: (newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    notesProvider.sortOption = newValue;
                                    _sortOption = newValue; // Update local state
                                  });
                                }
                              },
                            ),
                            const Spacer(),
                            // Grid/List toggle button from EmotionEntry
                            NoteIconButton(
                              icon: _isGrid
                                  ? FontAwesomeIcons.tableCellsLarge
                                  : FontAwesomeIcons.bars,
                              size: 18,
                              onPressed: () {
                                setState(() {
                                  _isGrid = !_isGrid;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async => _loadNotes(),
                            child: _isGrid
                                ? NotesGrid(notes: notes) // Use NotesGrid
                                : NotesList(notes: notes), // Use NotesList
                          ),
                        ),
                      ],
                    ),
                  );
          },
        ),
        // Floating Action Button from EmotionEntry
        floatingActionButton: NoteFab(
          onPressed: () {
            final controller = context.read<NewNoteController>();
            final userId = context.read<AuthProvider>().userId;
            print("User ID ở NoteFab: $userId");
            if (userId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bạn cần đăng nhập trước khi tạo ghi chú.')),
              );
              return;
            }

            controller.userId = userId;
            controller.contentJson = '[]'; // Initialize content for new note

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider.value(
                  value: controller,
                  child: const NewOrEditNotePage(isNewNote: true),
                ),
              ),
            );
          },

        ),
      ),
    );
  }
}
