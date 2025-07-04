import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mental_health_app/features/auth/page/login.dart';
import 'package:mental_health_app/features/diary/page/emotion_entry.dart';
import 'package:mental_health_app/features/home/profile/profile_page.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with TickerProviderStateMixin {
  User? get user => FirebaseAuth.instance.currentUser;
  late AnimationController _animationController;
  late AnimationController _floatingController;
  Animation<double>? _fadeAnimation;
  Animation<double>? _floatingAnimation;
  bool _isAnimationReady = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _floatingAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
    
    _animationController.forward().whenComplete(() {
      setState(() {
        _isAnimationReady = true;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _floatingController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildCustomDrawer(context),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF43A047), // Main green from splash
              Color(0xFF66BB6A), // Lighter green
              Color(0xFF81C784), // Even lighter green
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Background Logo with Bright Shadow
            Positioned(
              top: 100,
              right: -50,
              child: AnimatedBuilder(
                animation: _floatingAnimation ?? const AlwaysStoppedAnimation(0.0),
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_floatingAnimation?.value ?? 0, (_floatingAnimation?.value ?? 0) * 0.5),
                    child: Opacity(
                      opacity: 0.1,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 50,
                              spreadRadius: 20,
                              offset: const Offset(0, 0),
                            ),
                            BoxShadow(
                              color: Colors.green.withOpacity(0.2),
                              blurRadius: 80,
                              spreadRadius: 30,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "M",
                            style: TextStyle(
                              fontSize: 120,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF43A047),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Another background logo
            Positioned(
              bottom: 50,
              left: -80,
              child: AnimatedBuilder(
                animation: _floatingAnimation ?? const AlwaysStoppedAnimation(0.0),
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset((_floatingAnimation?.value ?? 0) * -0.5, _floatingAnimation?.value ?? 0),
                    child: Opacity(
                      opacity: 0.08,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.4),
                              blurRadius: 40,
                              spreadRadius: 15,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "M",
                            style: TextStyle(
                              fontSize: 90,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF43A047),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Main Content
            SafeArea(
              child: Column(
                children: [
                  // Bright Custom App Bar with Logo
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.9),
                          Colors.white.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.green.withOpacity(0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Builder(
                          builder: (context) => GestureDetector(
                            onTap: () => Scaffold.of(context).openDrawer(),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.menu_rounded,
                                color: Color(0xFF43A047),
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Logo from splash screen
                              AnimatedBuilder(
                                animation: _floatingAnimation ?? const AlwaysStoppedAnimation(0.0),
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(0, (_floatingAnimation?.value ?? 0) * 0.3),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(0.8),
                                            blurRadius: 20,
                                            spreadRadius: 5,
                                            offset: const Offset(0, 0),
                                          ),
                                          BoxShadow(
                                            color: Colors.green.withOpacity(0.3),
                                            blurRadius: 15,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: const Text(
                                        "M",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF43A047),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Mental Health",
                                style: TextStyle(
                                  fontFamily: 'ArialRoundedMTBold',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF43A047),
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.notifications_rounded,
                            color: Color(0xFF43A047),
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Main Content
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            // Bright Welcome Message
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.9),
                                    Colors.white.withOpacity(0.7),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.6),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.2),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF43A047),
                                          Color(0xFF66BB6A),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.4),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.waving_hand_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Xin chào!",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF2D3748),
                                          ),
                                        ),
                                        Text(
                                          user?.email ?? "Chào mừng bạn",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 25),
                            const Text(
                              "Chăm sóc sức khỏe tinh thần",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Color(0xFF43A047),
                                    blurRadius: 10,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            // Bright Feature Grid
                            Expanded(
                              child: GridView.count(
                                crossAxisCount: 2,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                                childAspectRatio: 1.1,
                                children: [
                                  _buildBrightFeatureButton(
                                    context,
                                    icon: Icons.edit_note_rounded,
                                    label: "Emotion Journal",
                                    subtitle: "Ghi nhật ký cảm xúc",
                                    colors: [const Color(0xFF667eea), const Color(0xFF764ba2)],
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => const EmotionEntry()));
                                    },
                                  ),
                                  _buildBrightFeatureButton(
                                    context,
                                    icon: Icons.psychology_rounded,
                                    label: "AI Analysis",
                                    subtitle: "Phân tích cảm xúc",
                                    colors: [const Color(0xFFf093fb), const Color(0xFFf5576c)],
                                    onTap: () {
                                      // TODO: điều hướng tới trang AI phân tích cảm xúc
                                    },
                                  ),
                                  _buildBrightFeatureButton(
                                    context,
                                    icon: Icons.insights_rounded,
                                    label: "Emotion Trends",
                                    subtitle: "Lịch sử cảm xúc",
                                    colors: [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
                                    onTap: () {
                                      // TODO: điều hướng tới trang biểu đồ cảm xúc
                                    },
                                  ),
                                  _buildBrightFeatureButton(
                                    context,
                                    icon: Icons.self_improvement_rounded,
                                    label: "Wellness Tips",
                                    subtitle: "Gợi ý thư giãn",
                                    colors: [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
                                    onTap: () {
                                      // TODO: thiền, nhạc, bài viết
                                    },
                                  ),
                                  _buildBrightFeatureButton(
                                    context,
                                    icon: Icons.calendar_month_rounded,
                                    label: "Book Expert",
                                    subtitle: "Đặt lịch chuyên gia",
                                    colors: [const Color(0xFFfa709a), const Color(0xFFfee140)],
                                    onTap: () {
                                      // TODO: trang đặt lịch chuyên gia
                                    },
                                  ),
                                  _buildBrightFeatureButton(
                                    context,
                                    icon: Icons.support_agent_rounded,
                                    label: "SOS Support",
                                    subtitle: "Hỗ trợ khẩn cấp",
                                    colors: [const Color(0xFFa8edea), const Color(0xFFfed6e3)],
                                    onTap: () {
                                      // TODO: hỗ trợ khẩn cấp & AI
                                    },
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
          ],
        ),
      ),
    );
  }

  Widget _buildCustomDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF43A047),
              Color(0xFF66BB6A),
              Color(0xFF81C784),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 40,
                      color: Color(0xFF43A047),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Chào bạn!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    user?.email ?? "No email",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildDrawerItem(
              icon: Icons.person_rounded,
              title: "Thông tin cá nhân",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
              },
            ),
            _buildDrawerItem(
              icon: Icons.settings_rounded,
              title: "Cài đặt",
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _buildDrawerItem(
              icon: Icons.help_outline_rounded,
              title: "Trợ giúp",
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Divider(color: Colors.white.withOpacity(0.5)),
            ),
            _buildDrawerItem(
              icon: Icons.logout_rounded,
              title: "Đăng xuất",
              onTap: () async {
                Navigator.pop(context);
                await signout();
              },
            ),
            const SizedBox(height: 30),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                "💚 Chăm sóc sức khỏe tinh thần mỗi ngày",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }

  Widget _buildBrightFeatureButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String subtitle,
        required List<Color> colors,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: colors.first.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black.withOpacity(0.9),
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}