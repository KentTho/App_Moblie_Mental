// Import các package cần thiết
import 'package:flutter/material.dart';
import 'package:mental_health_app/models/note.dart';
import 'package:mental_health_app/services/note_service.dart';

// NotesProvider là lớp quản lý trạng thái danh sách ghi chú (notes) và cung cấp dữ liệu cho UI
class NotesProvider extends ChangeNotifier {
  // Danh sách ghi chú gốc (tất cả)
  final List<Note> _notes = [];
  List<Note> get notes => _notes; // Getter để truy cập từ bên ngoài

  // Danh sách ghi chú sau khi được lọc (search/filter)
  List<Note> _filteredNotes = [];
  List<Note> get filteredNotes => _filteredNotes;

  // Tùy chọn sắp xếp: "Date created" hoặc "Last updated"
  String _sortOption = 'Date created';
  bool _isDescending = true; // Mặc định sắp xếp giảm dần

  // Getter và setter cho tùy chọn sắp xếp
  String get sortOption => _sortOption;
  set sortOption(String value) {
    _sortOption = value;
    _sortNotes(); // Sắp xếp lại khi thay đổi tùy chọn
    notifyListeners(); // Cập nhật UI
  }

  // Getter và setter cho hướng sắp xếp (tăng/giảm dần)
  bool get isDescending => _isDescending;
  set isDescending(bool value) {
    _isDescending = value;
    _sortNotes(); // Sắp xếp lại khi thay đổi hướng
    notifyListeners(); // Cập nhật UI
  }

  // Hàm lấy dữ liệu ghi chú từ server theo userId
  Future<void> fetchNotes(String userId) async {
    try {
      final data = await NoteService.fetchNotes(userId);
      _notes.clear();
      _notes.addAll(data);
      _filteredNotes = List.from(_notes); // 📌 Đặt trước khi sắp xếp
      _sortNotes(); // 📌 Sắp xếp danh sách sau khi fetch
      notifyListeners(); // Thông báo UI cập nhật
    } catch (e) {
      print("Lỗi khi fetch notes: $e");
    }
  }

  // Hàm thêm ghi chú mới
  Future<void> addNote(Note note) async {
    try {
      final newNote = await NoteService.createNote(
        userId: note.userId,
        title: note.title,
        content: note.content ?? '',
        contentJson: note.contentJson ?? '{}',
        tags: note.tags ?? [], // ✅ Đảm bảo không null
      );
      _notes.add(newNote); // Thêm vào danh sách gốc
      _sortNotes(); // Sắp xếp lại danh sách
      _filteredNotes = List.from(_notes); // Cập nhật danh sách lọc
      notifyListeners(); // Cập nhật UI
    } catch (e) {
      print("Lỗi khi thêm note: $e");
    }
  }

  // Hàm cập nhật ghi chú hiện tại
  Future<void> updateNote(Note note) async {
    try {
      // ✅ FIXED: Truyền đúng ID của note khi gọi hàm update
      final updatedNoteFromServer = await NoteService.updateNote(
        note.id!, // ID bắt buộc phải có
        title: note.title ?? '',
        content: note.content ?? '',
        contentJson: note.contentJson ?? '{}',
        tags: note.tags, // ✅ Giữ nguyên tags
      );

      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _notes[index] = updatedNoteFromServer; // Ghi đè note cũ
        _sortNotes(); // Sắp xếp lại
        _filteredNotes = List.from(_notes); // Cập nhật danh sách lọc
        notifyListeners(); // Cập nhật UI
      }
    } catch (e) {
      print("Lỗi khi cập nhật note: $e");
      rethrow; // Ném lỗi để UI có thể xử lý tiếp
    }
  }

  // Hàm xóa ghi chú theo ID
  Future<void> deleteNote(String noteId) async {
    try {
      await NoteService.deleteNote(noteId); // Gọi API xóa
      _notes.removeWhere((note) => note.id == noteId); // Xóa khỏi danh sách gốc
      _filteredNotes = List.from(_notes); // Cập nhật danh sách lọc
      notifyListeners(); // Cập nhật UI
    } catch (e) {
      print("Lỗi khi xóa note: $e");
    }
  }

  // Hàm lọc ghi chú theo từ khóa (search)
  void filterNotes(String query) {
    if (query.isEmpty) {
      _filteredNotes = List.from(_notes); // Nếu rỗng thì trả về tất cả
    } else {
      _filteredNotes = _notes.where((note) =>
        (note.title ?? '').toLowerCase().contains(query.toLowerCase()) ||
        (note.content ?? '').toLowerCase().contains(query.toLowerCase())
      ).toList(); // Lọc theo tiêu đề hoặc nội dung
    }
    notifyListeners(); // Cập nhật UI
  }

  // Hàm sắp xếp danh sách ghi chú (gốc và lọc)
  void _sortNotes() {
    Comparator<Note> comparator;

    // Sắp xếp theo ngày tạo hoặc ngày cập nhật
    if (_sortOption == 'Date created') {
      comparator = (a, b) => _isDescending
        ? b.createdAt.compareTo(a.createdAt)
        : a.createdAt.compareTo(b.createdAt);
    } else {
      comparator = (a, b) => _isDescending
        ? b.updatedAt.compareTo(a.updatedAt)
        : a.updatedAt.compareTo(b.updatedAt);
    }

    _notes.sort(comparator); // Sắp xếp danh sách gốc
    _filteredNotes.sort(comparator); // ✅ Sắp xếp danh sách lọc
  }

  // Hàm xóa toàn bộ ghi chú khỏi bộ nhớ tạm
  void clearNotes() {
    _notes.clear();
    _filteredNotes.clear();
    notifyListeners(); // Cập nhật UI
  }
}
