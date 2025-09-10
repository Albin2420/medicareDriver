import 'dart:convert';
import 'dart:developer';

import 'package:flutter/widgets.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';

import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:medicaredriver/src/data/repositories/check-ride/check-rideRepoImpl.dart';
import 'package:medicaredriver/src/data/repositories/location/commonLocation/locationrepoimpl.dart';
import 'package:medicaredriver/src/data/repositories/location/driverlocationInTrip/tripLocationrepoimpl.dart';
import 'package:medicaredriver/src/data/repositories/response/driverResponseImpl.dart';
import 'package:medicaredriver/src/data/services/hive_services/rideDetails/ride_model.dart';
import 'package:medicaredriver/src/domain/repositories/check-ride/check-rideRepo.dart';
import 'package:medicaredriver/src/domain/repositories/location/commonLocation/locationrepo.dart';
import 'package:medicaredriver/src/domain/repositories/location/driverlocationInTrip/tripLocationRepo.dart';
import 'package:medicaredriver/src/domain/repositories/response/driverresponse.dart';
import 'package:medicaredriver/src/presentation/controller/appstartupcontroller/appstartupcontroller.dart';

import 'package:open_route_service/open_route_service.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart' as fs;
import 'package:audioplayers/audioplayers.dart';

class Homecontroller extends GetxController {
  RxBool showroute = RxBool(false);
  Stream<Position>? _positionStream;
  RxDouble lat = RxDouble(0.0);
  RxDouble long = RxDouble(0.0);
  RxString location = RxString("initial");
  RxBool deniedforver = RxBool(false);
  Locationrepo lcrepo = Locationrepoimpl();
  RxString accessToken = RxString("initial");
  final ctrlr = Get.find<Appstartupcontroller>();
  Triplocationrepo triplocationrepo = Triplocationrepoimpl();
  RxBool isok = RxBool(false);
  WebSocketChannel? channel;

  final RxList<latlng.LatLng> routePoints = RxList<latlng.LatLng>();
  Driverresponse driverresponse = Driverresponseimpl();
  ValueNotifier<String?> socketMessage = ValueNotifier(null);

  final openrouteservice = OpenRouteService(
    apiKey: fs.dotenv.env['ORS_API_KEY'] ?? 'defaultApi',
    defaultProfile: ORSProfile.drivingCar,
  );

  var isready;
  var islocationupdatedonTrip;

  var dt = {}.obs;

  //trip details
  RxBool isonTrip = RxBool(false);
  RxInt rideID = RxInt(-1);
  RxString patientLandmark = RxString("");
  RxString assignMentId = RxString("");
  RxString patientPhoneNumber = RxString("");
  RxString distancetoLocation = RxString("");
  RxString eta = RxString("");
  RxDouble endLongitude = RxDouble(0);
  RxDouble endLatitude = RxDouble(0);
  RxBool showdetails = RxBool(false);
  RxBool showadditionalDetails = RxBool(false);

  RxInt id = RxInt(-1);
  RxInt patientId = RxInt(-1);

  var imageList = [].obs;
  var audioList = [].obs;

  final AudioPlayer audioPlayer = AudioPlayer();
  final Rx<Duration> currentPosition = Duration.zero.obs;
  final Rx<Duration> totalDuration = Duration(seconds: 1).obs;
  final RxBool isPlaying = false.obs;
  final RxInt currentplayingIndex = (-1).obs;

  RxInt previousRideId = RxInt(-1);
  CheckRiderepo checkRidedetail = CheckRiderepoimpl();

  static const String _boxName = 'ridemodel';
  late Box<RideModel> _rideBox;

  @override
  void onInit() {
    super.onInit();
    _initBox();
    _initializeController();
  }

  Future<void> _initBox() async {
    _rideBox = await Hive.openBox<RideModel>(_boxName);
  }

  Future<void> _initializeController() async {
    log("🏠 HomeController initialized()");

    // Start listening to location changes
    startListeningToLocation();

    // Get token, id, and previous ride ID
    final token = await ctrlr.getAccessToken();
    if (token == null) {
      log("❌ Failed to fetch access token");
      return;
    }
    accessToken.value = token;

    id.value = await ctrlr.getId();

    connect(drid: id.value);

    previousRideId.value = await ctrlr.getRideId();

    if (previousRideId.value != -1) {
      await _waitForValidLocation();
      checkRide(rideId: previousRideId.value);
    } else {
      log("ℹ️ No previous ride found.");
    }
  }

  Future<void> _waitForValidLocation({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final start = DateTime.now();
    const interval = Duration(milliseconds: 300);

    while ((lat.value == 0.0 || long.value == 0.0) &&
        DateTime.now().difference(start) < timeout) {
      await Future.delayed(interval);
    }

    if (lat.value != 0.0 && long.value != 0.0) {
      log("📍 Location received: (${lat.value}, ${long.value})");
    } else {
      log("⚠️ Timed out waiting for location.");
    }
  }

  void checkRide({required int rideId}) async {
    try {
      final res = await checkRidedetail.checkRidestatus(
        accesstoken: accessToken.value,
        rideId: previousRideId.value,
      );
      res.fold(
        (l) {
          log("failed in checking");
        },
        (R) async {
          if (R['ongoing'] == true) {
            Fluttertoast.showToast(msg: "still in ride");
            await getDistanceAndRouteWithFallback(
              startLat: lat.value,
              startLon: long.value,
              endLat: R['latitude'],
              endLon: R['longitude'],
            );

            if (isok.value == true) {
              patientId.value = R['user_id'];
              patientPhoneNumber.value = R['mobile'];
              patientLandmark.value = R['landmark'];
              rideID.value = rideId;
              showroute.value = true;
              isonTrip.value = true;
            }
          }
        },
      );
    } catch (e) {
      log("error in checkRide():$e");
    }
  }

  void toggleDtails() {
    if (showdetails.value) {
      showdetails.value = false;
    } else {
      showdetails.value = true;
    }
  }

  void toggleadditionalDetails() {
    if (imageList.isNotEmpty || audioList.isNotEmpty) {
      showadditionalDetails.value = true;
    }
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

        if (isonTrip.value && rideID.value != -1) {
          islocationupdatedonTrip = await triplocationrepo.location(
            rideId: rideID.value,
            longitude: position.longitude,
            latitude: position.latitude,
            accesstoken: accessToken.value,
          );
          checkAndRemoveReachedPoint(lat.value, long.value);
        }
      });
    } catch (e) {
      log("error in startListeningToLocation():$e");
    }
  }

  void checkAndRemoveReachedPoint(double currentLat, double currentLng) {
    if (routePoints.isNotEmpty) {
      final driverPosition = latlng.LatLng(currentLat, currentLng);
      final nextPoint = routePoints.first;

      log("on Target ======>>>>>> $nextPoint");

      final distance = const latlng.Distance().as(
        latlng.LengthUnit.Meter,
        driverPosition,
        nextPoint,
      );

      log("dis:$distance");

      if (distance < 20) {
        log(
          "🚗 Reached waypoint: ${nextPoint.latitude}, ${nextPoint.longitude} (Dist: ${distance.toStringAsFixed(2)}m)",
        );
        routePoints.removeAt(0);
      }
    }
  }

  void connect({required int drid}) {
    try {
      final uri = Uri.parse('ws://13.203.89.173:8001/ws/driver/$drid');

      channel = WebSocketChannel.connect(uri);
      log('🔌 Connecting to $uri');

      channel!.stream.listen(
        (data) async {
          try {
            log("in ws $drid :$data");

            dt.value = jsonDecode(data);

            if (dt['type'] == "ride_notification") {
              bookingNotification(data: data);
            }

            if (dt['type'] == "ride_confirmation") {
              rideConfirmation(data: data);
            }

            if (dt['type'] == "ride_completed") {
              rideCompleted();
            }

            if (dt['type'] == "image_uploade" || dt['type'] == "audio upload") {
              if (dt.containsKey("images")) {
                imageList.value = dt['images'];
              }

              if (dt.containsKey("audios")) {
                audioList.value = dt['audios'];
              }
            }
          } catch (e) {
            log("error in connect() : $e");
          }
        },
        onDone: () {
          log('❌ Connection closed.');
          connect(drid: id.value);
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

  void rideCompleted() {
    try {
      ctrlr.clearRideId();
      clearRide();
    } catch (e) {
      log("error in rideCompleted():$e");
    }
  }

  void onRideEnd({required dynamic message}) {
    try {
      if (channel != null) {
        channel!.sink.add(jsonEncode(message));
        log("📤 Sent: $message");
      } else {
        log("❌ Cannot send message, WebSocket not connected.");
      }
    } catch (e) {
      log("error in sendResponse():$e");
    }
  }

  Future<void> bookingNotification({required dynamic data}) async {
    try {
      var dt = jsonDecode(data);
      await getDistanceAndRouteWithFallback(
        startLat: lat.value,
        startLon: long.value,
        endLat: dt['location']['latitude'],
        endLon: dt['location']['longitude'],
      );

      if (isok.value == true) {
        rideID.value = dt["ride_id"];
        patientPhoneNumber.value = dt['mobile'];
        patientLandmark.value = dt['location']['landmark'];
        socketMessage.value = data;
      }
    } catch (e) {
      log("Error in bookingNotification():$e");
    }
  }

  Future<void> rideConfirmation({required dynamic data}) async {
    try {
      var dt = jsonDecode(data);
      patientId.value = dt['user_id'];
      rideID.value = dt['ride_id'];
      showroute.value = true;
      isonTrip.value = true;
      await ctrlr.saveRideId(rideId: dt['ride_id'].toString());
      socketMessage.value = null;
    } catch (e) {
      log("Error in rideConfirmation():$e");
    }
  }

  Future<void> clearRide() async {
    try {
      routePoints.clear();
      imageList.clear();
      audioList.clear();
      isok.value = false;
      showroute.value = false;
      isonTrip.value = false;
      rideID.value = -1;
      patientPhoneNumber.value = '';
      patientId.value = -1;
      patientLandmark.value = '';
      eta.value = '';
      socketMessage.value = null;
    } catch (e) {
      log("Error in clearRide():$e");
    }
  }

  Future<void> sendRideResponse({required Map<String, dynamic> message}) async {
    try {
      if (channel != null) {
        channel!.sink.add(jsonEncode(message));
        log("📤 Sent: $message");
      } else {
        log("❌ Cannot send message, WebSocket not connected.");
      }
    } catch (e) {
      log("error in sendResponse():$e");
    }
  }

  Future<void> seekTo(double seconds) async {
    final position = Duration(seconds: seconds.toInt());
    await audioPlayer.seek(position);
    currentPosition.value = position;
  }

  Future<void> playAudioAtIndex(int index, String url) async {
    try {
      if (currentplayingIndex.value == index && isPlaying.value) {
        await audioPlayer.pause();
        isPlaying.value = false;
        return;
      }

      currentplayingIndex.value = index;

      await audioPlayer.stop();
      await audioPlayer.play(UrlSource(url));

      isPlaying.value = true;

      audioPlayer.onDurationChanged.listen((Duration d) {
        totalDuration.value = d;
      });

      audioPlayer.onPositionChanged.listen((Duration p) {
        currentPosition.value = p;
      });

      audioPlayer.onPlayerComplete.listen((event) {
        isPlaying.value = false;
        currentPosition.value = Duration.zero;
      });
    } catch (e) {
      log("Error playing audio at index $index: $e");
      isPlaying.value = false;
    }
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    try {
      await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    } catch (e) {
      log("error:$e");
    }
  }

  Future<void> getDistanceAndRouteWithFallback({
    required double startLat,
    required double startLon,
    required double endLat,
    required double endLon,
    String mode = 'driving', // or 'walking'
  }) async {
    try {
      if (!_isValidCoordinate(startLat) ||
          !_isValidCoordinate(startLon) ||
          !_isValidCoordinate(endLat) ||
          !_isValidCoordinate(endLon)) {
        log("❌ Invalid coordinates");
        throw Exception("Invalid coordinates");
      }

      if (startLat == endLat && startLon == endLon) {
        log("🟡 Same start and end point");
        distancetoLocation.value = "0 m";
        eta.value = "0 sec";
        routePoints.clear();
        return;
      }

      // Primary: OSRM
      final osrmUrl = Uri.parse(
        'http://router.project-osrm.org/route/v1/$mode/'
        '$startLon,$startLat;$endLon,$endLat?overview=full&geometries=geojson',
      );

      log("🌐 Trying OSRM: $osrmUrl");

      final osrmResponse = await http.get(osrmUrl);

      if (osrmResponse.statusCode == 200) {
        log("✅ OSRM success");
        final data = json.decode(osrmResponse.body);
        final route = data['routes'][0];

        double distanceMeters = route['distance'].toDouble();
        double durationSeconds = route['duration'].toDouble();
        List coordinates = route['geometry']['coordinates'];

        routePoints.clear();
        for (var point in coordinates) {
          final lat = point[1] as double;
          final lon = point[0] as double;
          routePoints.add(latlng.LatLng(lat, lon));
        }

        distancetoLocation.value = distanceMeters < 1000
            ? "${distanceMeters.toStringAsFixed(0)} m"
            : "${(distanceMeters / 1000).toStringAsFixed(2)} km";

        eta.value = durationSeconds < 60
            ? "${durationSeconds.toStringAsFixed(0)} sec"
            : durationSeconds < 3600
            ? "${(durationSeconds / 60).toStringAsFixed(1)} min"
            : "${(durationSeconds / 3600).toStringAsFixed(1)} hr";

        isok.value = true;
        endLongitude.value = endLon;
        endLatitude.value = endLat;
        return;
      } else {
        log(
          "⚠️ OSRM failed: ${osrmResponse.statusCode}. Falling back to GraphHopper.",
        );
      }
    } catch (e) {
      log("❌ OSRM threw error: $e. Falling back to GraphHopper.");
    }

    // Fallback: GraphHopper
    try {
      final apiKey = fs.dotenv.env['graphHopperKey']; // Replace with actual key
      final ghUrl = Uri.parse(
        'https://graphhopper.com/api/1/route?'
        'point=$startLat,$startLon&'
        'point=$endLat,$endLon&vehicle=car&locale=en&instructions=false&points_encoded=false&key=$apiKey',
      );

      log("🌐 Trying GraphHopper: $ghUrl");

      final ghResponse = await http.get(ghUrl);

      if (ghResponse.statusCode == 200) {
        final data = json.decode(ghResponse.body);
        final path = data['paths'][0];

        double distanceMeters = path['distance'].toDouble();
        double durationSeconds = path['time'] / 1000.0; // ms to sec
        List coordinates = path['points']['coordinates'];

        routePoints.clear();
        for (var point in coordinates) {
          final lat = point[1] as double;
          final lon = point[0] as double;
          routePoints.add(latlng.LatLng(lat, lon));
        }

        distancetoLocation.value = distanceMeters < 1000
            ? "${distanceMeters.toStringAsFixed(0)} m"
            : "${(distanceMeters / 1000).toStringAsFixed(2)} km";

        eta.value = durationSeconds < 60
            ? "${durationSeconds.toStringAsFixed(0)} sec"
            : durationSeconds < 3600
            ? "${(durationSeconds / 60).toStringAsFixed(1)} min"
            : "${(durationSeconds / 3600).toStringAsFixed(1)} hr";

        isok.value = true;
        endLongitude.value = endLon;
        endLatitude.value = endLat;
        log(
          "✅ Fallback GraphHopper success: Distance ${distancetoLocation.value}, ETA ${eta.value}",
        );
        return;
      } else {
        isok.value = false;
        throw Exception('❌ GraphHopper failed: ${ghResponse.statusCode}');
      }
    } catch (e) {
      isok.value = false;
      log("❌ Fallback GraphHopper error: $e");
    }
  }

  bool _isValidCoordinate(double value) {
    return value.isFinite && !value.isNaN;
  }
}
