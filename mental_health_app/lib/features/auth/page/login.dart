import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mental_health_app/features/auth/page/forgot.dart';
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

  bool isLoading = false;


  Future<void> signIn() async {
  if (!mounted) return;

  setState(() {
    isLoading = true;
  });

  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.text,
      password: password.text,
    );

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Gửi thông tin người dùng lên server
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/user/firebase"),
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

      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Homepage()));
      return; // tránh gọi setState sau Navigator
    }
  } on FirebaseAuthException catch (e) {
    if (!mounted) return;
    Get.snackbar("Error msg", e.code);
  } catch (e) {
    if (!mounted) return;
    Get.snackbar("Error msg", e.toString());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đăng nhập thất bại: ${e.toString()}')),
    );
  }

  if (!mounted) return;
  setState(() {
    isLoading = false;
  });
}




  Future<void> loginWithGoogle() async {
  try {
    final GoogleAuthProvider googleProvider = GoogleAuthProvider();
    await FirebaseAuth.instance.signInWithProvider(googleProvider);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/user/firebase"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": user.email,
          "uid": user.uid,
          "full_name": user.displayName ?? "Google User",
        }),
      );

      if (response.statusCode == 200) {
        print("Đã lưu user Google vào PostgreSQL");
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Homepage()));
        return;
      } else {
        print("Lỗi Google login: ${response.body}");
      }
    }
  } catch (e) {
    if (!mounted) return;
    print("Lỗi đăng nhập Google: $e");
    Get.snackbar("Google Sign-In Failed", e.toString());
  }
}



Future<void> loginWithGitHub() async {
  try {
    final GithubAuthProvider githubProvider = GithubAuthProvider();
    await FirebaseAuth.instance.signInWithProvider(githubProvider);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/user/firebase"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": user.email,
          "uid": user.uid,
          "full_name": user.displayName ?? "GitHub User",
        }),
      );

      if (response.statusCode == 200) {
        print("Đã lưu user GitHub vào PostgreSQL");
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Homepage()));
        return;
      } else {
        print("Lỗi GitHub login: ${response.body}");
      }
    }
  } catch (e) {
    if (!mounted) return;
    print("Lỗi đăng nhập GitHub: $e");
    Get.snackbar("GitHub Sign-In Failed", e.toString());
  }
}



  @override
  Widget build(BuildContext context) {
    return isLoading ? Center(child: CircularProgressIndicator(),) : Scaffold(
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
                    
                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Get.to(Forgot());
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Color(0xFF2E7D32),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 8),

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

                    SizedBox(height: 16),

                    // OR Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "OR",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),



                    // Sign Up Now Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Get.to(RegisterPage());
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Color(0xFF4CAF50), width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_add_outlined,
                              color: Color(0xFF4CAF50),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "SIGN UP NOW",
                              style: TextStyle(
                                color: Color(0xFF4CAF50),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 16),
                    
                    // Google & GitHub as Floating Circle Buttons
                    // Google & GitHub as Floating Circle Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Google Button
                        GestureDetector(
                          onTap: () => loginWithGoogle(),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Colors.white.withOpacity(0.9), Colors.grey.shade200],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Image.asset(
                                'assets/images/google.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 24),

                        // GitHub Button
                        GestureDetector(
                          onTap: () => loginWithGitHub(),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Colors.black87, Colors.black54],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black45,
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.code,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8),

                    // Alternative text link
                    TextButton(
                      onPressed: () {
                        // Navigator.pushReplacement(
                        //   context,
                        //   MaterialPageRoute(builder: (_) => const RegisterPage()),
                        // );
                        Get.to(RegisterPage());
                      },
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 14),
                          children: [
                            TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            TextSpan(
                              text: "Register here",
                              style: TextStyle(
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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