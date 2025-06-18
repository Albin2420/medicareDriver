import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GradientBorderContainer extends StatelessWidget {
  final String name;
  final VoidCallback onTap; // Callback added

  const GradientBorderContainer({
    super.key,
    required this.name,
    required this.onTap, // Required parameter
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap, // Trigger callback on tap
        child: Container(
          width: 210,
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF51507F), Color(0xFF27264D)],
              stops: [0.0209, 1.044],
              transform: GradientRotation(90.83 * 3.1416 / 180),
            ),
            border: Border.all(width: 0.5, color: Colors.transparent),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Text(
              name,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
