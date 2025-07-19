import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note.dart'; // Import model Note

class NoteService {
  // ✅ Địa chỉ base URL API - nếu dùng Android Emulator, giữ nguyên IP 10.0.2.2
  static const String baseUrl = 'http://10.0.2.2:8000/api/notes';

  /// =========================
  /// 🔹 1. Lấy danh sách note của người dùng theo userId
  /// =========================
  static Future<List<Note>> fetchNotes(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId'),
    );

    if (response.statusCode == 200) {
      final List jsonData = jsonDecode(response.body);
      return jsonData.map((e) => Note.fromJson(e)).toList();
    } else {
      throw Exception("❌ Lỗi khi fetch notes");
    }
  }

  /// =========================
  /// 🔹 2. Tạo note mới
  /// =========================
  static Future<Note> createNote({
    required String userId,
    required String title,
    required String content,
    required String contentJson, // This is a JSON string from Quill
    required List<String> tags,
  }) async {
    final body = jsonEncode({
      'user_id': userId,
      'title': title,
      'content': content,
      'content_json': jsonDecode(contentJson), // ✅ Parse JSON string to Map
      'tags': tags,
    });

    final response = await http.post(
      Uri.parse('$baseUrl/'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Note.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('❌ Tạo note thất bại');
    }
  }

  /// =========================
  /// 🔹 3. Cập nhật (update) ghi chú theo noteId - FIXED
  /// =========================
  // ✅ Change return type from Future<void> to Future<Note>
  static Future<Note> updateNote(
    String noteId, {
    required String title,
    required String content,
    required String contentJson, // This is a JSON string from Quill
    required List<String> tags,
  }) async {
    final body = jsonEncode({
      'title': title,
      'content': content,
      'content_json': jsonDecode(contentJson), // ✅ Parse JSON string to Map
      'tags': tags,
    });

    print('🔄 Updating note with ID: $noteId'); // Debug log
    print('🔄 URL: $baseUrl/$noteId'); // Debug log
    print('🔄 Request Body: $body'); // Debug log the full body

    final response = await http.put(
      Uri.parse('$baseUrl/$noteId'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    print('🔄 Response status: ${response.statusCode}'); // Debug log
    print('🔄 Response body: ${response.body}'); // Debug log

    if (response.statusCode == 200) { // ✅ Check for 200 OK
      return Note.fromJson(jsonDecode(response.body)); // ✅ Return the updated note
    } else {
      throw Exception('❌ Cập nhật note thất bại - Status: ${response.statusCode}. Response: ${response.body}');
    }
  }

  /// =========================
  /// 🔹 4. Xoá ghi chú theo noteId
  /// =========================
  static Future<void> deleteNote(String noteId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$noteId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('❌ Xoá note thất bại');
    }
  }
}
