import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mental_health_app/features/auth/page/verifyemail.dart';
import 'package:mental_health_app/features/home/homepage.dart';
import 'package:mental_health_app/features/auth/page/login.dart';
import 'package:mental_health_app/change_notifiers/auth_provider.dart';

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
          final user = snapshot.data!;
          final authProvider = Provider.of<AuthProvider>(context, listen: false);

          // 🔐 Gán userId vào AuthProvider
          if (snapshot.hasData) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<AuthProvider>().setUserId(snapshot.data!.uid);
            });
          }


          // 📩 Kiểm tra email đã xác minh chưa
          if (user.emailVerified) {
            return const Homepage(); // Email đã xác thực
          } else {
            return const VerifyEmailPage(); // Chưa xác thực
          }
        }
        // ❌ Chưa đăng nhập
        return const Login();
      },
    );
  }
}
