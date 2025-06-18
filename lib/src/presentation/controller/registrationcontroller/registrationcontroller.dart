import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:get/get.dart';
import 'package:medicaredriver/src/data/repositories/login/loginrepoImpl.dart';
import 'package:medicaredriver/src/data/repositories/registration/driverRegistrationRepoImpl.dart';
import 'package:medicaredriver/src/domain/repositories/login/loginrepo.dart';
import 'package:medicaredriver/src/domain/repositories/registration/driverRegistrationRepo.dart';

import 'package:medicaredriver/src/presentation/controller/appstartupcontroller/appstartupcontroller.dart';
import 'package:medicaredriver/src/presentation/screens/Home/home.dart';
import 'package:medicaredriver/src/presentation/screens/registration/otp.dart';

class Registrationcontroller extends GetxController {
  final ctrl = Get.find<Appstartupcontroller>();
  TextEditingController firstNamecontroller = TextEditingController();
  TextEditingController secondNamecontroller = TextEditingController();
  TextEditingController phoneNumbercontroller = TextEditingController();
  TextEditingController otpcontroller = TextEditingController();

  //login
  TextEditingController phncontrolller = TextEditingController();
  TextEditingController oTpcontrolller = TextEditingController();

  DriverRegistrationRepo userRepo = DriverRegistrationRepoImpl();
  Loginrepo loginrepo = Loginrepoimpl();

  void checkName() {
    if (firstNamecontroller.text.length >= 3) {
      Get.to(() => Otp());
    }
  }

  void sendotp() {
    Fluttertoast.showToast(
      msg: "We've sent an OTP to your number. Please check your messages",
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  void submitRegistration() async {
    try {
      if (otpcontroller.text == "807456") {
        EasyLoading.show();
        final resp = await userRepo.saveDriver(
          frstName: firstNamecontroller.text,
          secondName: secondNamecontroller.text,
          phoneNumber: phoneNumbercontroller.text,
        );

        resp.fold(
          (l) {
            EasyLoading.dismiss();
            Fluttertoast.showToast(msg: "unable to register");
          },
          (r) {
            ctrl.saveAccessToken(r['access_token']);
            EasyLoading.dismiss();
            // Get.offAll(() => Landingscreen());
          },
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      log("error:$e");
    }
  }

  Future<void> login() async {
    if (oTpcontrolller.text == "807456") {
      final response = await loginrepo.login(phoneNumber: phncontrolller.text);
      response.fold(
        (l) {
          log("failed");
        },
        (R) {
          ctrl.saveAccessToken(R['access_token']);
          Get.offAll(() => Home());
        },
      );
    }
  }
}
