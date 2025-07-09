import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note.dart';

class NoteService {
  static const String baseUrl = 'http://10.0.2.2:8000/api/notes'; // nếu dùng Android Emulator

  // Lấy tất cả notes theo userId
  static Future<List<Note>> fetchNotes(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Note.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load notes');
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
      'user_id': userId,
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
}
