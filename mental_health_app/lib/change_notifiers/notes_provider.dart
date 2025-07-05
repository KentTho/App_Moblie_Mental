import 'package:flutter/widgets.dart';
import 'package:mental_health_app/models/note.dart';

class NotesProvider extends ChangeNotifier {
  // ví dụ một state đơn giản
  final List<Note> _notes = [];

  List<Note> get notes => _notes;

  void addNote(String note) {
    _notes.add(note as Note);
    notifyListeners();
  }

  void deleteNote(int index) {
    _notes.removeAt(index);
    notifyListeners();
  }
}