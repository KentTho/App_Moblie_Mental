import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mental_health_app/features/home/profile/edit_profile_page.dart';
import 'package:mental_health_app/features/security/security_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Mock data for demonstration - in real app, this would come from your database
  Future<Map<String, dynamic>> getUserData(User user) async {
    final uid = user.uid;
    final response = await http.get(Uri.parse("http://10.0.2.2:8000/user/firebase/$uid"));
    // 🛠 thay bằng IP backend thực tế


    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'id': data['id'],
        'email': data['email'],
        'password': '••••••••',
        'full_name': data['full_name'] ?? 'Người dùng',
        'role': data['role'] ?? 'user',
        'is_verified': data['is_verified'] ?? false,
        'avatar_url': data['avatar_url'] ?? '',
        'birthday': data['birthday'], // ISO date string
        'gender': data['gender'],     // 'Nam' / 'Nữ' / etc.
        'created_at': DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
        'updated_at': DateTime.tryParse(data['updated_at'] ?? '') ?? DateTime.now(),
      };
    } else {
      throw Exception("Không thể tải thông tin người dùng.");
    }
  }


  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE8F5E8), // Soft mint green
              Color(0xFFF0FFF0), // Honeydew
              Color(0xFFF5FFFA), // Mint cream
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF4CAF50).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        "Thông tin cá nhân",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage()));
                      },
                      child:Container(
                        padding: const EdgeInsets.all(8),

                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 20,

                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: user == null
                      ? _buildNoUserState()
                      : FutureBuilder<Map<String, dynamic>>(
                    future: getUserData(user),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Lỗi: ${snapshot.error}"));
                      } else if (!snapshot.hasData) {
                        return const Center(child: Text("Không có dữ liệu người dùng"));
                      }
                      final userData = snapshot.data!;
                      return _buildUserProfile(context, userData);
                    },
                  ),

                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoUserState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.person_off_rounded,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Không tìm thấy người dùng",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context, Map<String, dynamic> userData) {

    //final userData = getUserData(user);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFFFF), Color(0xFFF8FFF8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF4CAF50).withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Avatar
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: userData['avatar_url'] != null && userData['avatar_url'].isNotEmpty
                      ? CachedNetworkImage(
                    imageUrl: userData['avatar_url'],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(
                        Icons.error_outline,
                        size: 50,
                        color: Colors.redAccent,
                      ),
                    ),
                  )
                      : Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                // full_name
                Text(
                  userData['full_name'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 8),

                // Role Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getRoleColors(userData['role']),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getRoleText(userData['role']),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),

              ],
            ),
          ),

          const SizedBox(height: 25),

          // User Information Cards
          _buildInfoCard(
            icon: Icons.email_rounded,
            title: "Email",
            value: userData['email'],
            subtitle: userData['is_verified'] ? "Đã xác thực" : "Chưa xác thực",
            colors: [const Color(0xFF4CAF50), const Color(0xFF66BB6A)],
            isVerified: userData['is_verified'],
          ),

          const SizedBox(height: 15),

          _buildInfoCard(
            icon: Icons.fingerprint_rounded,
            title: "User ID",
            value: userData['id'],
            subtitle: "Mã định danh duy nhất",
            colors: [const Color(0xFF2E7D32), const Color(0xFF388E3C)],
          ),

          const SizedBox(height: 15),

          _buildInfoCard(
            icon: Icons.lock_rounded,
            title: "Mật khẩu",
            value: userData['password'],
            subtitle: "Bảo mật tài khoản",
            colors: [const Color(0xFF66BB6A), const Color(0xFF81C784)],
          ),

          const SizedBox(height: 15),

          if (userData['birthday'] != null)
            _buildInfoCard(
              icon: Icons.cake_rounded,
              title: "Ngày sinh",
              value: _formatDate(DateTime.parse(userData['birthday'])),
              subtitle: "Ngày sinh của bạn",
              colors: [Color(0xFF81C784), Color(0xFFB2FF59)],
            ),


          const SizedBox(height: 15),

          if (userData['gender'] != null)
            _buildInfoCard(
              icon: Icons.wc_rounded,
              title: "Giới tính",
              value: userData['gender'],
              subtitle: "Giới tính được khai báo",
              colors: [Color(0xFF80CBC4), Color(0xFF4DB6AC)],
            ),

          const SizedBox(height: 15),

          _buildInfoCard(
            icon: Icons.access_time_rounded,
            title: "Ngày tạo tài khoản",
            value: _formatDate(userData['created_at']),
            subtitle: "Thành viên từ",
            colors: [const Color(0xFF81C784), const Color(0xFF9CCC65)],
          ),

          const SizedBox(height: 15),

          _buildInfoCard(
            icon: Icons.update_rounded,
            title: "Cập nhật gần nhất",
            value: _formatDate(userData['updated_at']),
            subtitle: "Lần cuối hoạt động",
            colors: [const Color(0xFF4CAF50), const Color(0xFF8BC34A)],
          ),

          const SizedBox(height: 30),


          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.edit_rounded,
                  label: "Chỉnh sửa",
                  colors: [const Color(0xFF66BB6A), const Color(0xFF4CAF50)],
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage()));
                  },
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.security_rounded,
                  label: "Bảo mật",
                  colors: [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityPage()));
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required List<Color> colors,
    bool? isVerified,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: colors.first.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    if (isVerified != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isVerified ? Color(0xFF4CAF50) : Color(0xFFFF9800),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isVerified ? Icons.verified_rounded : Icons.pending_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4A5568),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getRoleColors(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return [const Color(0xFF2E7D32), const Color(0xFF388E3C)];
      case 'expert':
        return [const Color(0xFF4CAF50), const Color(0xFF66BB6A)];
      default:
        return [const Color(0xFF66BB6A), const Color(0xFF81C784)];
    }
  }

  String _getRoleText(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Quản trị viên';
      case 'expert':
        return 'Chuyên gia';
      default:
        return 'Người dùng';
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}
