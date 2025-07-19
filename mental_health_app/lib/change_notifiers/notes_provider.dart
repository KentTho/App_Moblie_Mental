import 'package:flutter/material.dart';
import 'package:mental_health_app/models/note.dart';
import 'package:mental_health_app/services/note_service.dart';

class NotesProvider extends ChangeNotifier {
  final List<Note> _notes = [];
  List<Note> get notes => _notes;

  List<Note> _filteredNotes = [];
  List<Note> get filteredNotes => _filteredNotes;

  String _sortOption = 'Date created';
  bool _isDescending = true;

  String get sortOption => _sortOption;
  set sortOption(String value) {
    _sortOption = value;
    _sortNotes();
    notifyListeners();
  }

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
      _sortNotes();
      _filteredNotes = List.from(_notes);
      notifyListeners();
    } catch (e) {
      print("Lỗi khi fetch notes: $e");
    }
  }

  Future<void> addNote(Note note) async {
    try {
      final newNote = await NoteService.createNote(
        userId: note.userId,
        title: note.title ?? '',
        content: note.content ?? '',
        contentJson: note.contentJson ?? '{}',
        tags: note.tags,
      );
      _notes.add(newNote);
      _sortNotes();
      _filteredNotes = List.from(_notes);
      notifyListeners();
    } catch (e) {
      print("Lỗi khi thêm note: $e");
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      // ✅ FIXED: Remove duplicate id parameter and pass correct noteId
      final updatedNoteFromServer = await NoteService.updateNote(
        note.id!, // Pass the note ID as the first parameter
        title: note.title ?? '',
        content: note.content ?? '',
        contentJson: note.contentJson ?? '{}',
        tags: note.tags,
      );
      
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _notes[index] = updatedNoteFromServer;
        _sortNotes();
        _filteredNotes = List.from(_notes);
        notifyListeners();
      }
    } catch (e) {
      print("Lỗi khi cập nhật note: $e");
      rethrow; // Re-throw to let UI handle the error
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await NoteService.deleteNote(noteId);
      _notes.removeWhere((note) => note.id == noteId);
      _filteredNotes = List.from(_notes);
      notifyListeners();
    } catch (e) {
      print("Lỗi khi xóa note: $e");
    }
  }

  void filterNotes(String query) {
    if (query.isEmpty) {
      _filteredNotes = List.from(_notes);
    } else {
      _filteredNotes = _notes
          .where((note) =>
              (note.title ?? '')
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              (note.content ?? '')
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void _sortNotes() {
    if (_sortOption == 'Date created') {
      _notes.sort((a, b) => _isDescending
          ? b.createdAt.compareTo(a.createdAt)
          : a.createdAt.compareTo(b.createdAt));
    } else if (_sortOption == 'Date modified') {
      _notes.sort((a, b) => _isDescending
          ? b.updatedAt.compareTo(a.updatedAt)
          : a.updatedAt.compareTo(b.updatedAt));
    }
  }

  void clearNotes() {
    _notes.clear();
    _filteredNotes.clear();
    notifyListeners();
  }
}
