import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mental_health_app/features/diary/core/constants.dart';

class NoteButton extends StatelessWidget {
  const NoteButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isOutlined = false,
  });


  final String label;
  final VoidCallback? onPressed;
  final bool isOutlined;
final IconData? icon;
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            offset: Offset(2, 2),
            color: isOutlined ? primaryColor : black,
          ),
        ],
        borderRadius: BorderRadius.circular(8)
      ),
      child: ElevatedButton.icon(
        icon: icon != null ? FaIcon(icon, size: 18) : const SizedBox.shrink(),
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? white : primaryColor,
          foregroundColor: isOutlined ? primaryColor : Colors.white,
          side: BorderSide(color: isOutlined ? primaryColor : black),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 5,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: onPressed, label:Text(label),
      )
     );
  }
}
