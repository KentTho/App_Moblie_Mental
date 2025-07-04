import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000'));

  /// 🔐 Lấy Firebase ID token hiện tại
  Future<String?> getIdToken() async {
    User? user = FirebaseAuth.instance.currentUser;
    return await user?.getIdToken();
  }

  /// 🧾 Đăng ký người dùng (FastAPI)
  Future<void> registerUser({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _dio.post('/api/auth/register', data: {
        'email': email,
        'password': password,
        'full_name': fullName,
      });

      print('✅ Đăng ký thành công: ${response.data}');
    } catch (e) {
      print('❌ Lỗi đăng ký: $e');
    }
  }

  /// ✅ Gửi trạng thái xác minh từ Firebase lên backend
  Future<void> updateVerifiedStatus({
    required String uid,
    required bool isVerified,
  }) async {
    try {
      final token = await getIdToken();
      if (token == null) throw Exception('Không lấy được Firebase token');

      final response = await _dio.put(
        '/user/update-verified',
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
    }
  }
}
