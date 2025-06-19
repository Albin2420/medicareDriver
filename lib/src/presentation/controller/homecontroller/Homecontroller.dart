// controllers are use in this folder

import 'dart:developer';

import 'package:flutter/foundation.dart';
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

import 'package:web_socket_channel/web_socket_channel.dart';

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

  WebSocketChannel? channel;

  final latlng.LatLng start = latlng.LatLng(10.1081324, 76.3585433);
  final latlng.LatLng end = latlng.LatLng(10.120000, 76.360000);

  final RxList<latlng.LatLng> routePoints = RxList<latlng.LatLng>();

  ValueNotifier<String?> socketMessage = ValueNotifier(null);

  final openrouteservice = OpenRouteService(
    apiKey: fs.dotenv.env['ORS_API_KEY'] ?? 'defaultApi',
    defaultProfile: ORSProfile.drivingCar,
  );

  var isready;

  @override
  void onInit() async {
    super.onInit();
    log("Home controller initialized");
    accessToken.value = (await ctrlr.getAccessToken())!;
    startListeningToLocation();
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

      _positionStream!.listen((Position position) async {
        log("pos : ${position.latitude} ${position.longitude}");
        lat.value = position.latitude;
        long.value = position.longitude;

        isready = await lcrepo.location(
          longitude: position.longitude,
          latitude: position.latitude,
          accesstoken: accessToken.value,
        );
        isready.fold((l) {}, (r) {
          //listen to socket for observe the requests
        });
      });
      connect(id: 1);
    } catch (e) {
      log("error in startListeningToLocation():$e");
    }
  }

  void connect({required int id}) {
    try {
      final uri = Uri.parse('ws://13.203.89.173:8001/ws/driver/$id');

      channel = WebSocketChannel.connect(uri);
      log('🔌 Connecting to $uri');

      channel!.stream.listen(
        (data) {
          log('✅ Message from server: $data');
          socketMessage.value = data; // Push to UI
        },
        onDone: () {
          log('❌ Connection closed.');
        },
        onError: (error) {
          log('🚨 Stream error: $error');
        },
        cancelOnError: true,
      );
    } catch (e, stack) {
      log("❗ Exception in connect(): $e\n$stack");
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
