import 'dart:convert'; // Cho phép chuyển đổi giữa String và JSON (Map/List)
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart'; // Editor hỗ trợ rich text
import 'package:mental_health_app/change_notifiers/notes_provider.dart'; // Quản lý danh sách note
import 'package:mental_health_app/models/note.dart'; // Model Note
import 'package:provider/provider.dart'; // State management

class NewNoteController extends ChangeNotifier {
  // ===========================
  // 0. Note hiện tại
  // ===========================

  Note? _note;
  
  /// Gán giá trị `note` và cập nhật các trường tương ứng từ model
  set note (Note? value){
    _note = value;
    _title = _note!.title ?? '';

    // ⚠️ Cập nhật nội dung (rich text) từ JSON hoặc plain text
    if (_note!.contentJson != null && _note!.contentJson!.isNotEmpty) {
      _content = Document.fromJson(jsonDecode(_note!.contentJson!));
    } else if (_note!.content != null && _note!.content!.isNotEmpty) {
      _content = Document()..insert(0, _note!.content!);
    } else {
      _content = Document();
    };
    _tags.addAll(_note!.tags ?? []);
    notifyListeners();
  }

  Note? get note => _note;


  // ===========================
  // 1. Các trường dữ liệu
  // ===========================

  bool _readOnly = false;
  String _title = '';
  Document _content = Document(); // Quill editor Document (rich text)
  final List<String> _tags = [];

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

  /// Thêm tag vào danh sách nếu chưa tồn tại
  void addTag(String tag) {
    if (!_tags.contains(tag)) {
      _tags.add(tag);
      notifyListeners();
    }
  }

  /// Xóa tag theo chỉ số
  void removeTag(int index) {
    if (index >= 0 && index < _tags.length) {
      _tags.removeAt(index);
      notifyListeners();
    }
  }

  /// Kiểm tra điều kiện để cho phép lưu
  bool get canSaveNote {
    return title.isNotEmpty || content.toPlainText().trim().isNotEmpty;
  }


  // ===========================
  // 4. Save Note
  // ===========================

  void saveNote(BuildContext context) {
    final String? newTitle = title.isNotEmpty ? title : null;
    final String? newContent = content.toPlainText().trim().isNotEmpty
        ? content.toPlainText().trim()
        : null;

    // ✅ Chuyển rich text thành JSON để lưu trữ (Quill Delta)
    final String contentJson = jsonEncode(_content.toDelta().toJson());

    final Note note = Note(
      id: _id,
      userId: _userId,
      title: newTitle ?? 'Untitled Note',
      content: newContent,
      contentJson: contentJson, // ✅ Đưa rich text JSON vào model
      tags: tags,
      sentiment: _sentiment,
      createdAt: _createdAt,
      updatedAt: DateTime.now(),
    );

    print('✅ Note saved: ${note.title}');
    print('📝 contentJson (not saved to DB): $contentJson');

    // Gửi lên Provider (hoặc backend sau này)
    context.read<NotesProvider>().addNote(note);
  }


  bool get hasChanged {
  final initialTitle = _note?.title ?? '';
  final initialContent = _note?.contentJson ?? '';

  final currentTitle = _title.trim();
  final currentContentJson = jsonEncode(_content.toDelta().toJson());

  return currentTitle != initialTitle || currentContentJson != initialContent;
}

}
