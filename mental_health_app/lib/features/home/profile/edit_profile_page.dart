import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _fullNameController = TextEditingController();
  File? _selectedImage;
  String? _currentAvatarUrl;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;
  final Dio _dio = Dio();
  DateTime? _selectedBirthday;
  String? _selectedGender;

  final List<String> _genderOptions = ['Nam', 'Nữ', 'Khác'];

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  void _loadCurrentUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _fullNameController.text = user.displayName ?? '';
      try {
        final response =
            await _dio.get('http://10.0.2.2:8000/user/firebase/${user.uid}');
        if (response.statusCode == 200) {
          final data = response.data;
          setState(() {
            _currentAvatarUrl = data['avatar_url'];
            _selectedGender = data['gender'];
            if (data['birthday'] != null &&
                data['birthday'].toString().isNotEmpty) {
              _selectedBirthday = DateTime.tryParse(data['birthday']);
            }
          });
        }
      } catch (e) {
        // log lỗi nếu cần
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showSnackBar('Lỗi chọn ảnh: ${e.toString()}', isError: true);
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    try {
      final bytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);
      return 'data:image/jpeg;base64,$base64Image';
    } catch (e) {
      _showSnackBar('Lỗi tải ảnh: ${e.toString()}', isError: true);
      return null;
    }
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
        ),
      ),
      child: const Icon(
        Icons.person_rounded,
        size: 60,
        color: Colors.white,
      ),
    );
  }

  Future<void> _updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('Không tìm thấy người dùng', isError: true);
      return;
    }

    if (_fullNameController.text.trim().isEmpty) {
      _showSnackBar('Vui lòng nhập họ tên', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? avatarUrl = _currentAvatarUrl;

      if (_selectedImage != null) {
        avatarUrl = await _uploadImage();
      }

      final response = await _dio.put(
        'http://10.0.2.2:8000/user/update-profile',
        data: {
          'uid': user.uid,
          'full_name': _fullNameController.text.trim(),
          'avatar_url': avatarUrl ?? '',
          'gender': _selectedGender,
          'birthday': _selectedBirthday?.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        await user.updateDisplayName(_fullNameController.text.trim());
        await user.reload();
        _showSnackBar('Cập nhật thông tin thành công!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showSnackBar('Lỗi cập nhật thông tin: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E8), Color(0xFFF5FFFA)],
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
                        child: const Icon(Icons.arrow_back_ios_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        "Chỉnh sửa thông tin",
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
                      onTap: _isLoading ? null : _updateProfile,
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _isLoading
                                ? [Colors.grey, Colors.grey]
                                : [Color(0xFF66BB6A), Color(0xFF4CAF50)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.save_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Avatar
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 120,
                            height: 120,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
                              ),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF4CAF50).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: _selectedImage != null
                                  ? Image.file(_selectedImage!, fit: BoxFit.cover)
                                  : _currentAvatarUrl != null &&
                                          _currentAvatarUrl!.isNotEmpty
                                      ? Image.network(
                                          _currentAvatarUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return _buildDefaultAvatar();
                                          },
                                        )
                                      : _buildDefaultAvatar(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Nhấn để thay đổi ảnh",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF66BB6A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Form Container
                        Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Thông tin cá nhân",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                label: "Họ và tên",
                                controller: _fullNameController,
                                hint: "Nhập họ và tên của bạn",
                                icon: Icons.person_rounded,
                              ),
                              const SizedBox(height: 20),
                              _buildDatePicker(),
                              const SizedBox(height: 20),
                              _buildGenderDropdown(),
                              const SizedBox(height: 30),
                              _buildSaveButton(),
                              const SizedBox(height: 15),
                              _buildCancelButton(),
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
      ),
    );
  }

  // === Custom Widgets with color effects ===

  Widget _buildTextField(
      {required String label,
      required TextEditingController controller,
      required String hint,
      required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Color(0xFF4CAF50)),
            filled: true,
            fillColor: const Color(0xFFE8F5E8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Color(0xFF4CAF50),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Ngày sinh",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedBirthday ?? DateTime(2000, 1, 1),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              helpText: "Chọn ngày sinh",
            );
            if (picked != null) {
              setState(() {
                _selectedBirthday = picked;
              });
            }
          },
          borderRadius: BorderRadius.circular(15),
          splashColor: const Color(0xFF4CAF50).withOpacity(0.3),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E8),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const Icon(Icons.cake_rounded, color: Color(0xFF66BB6A)),
                const SizedBox(width: 10),
                Text(
                  _selectedBirthday != null
                      ? "${_selectedBirthday!.day.toString().padLeft(2, '0')}/${_selectedBirthday!.month.toString().padLeft(2, '0')}/${_selectedBirthday!.year}"
                      : "Chọn ngày sinh",
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedBirthday != null
                        ? Colors.black87
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Giới tính",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E8),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFF4CAF50), width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedGender,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF4CAF50)),
              items: _genderOptions
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedGender = val;
                });
              },
              dropdownColor: Colors.white,
              style: const TextStyle(color: Colors.black87, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return InkWell(
      onTap: _isLoading ? null : _updateProfile,
      borderRadius: BorderRadius.circular(15),
      splashColor: Colors.greenAccent.withOpacity(0.4),
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  "Lưu thay đổi",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(15),
      splashColor: Colors.redAccent.withOpacity(0.2),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.redAccent, width: 1.5),
        ),
        child: const Text(
          "Hủy",
          style: TextStyle(
              color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
