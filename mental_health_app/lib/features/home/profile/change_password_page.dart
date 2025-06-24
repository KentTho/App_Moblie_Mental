import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  Future<void> _changePassword() async {
    if (_currentUser == null) {
      _showSnackBar('Không tìm thấy người dùng', isError: true);
      return;
    }

    // Validation
    if (_currentPasswordController.text.trim().isEmpty) {
      _showSnackBar('Vui lòng nhập mật khẩu hiện tại', isError: true);
      return;
    }

    if (_newPasswordController.text.trim().isEmpty) {
      _showSnackBar('Vui lòng nhập mật khẩu mới', isError: true);
      return;
    }

    if (_newPasswordController.text.length < 6) {
      _showSnackBar('Mật khẩu mới phải có ít nhất 6 ký tự', isError: true);
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackBar('Mật khẩu xác nhận không khớp', isError: true);
      return;
    }

    if (_currentPasswordController.text == _newPasswordController.text) {
      _showSnackBar('Mật khẩu mới phải khác mật khẩu hiện tại', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: _currentUser!.email!,
        password: _currentPasswordController.text.trim(),
      );

      await _currentUser!.reauthenticateWithCredential(credential);

      // Update password
      await _currentUser!.updatePassword(_newPasswordController.text.trim());

      // Clear form
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      _showSnackBar('Đổi mật khẩu thành công!');

      // Navigate back after success
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context, true);
        }
      });

    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Lỗi đổi mật khẩu';

      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'Mật khẩu hiện tại không đúng';
          break;
        case 'weak-password':
          errorMessage = 'Mật khẩu mới quá yếu';
          break;
        case 'requires-recent-login':
          errorMessage = 'Vui lòng đăng nhập lại để thực hiện thao tác này';
          break;
        default:
          errorMessage = 'Lỗi: ${e.message}';
      }

      _showSnackBar(errorMessage, isError: true);
    } catch (e) {
      _showSnackBar('Lỗi không xác định: ${e.toString()}', isError: true);
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
        duration: Duration(seconds: isError ? 4 : 2),
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
                      onTap: () => Navigator.pop(context),
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
                        "Đổi mật khẩu",
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
                        Icons.lock_reset_rounded,
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

                        // Password Icon
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
                            Icons.lock_reset_rounded,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Change Password Form
                        Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF4CAF50).withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Đổi mật khẩu",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Vui lòng nhập mật khẩu hiện tại để xác thực",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 25),

                              // Current Password Field
                              const Text(
                                "Mật khẩu hiện tại",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _currentPasswordController,
                                obscureText: !_isCurrentPasswordVisible,
                                decoration: InputDecoration(
                                  hintText: 'Nhập mật khẩu hiện tại',
                                  prefixIcon: Icon(
                                    Icons.lock_outline_rounded,
                                    color: Color(0xFF66BB6A),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isCurrentPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                      color: Color(0xFF66BB6A),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
                                      });
                                    },
                                  ),
                                  filled: true,
                                  fillColor: Color(0xFFE8F5E8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Color(0xFF4CAF50),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // New Password Field
                              const Text(
                                "Mật khẩu mới",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _newPasswordController,
                                obscureText: !_isNewPasswordVisible,
                                decoration: InputDecoration(
                                  hintText: 'Nhập mật khẩu mới (tối thiểu 6 ký tự)',
                                  prefixIcon: Icon(
                                    Icons.lock_rounded,
                                    color: Color(0xFF66BB6A),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isNewPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                      color: Color(0xFF66BB6A),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isNewPasswordVisible = !_isNewPasswordVisible;
                                      });
                                    },
                                  ),
                                  filled: true,
                                  fillColor: Color(0xFFE8F5E8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Color(0xFF4CAF50),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Confirm New Password Field
                              const Text(
                                "Xác nhận mật khẩu mới",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _confirmPasswordController,
                                obscureText: !_isConfirmPasswordVisible,
                                decoration: InputDecoration(
                                  hintText: 'Nhập lại mật khẩu mới',
                                  prefixIcon: Icon(
                                    Icons.lock_clock_rounded,
                                    color: Color(0xFF66BB6A),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                      color: Color(0xFF66BB6A),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                      });
                                    },
                                  ),
                                  filled: true,
                                  fillColor: Color(0xFFE8F5E8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Color(0xFF4CAF50),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),

                              // Security Notice
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Color(0xFFE8F5E8),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Color(0xFF4CAF50).withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline_rounded,
                                      color: Color(0xFF2E7D32),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        "Mật khẩu mới sẽ được áp dụng ngay lập tức. Bạn sẽ cần sử dụng mật khẩu mới cho lần đăng nhập tiếp theo.",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF2E7D32),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 25),

                              // Change Password Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _changePassword,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    backgroundColor: Color(0xFF4CAF50),
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
                                      Icon(Icons.lock_reset_rounded, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(
                                        "Đổi mật khẩu",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 15),

                              // Cancel Button
                              SizedBox(
                                width: double.infinity,
                                child: TextButton(
                                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      side: BorderSide(
                                        color: Color(0xFF4CAF50),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    "Hủy",
                                    style: TextStyle(
                                      color: Color(0xFF4CAF50),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
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

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
