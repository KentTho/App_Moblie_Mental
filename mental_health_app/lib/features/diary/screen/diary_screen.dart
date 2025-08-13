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
class _DiaryScreenState extends State<DiaryScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late String _sortOption;
  late bool _isDescending;
  bool _isGrid = true; // State for toggling between grid and list view

  @override
  void initState() {
    super.initState();

    // Animation setup
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();

    // Initialize local states from provider
    final notesProvider = context.read<NotesProvider>();
    _sortOption = notesProvider.sortOption;
    _isDescending = notesProvider.isDescending;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotes();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text(
            'My Diary',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          titleTextStyle: const TextStyle(
            color: primaryColor,
            fontSize: 32,
            fontFamily: 'Fredo',
            fontWeight: FontWeight.bold,
          ),
          actions: [
            NoteIconButtonOutlined(
              icon: FontAwesomeIcons.rightFromBracket,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const Homepage()),
                );
              },
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: Consumer<NotesProvider>(
          builder: (context, notesProvider, child) {
            final notes = notesProvider.filteredNotes;

            return notes.isEmpty
                ? const NoNotes()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        const SearchField(),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            NoteIconButton(
                              icon: notesProvider.isDescending
                                  ? FontAwesomeIcons.arrowDown
                                  : FontAwesomeIcons.arrowUp,
                              size: 18,
                              onPressed: () {
                                setState(() {
                                  notesProvider.isDescending =
                                      !notesProvider.isDescending;
                                  _isDescending = notesProvider.isDescending;
                                });
                              },
                            ),
                            const SizedBox(width: 16),
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
                              items: ['Date modified', 'Date created']
                                  .map((e) => DropdownMenuItem(
                                        value: e,
                                        child: Row(
                                          children: [
                                            Text(e),
                                            if (e == notesProvider.sortOption)
                                              ...[
                                                const SizedBox(width: 8),
                                                const Icon(Icons.check,
                                                    color: primaryColor),
                                              ],
                                          ],
                                        ),
                                      ))
                                  .toList(),
                              selectedItemBuilder: (context) => [
                                'Date modified',
                                'Date created'
                              ].map((e) => Text(e)).toList(),
                              onChanged: (newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    notesProvider.sortOption = newValue;
                                    _sortOption = newValue;
                                  });
                                }
                              },
                            ),
                            const Spacer(),
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
                                ? FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: SlideTransition(
                                      position: _slideAnimation,
                                      child: NotesGrid(notes: notes),
                                    ),
                                  )
                                : FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: SlideTransition(
                                      position: _slideAnimation,
                                      child: NotesList(notes: notes),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  );
          },
        ),
        floatingActionButton: NoteFab(
          onPressed: () {
            final controller = context.read<NewNoteController>();
            final userId = context.read<AuthProvider>().userId;
            print("User ID ở NoteFab: $userId");
            if (userId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Bạn cần đăng nhập trước khi tạo ghi chú.')),
              );
              return;
            }

            controller.userId = userId;
            controller.contentJson = '[]';

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
