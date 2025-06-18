import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Tailer extends StatelessWidget {
  final String title;
  final String description;
  const Tailer({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 18),
        ),
        SizedBox(height: 8),
        Text(
          description,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.normal,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
