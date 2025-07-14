import 'package:flutter/material.dart';

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
    final TextEditingController tagController = TextEditingController();
    return Dialog(
      backgroundColor: Colors.white.withOpacity(0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        // On Video Part 3: Name Column changed is NewNoteDiaLog()
        child: child,
      ),
    );
  }
}
