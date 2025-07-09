import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mental_health_app/features/diary/widge/new_notes_dialog.dart';

class DialogCard extends StatelessWidget {
  const DialogCard({
    super.key,
    required this.onTagAdded,
    required this.child,
  });

  final void Function(String tag) onTagAdded;
  final Widget child;


  @override
  Widget build(BuildContext context) {
    final TextEditingController _tagController = TextEditingController();

    return Dialog(
      backgroundColor: Colors.white.withOpacity(0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        // On Video: Name Column changed is NewNoteDiaLog()
        child: child,
      ),
    );
  }
}
