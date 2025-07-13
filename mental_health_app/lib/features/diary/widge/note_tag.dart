import 'package:flutter/material.dart';
import 'package:mental_health_app/features/diary/core/constants.dart';

class NoteTag extends StatelessWidget {
  const NoteTag({
    required this.label,
    this.onCLosed,
    super.key,
  });


  final String label;
  final VoidCallback? onCLosed;


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color.fromARGB(255, 206, 206, 206),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 2,
      ),
      margin: const EdgeInsets.only(right: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: onCLosed != null ? 14 : 12,
              color: gray700,
            ),
          ),
          if(onCLosed != null) ... {
            SizedBox(width: 4,),
            GestureDetector(
              onTap: onCLosed,
              child:const Icon(
                size: 18,
                Icons.close
              )
            )
          }

        ],
      ),
    );
  }
}