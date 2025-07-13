import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:mental_health_app/change_notifiers/notes_provider.dart';
import 'package:mental_health_app/models/note.dart';
import 'package:provider/provider.dart';

class NewNoteController extends ChangeNotifier {
  // ===========================
  // 1. Các trường dữ liệu
  // ===========================

  bool _readOnly = false;
  String _title = '';
  Document _content = Document();
  final List<String> _tags = [];

  String? _id;                     // ✅ ID của ghi chú (nullable khi tạo mới)
  String _userId = "";              // ✅ ID người dùng (bắt buộc)
  String? _sentiment;           // ✅ Tâm trạng (nếu có)
  DateTime _createdAt = DateTime.now(); // ✅ Tự động gán lúc tạo
  DateTime _updatedAt = DateTime.now(); // ✅ Cập nhật khi save

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

  List<String> get tags => [..._tags];

  String? get id => _id;
  set id(String? value) {
    _id = value;
  }

  String get userId => _userId;
  set userId(String value) {
    _userId = value;
  }

  String? get sentiment => _sentiment;
  set sentiment(String? value) {
    _sentiment = value;
  }

  DateTime get createdAt => _createdAt;
  set createdAt(DateTime value) {
    _createdAt = value;
  }

  DateTime get updatedAt => _updatedAt;
  set updatedAt(DateTime value) {
    _updatedAt = value;
  }

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

  void saveNote(BuildContext context) {
    final String? newTitle = title.isNotEmpty ? title : null;
    final String? newContent = content.toPlainText().trim().isNotEmpty
        ? content.toPlainText().trim()
        : null;

    // ✅ Không lưu vào DB, chỉ nội bộ để khôi phục editor
    final String contentJson = jsonEncode(_content.toDelta().toJson());

    final Note note = Note(
      id: _id,
      userId: _userId,
      title: newTitle ?? 'Untitled Note',
      content: newContent,
      tags: tags,
      sentiment: _sentiment,
      createdAt: _createdAt,
      updatedAt: DateTime.now(),
    );

    print('✅ Note saved: ${note.title}');
    print('📝 contentJson (not saved to DB): $contentJson');

    // TODO: Gửi `note` lên backend hoặc lưu DB nội bộ tại đây
    context.read<NotesProvider>().addNote(note);
  }
}
