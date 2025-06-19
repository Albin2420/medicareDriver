// import 'dart:developer';

// import 'package:flutter/material.dart';

// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:medicaredriver/src/presentation/controller/registrationcontroller/registrationcontroller.dart';
// import 'package:medicaredriver/src/presentation/widgets/gradientbutton.dart';

// class Otp extends StatelessWidget {
//   const Otp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final ctrl = Get.find<Registrationcontroller>();
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         scrolledUnderElevation: 0,
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         leading: Padding(
//           padding: const EdgeInsets.all(6),
//           child: SizedBox(
//             height: 50,
//             width: 40,
//             child: Image.asset("assets/icons/menu.png"),
//           ),
//         ),
//         title: Text(
//           "MediCare",
//           style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 20),
//         ),
//         flexibleSpace: Column(
//           children: [
//             const Spacer(),
//             Container(
//               height: 1,
//               decoration: BoxDecoration(
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.2),
//                     offset: const Offset(0, 1),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 25),
//         child: Column(
//           children: [
//             SizedBox(height: 80),
//             // Phone Number
//             Row(
//               children: [
//                 Text(
//                   "Phone Number",
//                   style: GoogleFonts.poppins(
//                     fontWeight: FontWeight.w500,
//                     fontSize: 20,
//                     color: const Color(0xff353459),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               onSubmitted: (value) {
//                 if (value.length == 10) {
//                   ctrl.sendotp();
//                   log("User pressed enter with 6-digit OTP: $value");
//                 }
//               },
//               maxLength: 10,
//               // controller: ctrl.phoneNumbercontroller,
//               keyboardType: TextInputType.phone,
//               decoration: InputDecoration(
//                 hintText: "Enter Phone Number",
//                 hintStyle: const TextStyle(color: Colors.black54),
//                 filled: true,
//                 fillColor: const Color(0xffEBEBEF),
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 14,
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(50),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//             SizedBox(height: 36),
//             Row(
//               children: [
//                 Text(
//                   "otp",
//                   style: GoogleFonts.poppins(
//                     fontWeight: FontWeight.w500,
//                     fontSize: 20,
//                     color: const Color(0xff353459),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               maxLength: 6,
//               // controller: ctrl.otpcontroller,
//               keyboardType: TextInputType.phone,
//               decoration: InputDecoration(
//                 hintText: "Enter otp",
//                 hintStyle: const TextStyle(color: Colors.black54),
//                 filled: true,
//                 fillColor: const Color(0xffEBEBEF),
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 14,
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(50),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//             SizedBox(height: 36),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomAppBar(
//         color: Colors.white,
//         elevation: 8,
//         child: GradientBorderContainer(
//           name: "submit",
//           onTap: () {
//             // ctrl.submitRegistration();
//           },
//         ),
//       ),
//     );
//   }
// }
