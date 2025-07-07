import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:medicaredriver/src/presentation/screens/splash/splashscreen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MediCare',
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(),
      home: Splashscreen(),
    );
  }
}
