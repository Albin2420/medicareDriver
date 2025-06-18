// controllers are use in this folder

import 'dart:developer';

import 'package:flutter/semantics.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:medicaredriver/src/data/repositories/location/locationrepoimpl.dart';
import 'package:medicaredriver/src/domain/repositories/location/locationrepo.dart';
import 'package:medicaredriver/src/presentation/controller/appstartupcontroller/appstartupcontroller.dart';
import 'package:medicaredriver/src/presentation/screens/Home/home.dart';
import 'package:open_route_service/open_route_service.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart' as fs;

class Homecontroller extends GetxController {
  RxBool hasShownSheet = RxBool(false);
  Stream<Position>? _positionStream;
  RxDouble lat = RxDouble(0.0);
  RxDouble long = RxDouble(0.0);
  RxString location = RxString("initial");

  RxBool deniedforver = RxBool(false);

  Locationrepo lcrepo = Locationrepoimpl();

  RxString accessToken = RxString("initial");

  final ctrlr = Get.find<Appstartupcontroller>();

  //ambulance details
  RxString ambulancestatus = RxString("Ambulance requested...");
  RxString ambulanceRegNumber = RxString("");
  RxString bookingId = RxString("");
  RxString mobNo = RxString("");
  RxString? eta = RxString("");
  RxString name = RxString("");

  final latlng.LatLng start = latlng.LatLng(10.1081324, 76.3585433);
  final latlng.LatLng end = latlng.LatLng(10.120000, 76.360000);

  final RxList<latlng.LatLng> routePoints = RxList<latlng.LatLng>();

  final openrouteservice = OpenRouteService(
    apiKey: fs.dotenv.env['ORS_API_KEY'] ?? 'defaultApi',
    defaultProfile: ORSProfile.drivingCar,
  );

  @override
  void onInit() async {
    super.onInit();
    log("Home controller initialized");
    startListeningToLocation();
    accessToken.value = (await ctrlr.getAccessToken())!;
  }

  Future<void> startListeningToLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          log("denied forever");
          deniedforver.value = true;
          return;
        }
      }

      // Start listening to the position stream
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 20, // meters (minimum distance before update)
        ),
      );

      _positionStream!.listen((Position position) {
        log("pos : ${position.latitude} ${position.longitude}");
        lat.value = position.latitude;
        long.value = position.longitude;

        getAddressFromLatLng(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      });
    } catch (e) {
      log("error:$e");
    }
  }

  Future<void> getAddressFromLatLng({
    required latitude,
    required longitude,
  }) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        location.value =
            '${place.name}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea} ,${place.postalCode}';

        log("final loc : $location");

        getRoute();
      }
    } catch (e) {
      log('Error in reverse geocoding: $e');
    }
  }

  void registerEmergency() async {
    if (accessToken.value != "initial" && accessToken.value != "") {
      try {
        EasyLoading.show();
        final res = await lcrepo.location(
          longitude: long.value,
          latitude: lat.value,
          landmark: location.value,
          accesstoken: accessToken.value,
        );
        res.fold(
          (l) {
            EasyLoading.dismiss();
            log("failed");
          },
          (R) {
            EasyLoading.dismiss();
            ambulanceRegNumber.value = R["ambulance_number"];
            bookingId.value = R["id"];
            mobNo.value = R["mobileNo"];
            eta?.value = R["eta_minutes"];
            name.value = R['Name'];
            ambulancestatus.value = "Ambulance is on the way!";
          },
        );
        Get.to(() => Home());
      } catch (e) {
        EasyLoading.dismiss();
        log("Error in registerEmergency() :$e");
      }
    }
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    try {
      bool? res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    } catch (e) {
      log("error:$e");
    }
  }

  Future<void> getRoute() async {
    try {
      final routeCoordinates = await openrouteservice.directionsRouteCoordsGet(
        startCoordinate: ORSCoordinate(
          latitude: start.latitude,
          longitude: start.longitude,
        ),
        endCoordinate: ORSCoordinate(
          latitude: end.latitude,
          longitude: end.longitude,
        ),
      );

      routePoints.value = routeCoordinates
          .map((e) => latlng.LatLng(e.latitude, e.longitude))
          .toList();

      log("route :$routePoints");
    } catch (e) {
      log('Route error: $e');
    }
  }
}
