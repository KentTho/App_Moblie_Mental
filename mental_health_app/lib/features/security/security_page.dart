import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mental_health_app/features/home/profile/profile_page.dart';
import '../auth/page/change_password_page.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _isLoading = false;
  final Dio _dio = Dio();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  Future<void> _updateVerificationStatus(bool isVerified) async {
    if (_currentUser == null) {
      _showSnackBar('Không tìm thấy người dùng', isError: true);
      return;
    }

    await _currentUser!.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser;

    if (isVerified && (refreshedUser == null || !refreshedUser.emailVerified)) {
      _showSnackBar('Email của bạn chưa được xác thực trên Firebase.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _dio.put(
        'http://10.0.2.2:8000/user/update-verified',
        data: {
          'uid': _currentUser!.uid,
          'is_verified': isVerified,
        },
      );

      if (response.statusCode == 200) {
        _showSnackBar('Cập nhật trạng thái xác thực thành công!');
      } else {
        _showSnackBar('Lỗi máy chủ: ${response.statusCode}', isError: true);
      }
    } catch (e) {
      _showSnackBar('Lỗi cập nhật trạng thái: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAccount() async {
    if (_currentUser == null) {
      _showSnackBar('Không tìm thấy người dùng', isError: true);
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Xác nhận xóa tài khoản', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Bạn có chắc chắn muốn xóa tài khoản? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final response = await _dio.delete(
        'http://10.0.2.2:8000/user/delete/${_currentUser!.uid}',
      );

      if (response.statusCode == 200) {
        await _currentUser!.delete();
        _showSnackBar('Tài khoản đã được xóa thành công');
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      _showSnackBar('Lỗi xóa tài khoản: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> sendVerificationEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser;

    if (refreshedUser != null && refreshedUser.emailVerified) {
      _showSnackBar('Email đã được xác thực trước đó!');
      await _updateVerificationStatus(true);
    } else if (refreshedUser != null) {
      try {
        await refreshedUser.sendEmailVerification();
        _showSnackBar('Email xác thực đã được gửi');
      } catch (e) {
        _showSnackBar('Lỗi gửi email xác thực: ${e.toString()}', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // AppBar giống ProfilePage
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
                    },
                  ),
                  const Expanded(
                    child: Text(
                      "Bảo mật",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Icon(Icons.security_rounded, color: Colors.green, size: 22),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 8),
                  _buildSecurityCard(
                    icon: Icons.verified_user_rounded,
                    title: "Xác thực tài khoản",
                    subtitle: "Cập nhật trạng thái xác thực",
                    color: Colors.green,
                    onTap: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      await user?.reload();
                      final refreshedUser = FirebaseAuth.instance.currentUser;
                      if (refreshedUser != null && refreshedUser.emailVerified) {
                        await _updateVerificationStatus(true);
                      } else {
                        _showSnackBar('Bạn chưa xác thực email. Vui lòng kiểm tra hộp thư.', isError: true);
                      }
                    },
                  ),
                  _buildSecurityCard(
                    icon: Icons.remove_circle_outline_rounded,
                    title: "Hủy xác thực",
                    subtitle: "Gỡ bỏ trạng thái xác thực",
                    color: Colors.orange,
                    onTap: () => _updateVerificationStatus(false),
                  ),
                  _buildSecurityCard(
                    icon: Icons.password_rounded,
                    title: "Đổi mật khẩu",
                    subtitle: "Cập nhật mật khẩu đăng nhập",
                    color: Colors.teal,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage()));
                    },
                  ),
                  _buildSecurityCard(
                    icon: Icons.mark_email_read_rounded,
                    title: "Gửi email xác thực",
                    subtitle: "Gửi liên kết xác thực đến email",
                    color: Colors.blue,
                    onTap: sendVerificationEmail,
                  ),

                  const SizedBox(height: 20),
                  // Danger Zone
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.red.withOpacity(0.15)),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Vùng nguy hiểm", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                        const SizedBox(height: 8),
                        const Text("Các hành động trong vùng này không thể hoàn tác", style: TextStyle(fontSize: 13, color: Colors.black54)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _deleteAccount,
                          icon: _isLoading
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.delete_forever_rounded, color: Colors.white),
                          label: const Text("Xóa tài khoản", style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}
