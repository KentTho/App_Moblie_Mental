import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mental_health_app/features/auth/page/register_page.dart';
import 'package:mental_health_app/features/home/homepage.dart';
import 'package:http/http.dart' as http;


class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  Future<void> signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );

      // ✅ Chuyển sang trang Homepage sau khi đăng nhập thành công
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (_) => const Homepage()),
      // );

      if (FirebaseAuth.instance.currentUser != null) {
        // Đã đăng nhập → sang Homepage
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Homepage()));
      } else {
        // Chưa đăng nhập → ở lại LoginPage
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng nhập thất bại: ${e.toString()}')),
      );
    }


    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/user/firebase"), // Gửi về FastAPI
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": user.email,
          "uid": user.uid,
          "full_name": user.displayName ?? "Người dùng",
        }),
      );

      if (response.statusCode == 200) {
        print("Đã lưu user vào PostgreSQL");
      } else {
        print("Lỗi: ${response.body}");
      }
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline, size: 80, color: Color(0xFF2E7D32)),
                    SizedBox(height: 16),
                    Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Login to continue",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    SizedBox(height: 32),

                    TextField(
                      controller: email,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF66BB6A)),
                        filled: true,
                        fillColor: Color(0xFFE8F5E8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    TextField(
                      controller: password,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF66BB6A)),
                        filled: true,
                        fillColor: Color(0xFFE8F5E8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => signIn(),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Color(0xFF4CAF50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          "LOGIN",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterPage()),
                        );
                      },
                      child: Text(
                        "Don't have an account? Register",
                        style: TextStyle(color: Color(0xFF2E7D32)),
                      ),
                    )

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}
