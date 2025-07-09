// lib/change_notifiers/notes_provider.dart

import 'package:flutter/widgets.dart';
import 'package:mental_health_app/models/note.dart';
import 'package:mental_health_app/services/note_service.dart';

class NotesProvider extends ChangeNotifier {
  final List<Note> _notes = [];

  List<Note> get notes => _notes;

  Future<void> fetchNotes(String userId) async {
    try {
      final data = await NoteService.fetchNotes(userId);
      _notes.clear();
      _notes.addAll(data);
      notifyListeners();
    } catch (e) {
      print("Lỗi khi fetch notes: $e");
    }
  }

  Future<void> addNote(Note note) async {
    _notes.add(note);
    notifyListeners();
  }

  void deleteNote(int index) {
    _notes.removeAt(index);
    notifyListeners();
  }
}
