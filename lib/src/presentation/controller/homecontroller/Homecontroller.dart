// controllers are use in this folder

import 'dart:convert';
import 'dart:developer';

import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:medicaredriver/src/data/repositories/location/commonLocation/locationrepoimpl.dart';
import 'package:medicaredriver/src/data/repositories/location/driverlocationInTrip/tripLocationrepoimpl.dart';
import 'package:medicaredriver/src/data/repositories/response/driverResponseImpl.dart';
import 'package:medicaredriver/src/domain/repositories/location/commonLocation/locationrepo.dart';
import 'package:medicaredriver/src/domain/repositories/location/driverlocationInTrip/tripLocationRepo.dart';
import 'package:medicaredriver/src/domain/repositories/response/driverresponse.dart';
import 'package:medicaredriver/src/presentation/controller/appstartupcontroller/appstartupcontroller.dart';
import 'package:medicaredriver/src/presentation/screens/Home/home.dart';
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
  static const epsilon = 0.00001;
  final latlng.LatLng start = latlng.LatLng(10.1081715, 76.3586718);
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
  RxInt rideId = RxInt(-1);
  RxString patientLandmark = RxString("");
  RxString assignMentId = RxString("");
  RxString patientPhoneNumber = RxString("");
  RxString distancetoLocation = RxString('');
  RxString eta = RxString("");
  RxDouble endLongitude = RxDouble(0);
  RxDouble endLatitude = RxDouble(0);
  RxBool showdetails = RxBool(false);
  RxBool showadditionalDetails = RxBool(false);

  var imageList = [].obs;
  var audioList = [].obs;

  final AudioPlayer audioPlayer = AudioPlayer();
  final Rx<Duration> currentPosition = Duration.zero.obs;
  final Rx<Duration> totalDuration = Duration(seconds: 1).obs;
  final RxBool isPlaying = false.obs;
  final RxInt currentplayingIndex = (-1).obs;

  @override
  void onInit() async {
    super.onInit();
    log("Home controller initialized()");
    accessToken.value = (await ctrlr.getAccessToken())!;
    startListeningToLocation();
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

        if (isonTrip.value && rideId.value != -1) {
          islocationupdatedonTrip = await triplocationrepo.location(
            rideId: rideId.value,
            longitude: position.longitude,
            latitude: position.latitude,
            accesstoken: accessToken.value,
          );
          checkAndRemoveReachedPoint(lat.value, long.value);
        }
      });
      connect(id: 16); //remove hardcode value
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

      if (distance < 1500) {
        log(
          "🚗 Reached waypoint: ${nextPoint.latitude}, ${nextPoint.longitude} (Dist: ${distance.toStringAsFixed(2)}m)",
        );
        routePoints.removeAt(0);
      } else {
        log("too far");
      }
    } else {
      log("points empty");
    }
  }

  void connect({required int id}) {
    try {
      final uri = Uri.parse('ws://13.203.89.173:8001/ws/driver/$id');

      channel = WebSocketChannel.connect(uri);
      log('🔌 Connecting to $uri');

      channel!.stream.listen(
        (data) async {
          try {
            dt.value = jsonDecode(data);

            log("from server:$data");

            if (dt.containsKey("images") || dt.containsKey("audios")) {
              log("image file catched");

              if (dt.containsKey("images")) {
                imageList.value = dt['images'];
              }

              if (dt.containsKey("audios")) {
                audioList.value = dt['audios'];
              }
              return;
            } else {
              log("latitude:${dt['location']['latitude']}");
              await getDistanceAndRouteFromOSRM(
                startLat: lat.value,
                startLon: long.value,
                // endLat: 10.1066164,
                // endLon: 76.363186,
                endLat: dt['location']['latitude'],
                endLon: dt['location']['longitude'],
              );

              if (isok.value == true) {
                rideId.value = dt["ride_id"];
                socketMessage.value = data;
              }
            }
          } catch (e) {
            log("inside data:$e");
          }
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

  void accepted({required String assignmentId}) async {
    try {
      var ds = await driverresponse.respondBooking(
        assignmentId: assignmentId,
        status: "accepted",
        accesstoken: accessToken.value,
      );
      ds.fold(
        (l) {
          log("failed in accepting()");
        },
        (r) {
          patientPhoneNumber.value = r['phoneNumber'];
          patientLandmark.value = r['landmark'];
          showroute.value = true;
          isonTrip.value = true;
          socketMessage.value = null;
          log("submitted successfully");
        },
      );
    } catch (e) {
      log("Error in accepted():$e");
    }
  }

  void rejected({required String assignmentId}) async {
    try {
      var ds = await driverresponse.respondBooking(
        assignmentId: assignmentId,
        status: "rejected",
        accesstoken: accessToken.value,
      );
      ds.fold((l) {}, (r) {
        log("rejected");
      });
    } catch (e) {
      log("Error in rejected():$e");
    }
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    try {
      bool? res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    } catch (e) {
      log("error:$e");
    }
  }

  Future<void> getDistanceAndRouteFromOSRM({
    required double startLat,
    required double startLon,
    required double endLat,
    required double endLon,
    String mode = 'driving', // or 'walking'
  }) async {
    try {
      // ✅ Validate coordinates
      if (!_isValidCoordinate(startLat) ||
          !_isValidCoordinate(startLon) ||
          !_isValidCoordinate(endLat) ||
          !_isValidCoordinate(endLon)) {
        log("❌ Invalid coordinates detected");
        throw Exception("Invalid coordinates provided.");
      }

      // ✅ Check if coordinates are the same
      if (startLat == endLat && startLon == endLon) {
        log("🟡 Start and end coordinates are the same. No route needed.");
        distancetoLocation.value = "0 m";
        eta.value = "0 sec";
        routePoints.clear();
        return;
      }

      final url = Uri.parse(
        'http://router.project-osrm.org/route/v1/$mode/'
        '$startLon,$startLat;$endLon,$endLat?overview=full&geometries=geojson',
      );

      final response = await http.get(url);

      log("response :${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
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

        log("✅ OSRM route updated: $routePoints");

        // Distance formatting
        distancetoLocation.value = distanceMeters < 1000
            ? "${distanceMeters.toStringAsFixed(0)} m"
            : "${(distanceMeters / 1000).toStringAsFixed(2)} km";

        // Duration formatting
        String durationFormatted;
        if (durationSeconds < 60) {
          durationFormatted = "${durationSeconds.toStringAsFixed(0)} sec";
        } else if (durationSeconds < 3600) {
          durationFormatted =
              "${(durationSeconds / 60).toStringAsFixed(1)} min";
        } else {
          durationFormatted =
              "${(durationSeconds / 3600).toStringAsFixed(1)} hr";
        }

        eta.value = durationFormatted;

        log(
          "Distance: ${distancetoLocation.value}, Duration: $durationFormatted",
        );

        endLongitude.value = endLon;
        endLatitude.value = endLat;
        isok.value = true;
      } else {
        isok.value = false;
        throw Exception(
          '❌ Failed to get route from OSRM: ${response.statusCode}',
        );
      }
    } catch (e) {
      isok.value = false;
      log("❌ Error in getDistanceAndRouteFromOSRM(): $e");
    }
  }

  bool _isValidCoordinate(double value) {
    return value.isFinite && !value.isNaN;
  }
}
