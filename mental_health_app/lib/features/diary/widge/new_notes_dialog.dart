
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mental_health_app/features/diary/core/constants.dart';
class NewNoteDiaLog extends StatelessWidget {
  const NewNoteDiaLog({
    super.key,
    required this.onTagAdded, required TextEditingController tagController,
  });

  final void Function(String tag) onTagAdded;



  @override
  Widget build(BuildContext context) {
    final TextEditingController _tagController = TextEditingController(); // ✅ Tạo tại đây
    final GlobalKey<FormFieldState> tagkey = GlobalKey<FormFieldState>();


    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            '✨ Add a Tag',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5F5F5F),
              fontFamily: 'Fredo',
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          key: tagkey,
          controller: _tagController,
          maxLength: 16,
          decoration: InputDecoration(
            hintText: 'Enter tag (max 16 chars)',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(FontAwesomeIcons.plus, size: 16),
            label: const Text('Add Tag'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 5,
            ),
            onPressed: () {
              final newTag = _tagController.text.trim();
              if (newTag.isNotEmpty && newTag.length <= 16) {
                onTagAdded(newTag); // Gọi callback
              }
            },
          ),
        )
      ],
    );
  }
}
