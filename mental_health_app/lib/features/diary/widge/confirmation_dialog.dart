
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mental_health_app/features/diary/core/constants.dart';
import 'package:mental_health_app/features/diary/widge/note_button.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          FontAwesomeIcons.floppyDisk,
          size: 48,
          color: primaryColor,
        ),
        const SizedBox(height: 16),
        const Text(
          'Save Note?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        const Text('Do you want to save the note?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            NoteButton(
              label: "No",
              icon: FontAwesomeIcons.xmark, // ❌ icon cho từ chối
              onPressed: () => Navigator.pop(context, false),
              isOutlined: true,
            ),
            SizedBox(width: 8,),
            NoteButton(
              label: "Yes",
              icon: FontAwesomeIcons.check, // ✅ icon cho xác nhận
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        )
      ],
    );
  }
}
