// screens are use in this folder

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medicaredriver/src/presentation/controller/registrationcontroller/registrationcontroller.dart';
import 'package:medicaredriver/src/presentation/screens/registration/driverRegistration.dart';
import 'package:medicaredriver/src/presentation/widgets/gradientbutton.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(Registrationcontroller());
    // Check if keyboard is visible
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(6),
          child: SizedBox(
            height: 50,
            width: 40,
            child: Image.asset("assets/icons/menu.png"),
          ),
        ),
        title: Text(
          "MediCare",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        flexibleSpace: Column(
          children: [
            const Spacer(),
            Container(
              height: 1,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Title Section
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOutCubic,
                        height: isKeyboardVisible ? 130 : 180,
                        width: double.infinity,
                        color: Colors.white,
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 350),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: isKeyboardVisible ? 24 : 30,
                              color: const Color(0xff353459),
                            ),
                            child: const Text(
                              "Ambulance \n Login",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),

                      // Form Section
                      Expanded(
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),

                              // First Name
                              Text(
                                "Registered Phone Number",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                  color: const Color(0xff353459),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: ctrl.phncontrolller,
                                onSubmitted: (value) {
                                  if (value.length == 10) {
                                    // ctrl.sendotp();
                                    log(
                                      "User pressed enter with 10-digit number: $value",
                                    );
                                  }
                                },
                                maxLength: 10,
                                keyboardType: TextInputType.numberWithOptions(),
                                decoration: InputDecoration(
                                  hintText: "Enter Registered phone No",
                                  hintStyle: const TextStyle(
                                    color: Colors.black54,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xffEBEBEF),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 36),

                              // Last Name
                              Text(
                                "OTP",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                  color: const Color(0xff353459),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: ctrl.oTpcontrolller,
                                maxLength: 6,
                                keyboardType: TextInputType.numberWithOptions(),
                                decoration: InputDecoration(
                                  hintText: "Enter OTP sent to registered no.",
                                  hintStyle: const TextStyle(
                                    color: Colors.black54,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xffEBEBEF),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 36),

                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   children: [
                              //     Text("don't have an account? "),
                              //     GestureDetector(
                              //       onTap: () {
                              //         Get.to(() => DriverRegistration());
                              //       },
                              //       child: Text(
                              //         "Register here",
                              //         style: GoogleFonts.poppins(
                              //           fontWeight: FontWeight.w500,
                              //         ),
                              //       ),
                              //     ),
                              //   ],
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: isKeyboardVisible
          ? const SizedBox.shrink()
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("don't have an account? "),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => DriverRegistration());
                      },
                      child: Text(
                        "Register here",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                GradientBorderContainer(
                  name: 'Submit',
                  onTap: () {
                    ctrl.login();
                  },
                ),
                SizedBox(height: 8),
              ],
            ),
    );
  }
}
