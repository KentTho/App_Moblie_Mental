import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:mental_health_app/change_notifiers/notes_provider.dart';
import 'package:mental_health_app/models/note.dart';
import 'package:provider/provider.dart';

class NewNoteController extends ChangeNotifier {
  // ===========================
  // 0. Note hiện tại
  // ===========================
  Note? _note;

  set note(Note? value) {
    _note = value;

    if (value != null) {
      _id = value.id;
      _userId = value.userId ?? '';
      _title = value.title ?? '';
      _sentiment = value.sentiment;
      _createdAt = value.createdAt;
      _updatedAt = value.updatedAt;

      if (value.contentJson != null && value.contentJson!.isNotEmpty) {
        try {
          _content = Document.fromJson(jsonDecode(value.contentJson!));
        } catch (e) {
          _content = Document()..insert(0, value.content ?? '');
        }
      } else if (value.content != null && value.content!.isNotEmpty) {
        _content = Document()..insert(0, value.content!);
      } else {
        _content = Document();
      }

      _tags.clear();
      _tags.addAll(value.tags ?? []);
      _emotions.clear(); // ✅ NEW: Clear and add emotions
      _emotions.addAll(value.emotions ?? []); // ✅ NEW: Initialize emotions
    } else {
      // Nếu không có note, tạo mới
      _title = '';
      _content = Document();
      _tags.clear();
      _emotions.clear(); // ✅ NEW: Clear emotions for new note
    }

    notifyListeners();
  }

  Note? get note => _note;

  // ===========================
  // 1. Các trường dữ liệu
  // ===========================
  bool _readOnly = false;
  String _title = '';
  Document _content = Document();
  final List<String> _tags = [];
  final List<String> _emotions = []; // ✅ NEW: Add emotions list

  String? _id;
  String _userId = "";
  String? _sentiment;
  DateTime _createdAt = DateTime.now();
  DateTime _updatedAt = DateTime.now();

  // ===========================
  // 2. Getter / Setter
  // ===========================
  bool get readOnly => _readOnly;
  set readOnly(bool value) {
    _readOnly = value;
    notifyListeners();
  }

  String get title => _title.trim();
  set title(String value) {
    _title = value;
    notifyListeners();
  }

  Document get content => _content;
  set content(Document value) {
    _content = value;
    notifyListeners();
  }

  set contentJson(String value) {
    try {
      final json = jsonDecode(value);
      _content = (json is List && json.isEmpty)
          ? (Document()..insert(0, ''))
          : Document.fromJson(json);
    } catch (e) {
      _content = Document()..insert(0, '');
    }
    notifyListeners();
  }

  List<String> get tags => [..._tags];
  List<String> get emotions => [..._emotions]; // ✅ NEW: Getter for emotions

  String? get id => _id;
  set id(String? value) => _id = value;

  String get userId => _userId;
  set userId(String value) => _userId = value;

  String? get sentiment => _sentiment;
  set sentiment(String? value) => _sentiment = value;

  DateTime get createdAt => _createdAt;
  set createdAt(DateTime value) => _createdAt = value;

  DateTime get updatedAt => DateTime.now(); // Always update on save/edit


  // ===========================
  // 3. Tag Methods
  // ===========================
  void addTag(String tag) {
    if (!_tags.contains(tag)) {
      _tags.add(tag);
      notifyListeners();
    }
  }

  void removeTag(int index) {
    if (index >= 0 && index < _tags.length) {
      _tags.removeAt(index);
      notifyListeners();
    }
  }

  // ===========================
  // 4. Save Note
  // ===========================
  bool get canSaveNote {
    return title.isNotEmpty || content.toPlainText().trim().isNotEmpty;
  }

  void saveNote(BuildContext context) {
    final String? newTitle = title.isNotEmpty ? title : null;
    final String? newContent = content.toPlainText().trim().isNotEmpty
        ? content.toPlainText().trim()
        : null;

    final String contentJson = jsonEncode(_content.toDelta().toJson());

    final Note note = Note(
      id: _id,
      userId: _userId,
      title: newTitle ?? 'Untitled Note',
      content: newContent,
      contentJson: contentJson,
      tags: tags,
      sentiment: _sentiment,
      emotions: emotions, // ✅ NEW: Pass emotions (will be overwritten by backend)
      createdAt: _createdAt,
      updatedAt: DateTime.now(),
    );

    print('✅ Note saved: ${note.title}');
    print('📝 contentJson (not saved to DB): $contentJson');

    context.read<NotesProvider>().addNote(note);
  }

  // ===========================
  // 5. Update Note - FIXED
  // ===========================
  Future<void> updateNote(BuildContext context, String noteId) async {
    // ✅ Validate noteId first
    if (noteId.isEmpty) {
      throw Exception('❌ Note ID is empty - cannot update');
    }

    final String? newTitle = title.isNotEmpty ? title : null;
    final String? newContent = content.toPlainText().trim().isNotEmpty
        ? content.toPlainText().trim()
        : null;

    final String contentJson = jsonEncode(_content.toDelta().toJson());

    final Note updatedNote = Note(
      id: noteId,
      userId: _userId,
      title: newTitle ?? 'Untitled Note',
      content: newContent,
      contentJson: contentJson,
      tags: tags,
      sentiment: _sentiment,
      emotions: emotions, // ✅ NEW: Pass emotions (will be overwritten by backend)
      createdAt: _createdAt,
      updatedAt: DateTime.now(),
    );

    print('✅ Note updating: ${updatedNote.title}');
    print('🔄 Note ID: $noteId');
    print('📝 contentJson: $contentJson');

    await context.read<NotesProvider>().updateNote(updatedNote);
  }

  // ===========================
  // 6. Kiểm tra thay đổi
  // ===========================
  bool get hasChanged {
    final initialTitle = _note?.title ?? '';
    final initialContent = _note?.contentJson ?? '';
    final currentTitle = _title.trim();
    final currentContentJson = jsonEncode(_content.toDelta().toJson());

    return currentTitle != initialTitle || currentContentJson != initialContent;
  }
}
 