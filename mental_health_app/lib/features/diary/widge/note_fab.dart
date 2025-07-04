
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../core/constants.dart';

class NoteFab extends StatelessWidget {
  const NoteFab({
    super.key, required this.onPressed,
  });


  final VoidCallback? onPressed;


  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            const BoxShadow(
              blurRadius: 4,
              color: Colors.black12,
              offset: Offset(4, 4),
            )
          ]
      ),
      child: FloatingActionButton.large(
        onPressed: onPressed,
        backgroundColor: primaryColor,
        foregroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: black, width: 2),
        ),
        child: FaIcon(FontAwesomeIcons.plus),
      ),
    );
  }
}