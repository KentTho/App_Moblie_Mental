import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note.dart';

class NoteService {
  static const String baseUrl = 'http://10.0.2.2:8000/api/notes'; // nếu dùng Android Emulator

  // ✅ Đảm bảo userId là String ở đây
    static Future<List<Note>> fetchNotes(String userId) async {
    final response = await http.get(
      Uri.parse("http://10.0.2.2:8000/api/notes/user/$userId"),
    );

    if (response.statusCode == 200) {
      final List jsonData = jsonDecode(response.body);
      return jsonData.map((e) => Note.fromJson(e)).toList();
    } else {
      throw Exception("Lỗi khi fetch notes");
    }
  }




  // Tạo note mới
    static Future<void> createNote({
    required String userId,
    required String title,
    required String content,
    required List<String> tags,
  }) async {
    final body = jsonEncode({
      'user_id': userId, // là string UUID
      'title': title,
      'content': content,
      'tags': tags,
    });

    final response = await http.post(
      Uri.parse('$baseUrl/'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create note');
    }
  }




  static Future<void> updateNote({
      required int noteId,
      required String title,
      required String content,
      required List<String> tags,
    }) async {
      final body = jsonEncode({
        'title': title,
        'content': content,
        'tags': tags,
      });

      final response = await http.put(
        Uri.parse('$baseUrl/$noteId'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update note');
      }
    }


  static Future<void> deleteNote(String noteId) async {
  final response = await http.delete(Uri.parse('$baseUrl/$noteId'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete note');
    }
  }


}
