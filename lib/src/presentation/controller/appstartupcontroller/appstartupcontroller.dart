import 'dart:developer';

import 'package:get/get.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:medicaredriver/src/presentation/screens/Home/home.dart';
import 'package:medicaredriver/src/presentation/screens/login/login.dart';
import 'package:medicaredriver/src/presentation/screens/splash/splashscreen.dart';

class Appstartupcontroller extends GetxController {
  final _secureStorage = FlutterSecureStorage();

  @override
  void onInit() {
    log("appstartup controller");
    super.onInit();
    checktoken();
  }

  Future<void> checktoken() async {
    await Future.delayed(Duration(seconds: 1, microseconds: 500));
    // Your task here
    var tk = await getAccessToken();

    if (tk == null) {
      Get.offAll(() => Login());
    } else {
      Get.offAll(() => Home());
    }
  }

  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: 'access_token', value: token);
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: 'access_token');
  }

  Future<void> deleteAccessToken() async {
    await _secureStorage.delete(key: 'access_token');
  }
}
