import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:medicaredriver/src/presentation/controller/appstartupcontroller/appstartupcontroller.dart';

class Splashscreen extends StatelessWidget {
  const Splashscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(Appstartupcontroller());
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Medi",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 33,
                color: Color(0xff353459),
              ),
            ),
            Text(
              "Care",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 33,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
