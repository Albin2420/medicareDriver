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
  TextEditingController vechicleOwnerName = TextEditingController();
  TextEditingController vechicleOwnerPhoneNumber = TextEditingController();
  TextEditingController vechicleOwnerEmailId = TextEditingController();
  TextEditingController vechicleNumber = TextEditingController();

  TextEditingController driverName = TextEditingController();
  TextEditingController driverPhoneNumber = TextEditingController();

  //login
  TextEditingController phncontrolller = TextEditingController();
  TextEditingController oTpcontrolller = TextEditingController();

  DriverRegistrationRepo userRepo = DriverRegistrationRepoImpl();
  Loginrepo loginrepo = Loginrepoimpl();

  void sendotp() {
    Fluttertoast.showToast(
      msg: "We've sent an OTP to your number. Please check your messages",
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  void submitRegistration() async {
    try {
      EasyLoading.show();
      final resp = await userRepo.saveDriver(
        ownerName: vechicleOwnerName.text,
        ownerNumber: vechicleOwnerPhoneNumber.text,
        ownerEmail: vechicleOwnerEmailId.text,
        ambulanceNumber: vechicleNumber.text,
        driverName: driverName.text,
        driverPhoneNumber: driverPhoneNumber.text,
      );

      resp.fold(
        (l) {
          log('ooops');
          EasyLoading.dismiss();
          Fluttertoast.showToast(msg: "unable to register");
        },
        (r) {
          log("token :${r['access_token']}");
          log("id :${r['id']}");
          ctrl.saveAccessToken(
            id: r['id'].toString(),
            token: r['access_token'],
          );
          EasyLoading.dismiss();
          Get.offAll(() => Home());
        },
      );
    } catch (e) {
      EasyLoading.dismiss();
      log("error in submitRegistration() :$e");
    }
  }

  Future<void> login() async {
    try {
      EasyLoading.show();
      if (oTpcontrolller.text == "807456") {
        final response = await loginrepo.login(
          phoneNumber: phncontrolller.text,
        );
        response.fold(
          (l) {
            log("failed");
            EasyLoading.dismiss();
            Fluttertoast.showToast(msg: "oops couldn,t login");
          },
          (R) {
            ctrl.saveAccessToken(
              token: R['access_token'],
              id: R['id'].toString(),
            );
            EasyLoading.dismiss();
            Get.offAll(() => Home());
          },
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      log("error in login():$e");
      Fluttertoast.showToast(msg: "error in login():$e");
    }
  }
}
