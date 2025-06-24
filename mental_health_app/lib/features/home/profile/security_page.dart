import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mental_health_app/features/home/profile/profile_page.dart';

import 'change_password_page.dart';

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

    setState(() {
      _isLoading = true;
    });

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
      }
    } catch (e) {
      _showSnackBar('Lỗi cập nhật trạng thái: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAccount() async {
    if (_currentUser == null) {
      _showSnackBar('Không tìm thấy người dùng', isError: true);
      return;
    }

    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            'Xác nhận xóa tài khoản',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          content: const Text(
            'Bạn có chắc chắn muốn xóa tài khoản? Hành động này không thể hoàn tác.',
            style: TextStyle(color: Color(0xFF4A5568)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Hủy',
                style: TextStyle(color: Color(0xFF4CAF50)),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'Xóa',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _dio.delete(
        'http://10.0.2.2:8000/user/delete/${_currentUser!.uid}',
      );

      if (response.statusCode == 200) {
        // Delete Firebase user
        await _currentUser!.delete();

        _showSnackBar('Tài khoản đã được xóa thành công');

        // Navigate back to login
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      _showSnackBar('Lỗi xóa tài khoản: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE8F5E8), // Soft mint green
              Color(0xFFF0FFF0), // Honeydew
              Color(0xFFF5FFFA), // Mint cream
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF4CAF50).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        "Bảo mật",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.security_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Security Icon
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF4CAF50).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.security_rounded,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Security Options
                        _buildSecurityCard(
                          icon: Icons.verified_user_rounded,
                          title: "Xác thực tài khoản",
                          subtitle: "Cập nhật trạng thái xác thực",
                          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                          onTap: () => _updateVerificationStatus(true),
                        ),

                        const SizedBox(height: 15),

                        _buildSecurityCard(
                          icon: Icons.remove_circle_outline_rounded,
                          title: "Hủy xác thực",
                          subtitle: "Gỡ bỏ trạng thái xác thực",
                          colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                          onTap: () => _updateVerificationStatus(false),
                        ),

                        const SizedBox(height: 15),

                        _buildSecurityCard(
                          icon: Icons.password_rounded,
                          title: "Đổi mật khẩu",
                          subtitle: "Cập nhật mật khẩu đăng nhập",
                          colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage()));
                          },
                        ),

                        const SizedBox(height: 30),

                        // Danger Zone
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Vùng nguy hiểm",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Các hành động trong vùng này không thể hoàn tác",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4A5568),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _deleteAccount,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    backgroundColor: Colors.red,
                                    disabledBackgroundColor: Colors.grey[300],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                      : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.delete_forever_rounded, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(
                                        "Xóa tài khoản",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: colors.first.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: colors.first,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
