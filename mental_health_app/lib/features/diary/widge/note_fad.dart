import 'package:flutter/material.dart';

class NoteFab extends StatelessWidget {
  final VoidCallback onPressed;

  const NoteFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Colors.deepPurple, // Consistent with EmotionEntry's theme
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}
