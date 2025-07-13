import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mental_health_app/features/diary/core/constants.dart';

class NewNoteDiaLog extends StatelessWidget {
  const NewNoteDiaLog({
    super.key,
    required this.onTagAdded,
    required this.tagController,
  });

  final void Function(String tag) onTagAdded;
  final TextEditingController tagController;

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormFieldState> tagKey = GlobalKey<FormFieldState>();

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
        TextFormField(
          key: tagKey,
          controller: tagController,
          autofocus: true,
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
            isDense: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          validator: (value) {
            if (value!.trim().isEmpty) {
              return 'No Tags added';
            } else if (value.trim().length > 16) {
              return 'Tags should not be more than 16 characters';
            }
            return null;
          },
          onChanged: (_) => tagKey.currentState?.validate(),
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
              final newTag = tagController.text.trim();

              // Nếu hợp lệ, pop ra tag và để callback xử lý ở nơi gọi showDialog
              if (tagKey.currentState?.validate() ?? false) {
                Navigator.pop(context, newTag); // Trả tag về nơi gọi
              }
            },
          ),
        ),
      ],
    );
  }
}
