import 'package:flutter/material.dart';

class avatar_profile extends StatelessWidget {
  const avatar_profile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
        color: Color(0xFF1E2A47),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
          strokeWidth: 2,
        ),
      ),
    );
  }
}