import 'dart:developer';

import 'package:get/get.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:medicaredriver/src/data/repositories/tokenRepoImpl/tokenRepoImpl.dart';
import 'package:medicaredriver/src/domain/repositories/token/tokenRepo.dart';
import 'package:medicaredriver/src/presentation/screens/Home/home.dart';
import 'package:medicaredriver/src/presentation/screens/login/login.dart';

class Appstartupcontroller extends GetxController {
  final _secureStorage = FlutterSecureStorage();
  Tokenrepo tokenrepo = Tokenrepoimpl();

  @override
  void onInit() {
    log("appstartup controller");
    super.onInit();
    checktoken();
  }

  Future<void> checktoken() async {
    var tk = await getAccessToken();

    if (tk == null || tk == '') {
      Get.offAll(() => Login());
    } else {
      final res = await tokenrepo.checkToken(accesstoken: tk);
      res.fold(
        (l) {
          Get.offAll(() => Login());
        },
        (r) {
          if (r['expired'] == false) {
            Get.offAll(() => Home());
          } else {
            Get.offAll(() => Login());
          }
        },
      );
    }
  }

  Future<void> saveAccessToken({required String token}) async {
    try {
      await _secureStorage.write(key: 'access_token', value: token);
    } catch (e) {
      log("error in saveAccessToken():$e");
    }
  }

  Future<void> saveId({required String id}) async {
    await _secureStorage.write(key: 'userId', value: id);
  }

  Future<int> getId() async {
    final userIdString = await _secureStorage.read(key: 'userId');
    return int.parse(userIdString ?? '0');
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: 'access_token');
  }

  Future<void> saveRideId({required String rideId}) async {
    await _secureStorage.write(key: 'rideId', value: rideId);
  }

  Future<int> getRideId() async {
    final rideId = await _secureStorage.read(key: 'rideId');
    return int.parse(rideId ?? '-1');
  }

  Future<void> clearRideId() async {
    await _secureStorage.delete(key: 'rideId');
  }
}
