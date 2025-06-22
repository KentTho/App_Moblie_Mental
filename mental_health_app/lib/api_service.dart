import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api'));

  Future<void> registerUser({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'full_name': fullName,
      });

      print('Đăng ký thành công: ${response.data}');
    } catch (e) {
      print('Lỗi đăng ký: $e');
    }
  }
}
