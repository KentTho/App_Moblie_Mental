import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Giữ lại cả Dio và http như cũ nhưng sửa cách sử dụng
  final Dio _dio = Dio();
  final String _baseUrl = 'http://10.0.2.2:8000';

  /// 🔐 Lấy Firebase ID token hiện tại (giữ nguyên)
  Future<String?> getIdToken() async {
    User? user = FirebaseAuth.instance.currentUser;
    return await user?.getIdToken();
  }

  /// 🧾 Đăng ký người dùng (FastAPI) - Giữ nguyên
  Future<void> registerUser({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/auth/register',
        data: {
          'email': email,
          'password': password,
          'full_name': fullName,
        },
      );
      print('✅ Đăng ký thành công: ${response.data}');
    } catch (e) {
      print('❌ Lỗi đăng ký: $e');
      rethrow;
    }
  }

  /// ✅ Gửi trạng thái xác minh - Giữ nguyên
  Future<void> updateVerifiedStatus({
    required String uid,
    required bool isVerified,
  }) async {
    try {
      final token = await getIdToken();
      if (token == null) throw Exception('Không lấy được Firebase token');

      final response = await _dio.put(
        '$_baseUrl/user/update-verified',
        data: {
          'uid': uid,
          'is_verified': isVerified,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      print('✅ Trạng thái xác minh đã được cập nhật: ${response.data}');
    } catch (e) {
      print('❌ Lỗi cập nhật trạng thái xác minh: $e');
      rethrow;
    }
  }

  // ========== Các phương thức HTTP cơ bản ==========
  // Sửa lại để tránh trùng lặp baseUrl
  Future<Map<String, String>> _getHeaders() async {
    final token = await getIdToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Sửa lại các phương thức http
  Future<http.Response> get(String endpoint, {Map<String, String>? headers}) async {
    final uri = Uri.parse('$_baseUrl$endpoint'.replaceAll(_baseUrl + _baseUrl, _baseUrl));
    final defaultHeaders = await _getHeaders();
    return await http.get(
      uri,
      headers: {...defaultHeaders, ...?headers},
    );
  }

  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint'.replaceAll(_baseUrl + _baseUrl, _baseUrl));
    final defaultHeaders = await _getHeaders();
    return await http.post(
      uri,
      headers: {...defaultHeaders, ...?headers},
      body: json.encode(data),
    );
  }

  Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint'.replaceAll(_baseUrl + _baseUrl, _baseUrl));
    final defaultHeaders = await _getHeaders();
    return await http.put(
      uri,
      headers: {...defaultHeaders, ...?headers},
      body: json.encode(data),
    );
  }

  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint'.replaceAll(_baseUrl + _baseUrl, _baseUrl));
    final defaultHeaders = await _getHeaders();
    return await http.delete(
      uri,
      headers: {...defaultHeaders, ...?headers},
    );
  }

  // Thêm phương thức mới để sử dụng Dio nếu cần
  Future<Response> dioGet(String endpoint, {Map<String, dynamic>? headers}) async {
    final token = await getIdToken();
    return await _dio.get(
      '$_baseUrl$endpoint',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
          ...?headers,
        },
      ),
    );
  }
}