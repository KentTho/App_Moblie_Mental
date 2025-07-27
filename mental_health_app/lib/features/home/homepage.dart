import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mental_health_app/features/auth/page/login.dart';
import 'package:mental_health_app/features/charts/page/emotion_chart_page.dart';
import 'package:mental_health_app/features/chatbot/page/chatbot_page.dart';
import 'package:mental_health_app/features/diary/screen/diary_screen.dart';
import 'package:mental_health_app/features/home/profile/profile_page.dart';
import 'package:mental_health_app/features/suggestions/page/suggestion_list_page.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with TickerProviderStateMixin {
  User? get user => FirebaseAuth.instance.currentUser;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> signout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Login()),
      );
    }
  }

  Widget _buildFeatureCard({
  required IconData icon,
  required String title,
  required String subtitle,
  required Color iconColor,
  required Color backgroundColor,
  required VoidCallback onTap,
  bool isLarge = false,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: isLarge ? 240 : 200, // ← Tăng chiều cao để tránh overflow
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D1D1F),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
              maxLines: isLarge ? 4 : 3, // ← tăng maxLines để tránh tràn
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
  );
}


  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              slivers: [
                // Custom App Bar
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      children: [
                        // Profile Avatar
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ProfilePage()),
                            );
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Greeting
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getGreeting(),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                _getUserName(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1D1D1F),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Settings Button
                       // Logout Button
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: signout,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.logout_rounded,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Quick Actions Section
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Quick Actions",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1D1D1F),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildQuickActionButton(
                              icon: Icons.add_circle_outline_rounded,
                              label: "New Entry",
                              color: const Color(0xFF34C759),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const DiaryScreen()),
                                );
                              },
                            ),
                            _buildQuickActionButton(
                              icon: Icons.chat_bubble_outline_rounded,
                              label: "Chat",
                              color: const Color(0xFF007AFF),
                              onTap: () {
                                // Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotPage()));
                              },
                            ),
                            _buildQuickActionButton(
                              icon: Icons.insights_rounded,
                              label: "Insights",
                              color: const Color(0xFFFF9500),
                              onTap: () {
                                // Navigator.push(context, MaterialPageRoute(builder: (_) => const EmotionChartPage()));
                              },
                            ),
                            _buildQuickActionButton(
                              icon: Icons.notifications_none_rounded,
                              label: "Reminders",
                              color: const Color.fromARGB(255, 247, 35, 229),
                              onTap: () {
                                // Navigator.push(context, MaterialPageRoute(builder: (_) => const ReminderListPage()));
                              },
                            ),
                            _buildQuickActionButton(
                              icon: Icons.logout_rounded,
                              label: "Logout",
                              color: Colors.redAccent,
                              onTap: signout,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Main Features Section
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Your Wellbeing Tools",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1D1D1F),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // First Row - Diary (Large) + Chart
                        Row(
                          children: [
                            // Diary - Large Card
                            Expanded(
                              child: _buildFeatureCard(
                                icon: Icons.book_outlined,
                                title: "Emotion Diary",
                                subtitle: "Track your daily emotions and thoughts. Build healthy habits through reflection.",
                                iconColor: const Color(0xFF34C759),
                                backgroundColor: Colors.white,
                                isLarge: true,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const DiaryScreen()),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Chart
                            Expanded(
                              child: _buildFeatureCard(
                                icon: Icons.analytics_outlined,
                                title: "Progress Chart",
                                subtitle: "View your emotional patterns",
                                iconColor: const Color(0xFFFF9500),
                                backgroundColor: Colors.white,
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const EmotionChartPage()));
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Second Row - Chatbot + Reminders
                        Row(
                          children: [
                            // Chatbot
                            Expanded(
                              child: _buildFeatureCard(
                                icon: Icons.psychology_outlined,
                                title: "AI Assistant",
                                subtitle: "Chat with your personal wellbeing companion",
                                iconColor: const Color(0xFF007AFF),
                                backgroundColor: Colors.white,
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotPage()));
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Reminders
                            Expanded(
                              child: _buildFeatureCard(
                                icon: Icons.schedule_outlined,
                                title: "Smart Reminders",
                                subtitle: "Never miss your self-care routine",
                                iconColor: const Color(0xFFFF3B30),
                                backgroundColor: Colors.white,
                                onTap: () {
                                  // Navigator.push(context, MaterialPageRoute(builder: (_) => const ReminderListPage()));
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Third Row - Suggestions (Full Width)
                        _buildFeatureCard(
                          icon: Icons.lightbulb_outline_rounded,
                          title: "Wellness Suggestions",
                          subtitle: "Personalized tips and activities to improve your mental health and daily routine",
                          iconColor: const Color(0xFF5856D6),
                          backgroundColor: Colors.white,
                          isLarge: true,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const SuggestionListPage()));
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Today's Inspiration Section
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Today's Inspiration",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1D1D1F),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF667eea),
                                Color(0xFF764ba2),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667eea).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.favorite_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Your mental health matters",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Take a moment today to check in with yourself. Small steps lead to big changes in your wellbeing journey.",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Spacing
                const SliverToBoxAdapter(
                  child: SizedBox(height: 40),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 17) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  String _getUserName() {
    if (user?.email != null) {
      return user!.email!.split('@')[0].split('.').map((name) => 
        name[0].toUpperCase() + name.substring(1)
      ).join(' ');
    }
    return "Welcome Back";
  }
}