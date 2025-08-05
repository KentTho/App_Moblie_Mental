import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:mental_health_app/change_notifiers/suggestion_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:mental_health_app/change_notifiers/auth_provider.dart';
import 'package:mental_health_app/change_notifiers/chart_provider.dart';
import 'package:mental_health_app/change_notifiers/chatbot_provider.dart';
import 'package:mental_health_app/change_notifiers/new_note_controller.dart';
import 'package:mental_health_app/change_notifiers/notes_provider.dart';
import 'package:mental_health_app/change_notifiers/reminder_provider.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:mental_health_app/services/api_service.dart';
import 'package:mental_health_app/services/chatbot_service.dart';
import 'package:mental_health_app/wrapper.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Nếu cần xử lý thông báo trong background
  print("🔄 Handling background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized!');
  } catch (e) {
    print('❌ Firebase init failed: $e');
  }

  // ✅ Khởi tạo Awesome Notifications
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'reminder_channel',
        channelName: 'Reminder Notifications',
        channelDescription: 'Channel for reminders',
        defaultColor: Colors.teal,
        ledColor: Colors.white,
        importance: NotificationImportance.High,
      )
    ],
    debug: true,
  );

  // ✅ Xin quyền gửi thông báo nếu chưa được cấp
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  // ✅ Cấu hình nhận thông báo background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ✅ Cấu hình nhận thông báo foreground (hiện khi app đang mở)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('📩 Foreground message received: ${message.notification?.title}');
    if (message.notification != null) {
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          channelKey: 'reminder_channel',
          title: message.notification?.title ?? 'Reminder',
          body: message.notification?.body ?? 'You have a new reminder!',
          notificationLayout: NotificationLayout.Default,
        ),
      );
    }
  });
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChartProvider()),
        ChangeNotifierProvider(
          create: (context) {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            return ChatbotProvider(
              chatbotService: ChatbotService(
                apiService: ApiService(),
                getToken: () => authProvider.firebaseToken ?? '',
              ),
            );
          },
        ),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(
          create: (context) => SuggestionProvider(context),
        ),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => NewNoteController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mental Health App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const SplashScreen(),
      localizationsDelegates: const [
        FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
      ],
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    Future.delayed(const Duration(seconds: 3), () {
      Get.off(() => const Wrapper());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF43A047),
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 30,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "M",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF43A047),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  "Mental Health",
                  style: TextStyle(
                    fontFamily: 'ArialRoundedMTBold',
                    fontSize: 26,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
