import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/constants.dart';

class NoteIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onPressed;

  const NoteIconButton({
    super.key,
    required this.icon,
    this.size = 24,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: primaryColor.withOpacity(0.1),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FaIcon(icon, size: size, color: gray700),
        ),
      ),
    );
  }
}
