import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mental_health_app/features/home/homepage.dart';
import 'package:mental_health_app/features/auth/page/login.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ⏳ Đang kết nối tới Firebase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ✅ Đã đăng nhập
        if (snapshot.hasData && snapshot.data != null) {
          return const Homepage();
        }

        // ❌ Chưa đăng nhập
        return const Login();
      },
    );
  }
}
