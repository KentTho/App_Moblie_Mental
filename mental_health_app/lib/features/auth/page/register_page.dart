import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mental_health_app/features/auth/page/login.dart';
import 'package:dio/dio.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController fullName = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  Future<void> signUp() async {
    try {
      // Tạo tài khoản Firebase
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );

      final user = FirebaseAuth.instance.currentUser;



      // ✅ Cập nhật full name vào Firebase
      if (user != null) {
        await user.updateDisplayName(fullName.text); // 🟢 QUAN TRỌNG!
        await user.reload(); // Refresh lại thông tin
      }

      // ✅ Gửi email xác thực
      // if (!user.emailVerified) {
      //     await user.sendEmailVerification();
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //       content: Text('Email xác thực đã được gửi đến ${user.email}'),
      //     ),
      //   );
      // }

      // ✅ Gửi thông tin về backend (để lưu vào PostgreSQL)
      if (user != null) {
        final dio = Dio();
        await dio.post(
          'http://10.0.2.2:8000/user/firebase',
          data: {
            'email': user.email,
            'uid': user.uid,
            'full_name': fullName.text,
          },
        );
      }

      // ✅ Chuyển trang khi thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created! You can now login.')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Login()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B0D),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                      ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                  ),
                ),
                const SizedBox(height: 40),
                // Full name input
                TextField(
                  controller: fullName,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person, color: Color(0xFF66BB6A)),
                    hintText: 'Enter your full name',
                    hintStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Color(0xFF1B2E1B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: email,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email, color: Color(0xFF66BB6A)),
                    hintText: 'Enter your email',
                    hintStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Color(0xFF1B2E1B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: password,
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock, color: Color(0xFF66BB6A)),
                    hintText: 'Enter your password',
                    hintStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Color(0xFF1B2E1B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Confirm password input
                TextField(
                  controller: confirmPassword,
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF66BB6A)),
                    hintText: 'Confirm your password',
                    hintStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Color(0xFF1B2E1B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const Login()),
                    );
                  },
                  child: Text(
                    "Already have an account? Login",
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
