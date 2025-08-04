import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mental_health_app/features/auth/page/verifyemail.dart';
import 'package:mental_health_app/features/home/homepage.dart';
import 'package:mental_health_app/features/auth/page/login.dart';
import 'package:mental_health_app/change_notifiers/auth_provider.dart';
class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            channelKey: 'reminder_channel',
            title: message.notification?.title ?? 'Thông báo',
            body: message.notification?.body ?? '',
            notificationLayout: NotificationLayout.Default,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            user.getIdToken().then((token) {
              if (token != null) {
                context.read<AuthProvider>().setUserId(user.uid, token);
              }
            });
          });

          if (user.emailVerified) {
            return const Homepage();
          } else {
            return const VerifyEmailPage();
          }
        }

        return const Login();
      },
    );
  }
}
