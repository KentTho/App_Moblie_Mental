import 'package:flutter/widgets.dart';
import 'package:mental_health_app/models/note.dart';
import 'package:mental_health_app/services/note_service.dart';

class NotesProvider extends ChangeNotifier {
  final List<Note> _notes = [];
  List<Note> get notes => _notes;

  String _sortOption = 'Date created'; // default
  bool _isDescending = true;

  // getter và setter cho sortOption
  String get sortOption => _sortOption;
  set sortOption(String value) {
    _sortOption = value;
    _sortNotes(); // gọi sắp xếp lại
    notifyListeners();
  }

  // getter và setter cho isDescending
  bool get isDescending => _isDescending;
  set isDescending(bool value) {
    _isDescending = value;
    _sortNotes();
    notifyListeners();
  }

  Future<void> fetchNotes(String userId) async {
    try {
      final data = await NoteService.fetchNotes(userId);

      _notes.clear();
      _notes.addAll(data);

      _sortNotes(); // sort khi fetch xong
      notifyListeners();
    } catch (e) {
      print("Lỗi khi fetch notes: $e");
    }
  }

  Future<void> addNote(Note note) async {
  try {
    await NoteService.createNote(
      userId: note.userId,
      title: note.title ?? '',
      content: note.content ?? '',
      contentJson: note.contentJson ?? '{}', // ✅ Gửi rich text JSON
      tags: note.tags,
    );

    _notes.add(note);
    _sortNotes();
    notifyListeners();
  } catch (e) {
    print("Lỗi khi thêm note: $e");
  }
}


  void _sortNotes() {
    if (_sortOption == 'Date created') {
      _notes.sort((a, b) => _isDescending
          ? b.createdAt.compareTo(a.createdAt)
          : a.createdAt.compareTo(b.createdAt));
    } else if (_sortOption == 'Data modified') {
      _notes.sort((a, b) => _isDescending
          ? b.updatedAt.compareTo(a.updatedAt)
          : a.updatedAt.compareTo(b.updatedAt));
    }
  }

  // (Tuỳ chọn) tìm kiếm nếu cần sử dụng
  List<Note> _filteredNotes = [];
  List<Note> get filteredNotes => _filteredNotes;

  void filterNotes(String query) {
    if (query.isEmpty) {
      _filteredNotes = _notes;
    } else {
      _filteredNotes = _notes
          .where((note) =>
              note.title.toLowerCase().contains(query.toLowerCase()) ||
              (note.content ?? '').toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }


    void removeNoteById(String noteId) {
      _notes.removeWhere((note) => note.id == noteId);
      notifyListeners();
    }

}
