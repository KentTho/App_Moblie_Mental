import 'package:flutter/material.dart';
import 'package:mental_health_app/features/charts/page/emotion_chart_page.dart';
import 'package:mental_health_app/features/chatbot/page/chatbot_page.dart';
import 'package:mental_health_app/features/diary/screen/diary_screen.dart';
import 'package:mental_health_app/features/home/profile/profile_page.dart';
import 'package:mental_health_app/features/home/homepage.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavItem(
            context,
            icon: Icons.home_rounded,
            label: "Home",
            index: 0,
          ),
          _buildBottomNavItem(
            context,
            icon: Icons.android,
            label: "ChatBot",
            index: 1,
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DiaryScreen()),
              );
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
          _buildBottomNavItem(
            context,
            icon: Icons.show_chart,
            label: "Chart",
            index: 2,
          ),
          _buildBottomNavItem(
            context,
            icon: Icons.person_rounded,
            label: "Profile",
            index: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(BuildContext context,
      {required IconData icon, required String label, required int index}) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (currentIndex == index) return; // tránh mở lại đúng tab hiện tại
        Widget page;
        switch (index) {
          case 0:
            page = const Homepage();
            break;
          case 1:
            page = const ChatbotPage();
            break;
          case 2:
            page = const EmotionChartPage();
            break;
          case 3:
            page = const ProfilePage();
            break;
          default:
            page = const Homepage();
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? Colors.green : Colors.grey, size: 28),
          Text(label,
              style: TextStyle(
                  color: isSelected ? Colors.green : Colors.grey,
                  fontSize: 12)),
        ],
      ),
    );
  }
}
