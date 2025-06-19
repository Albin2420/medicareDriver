import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RejectBtn extends StatelessWidget {
  final VoidCallback onPressed;
  const RejectBtn({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Center(
          child: Text(
            "Reject",
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
