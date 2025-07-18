import 'package:flutter/material.dart';
import '../core/constants.dart';

class NoNotes extends StatelessWidget {
  const NoNotes({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 80,
            color: gray500,
          ),
          const SizedBox(height: 16),
          Text(
            'No diary entries yet',
            style: TextStyle(
              fontSize: 18,
              color: gray500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to create your first entry',
            style: TextStyle(
              fontSize: 14,
              color: gray500,
            ),
          ),
        ],
      ),
    );
  }
}
