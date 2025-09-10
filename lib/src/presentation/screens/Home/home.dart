import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' as lat;
import 'package:medicaredriver/src/presentation/controller/homecontroller/Homecontroller.dart';
import 'package:medicaredriver/src/presentation/screens/Home/widgets/acceptButton.dart';
import 'package:medicaredriver/src/presentation/screens/Home/widgets/recTile.dart';
import 'package:medicaredriver/src/presentation/screens/Home/widgets/rejectButton.dart';
import 'package:medicaredriver/src/presentation/screens/Home/widgets/ridecloseButton.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(Homecontroller());
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(6),
          child: SizedBox(
            height: 50,
            width: 40,
            child: Image.asset("assets/icons/menu.png"),
          ),
        ),
        title: Text(
          "MediCare",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        flexibleSpace: Column(
          children: [
            const Spacer(),
            Container(
              height: 1,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (ctrl.lat.value != 0 && ctrl.long.value != 0) {
          return Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: lat.LatLng(ctrl.lat.value, ctrl.long.value),
                  initialZoom: 18,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    // no subdomains to avoid OSM warning
                    userAgentPackageName:
                        'com.yourcompany12.yourapp', // required
                    tileProvider: NetworkTileProvider(),
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: lat.LatLng(ctrl.lat.value, ctrl.long.value),
                        width: 40,
                        height: 40,
                        child: Image.asset("assets/icons/location.png"),
                      ),
                      if (ctrl.routePoints.isNotEmpty && ctrl.showroute.value)
                        Marker(
                          point: lat.LatLng(
                            ctrl.endLatitude.value,
                            ctrl.endLongitude.value,
                          ),
                          width: 40,
                          height: 40,
                          child: Image.asset("assets/icons/destination.png"),
                        ),
                    ],
                  ),
                  if (ctrl.routePoints.isNotEmpty && ctrl.showroute.value)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: ctrl.routePoints.value,
                          strokeWidth: 4.0,
                          color: const Color.fromARGB(255, 1, 10, 17),
                        ),
                      ],
                    ),
                ],
              ),

              ValueListenableBuilder<String?>(
                valueListenable: ctrl.socketMessage,
                builder: (context, message, _) {
                  if (message == null) return SizedBox.shrink();
                  return Align(
                    alignment: Alignment.topCenter,
                    child: Obx(() {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: Offset(6, 6),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        margin: EdgeInsets.only(top: 30),
                        width: MediaQuery.of(context).size.width - 30,
                        padding: EdgeInsets.only(top: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Centered Request ID
                            Text(
                              "Request ID: ${ctrl.dt['assignment_id']}",
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),
                            Divider(thickness: 1),
                            SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Location : ',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: Color(0xff353459),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${ctrl.dt["location"]["landmark"]}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Distance : ',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Color(0xff353459),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  ctrl.distancetoLocation.value,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),

                            SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'ETA : ',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Color(0xff353459),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  ctrl.eta.value,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            SizedBox(height: 22),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                              ),
                              child: SizedBox(
                                height: 40,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Acceptbutton(
                                        onPressed: () async {
                                          await ctrl.sendRideResponse(
                                            message: {
                                              "type": "ride_response",
                                              "assignment_id":
                                                  ctrl.dt['assignment_id'],
                                              "status": "accepted",
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: RejectBtn(
                                        onPressed: () async {
                                          log("rejected");
                                          await ctrl.sendRideResponse(
                                            message: {
                                              "type": "ride_response",
                                              "assignment_id":
                                                  ctrl.dt['assignment_id'],
                                              "status": "rejected",
                                            },
                                          );
                                          ctrl.clearRide();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 22),
                          ],
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          );
        } else {
          return SizedBox();
        }
      }),
      bottomNavigationBar: Obx(() {
        if (ctrl.isonTrip.value == false) {
          return SizedBox();
        } else {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2), // light shadow
                  blurRadius: 20, // softness of the shadow
                  spreadRadius: 5, // how wide the shadow spreads
                  offset: Offset(0, -6), // x: 0, y: -5 (upward shadow)
                ),
              ],
            ),

            child: Obx(() {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 28),
                  GestureDetector(
                    onTap: () {
                      ctrl.toggleDtails();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left icon
                          SizedBox(width: 18),
                          SizedBox(
                            width: 20,
                            height: 28,
                            child: Image.asset("assets/icons/destination.png"),
                          ),
                          SizedBox(width: 16),

                          // Expanded Text in center
                          Expanded(
                            child: Text(
                              ctrl.patientLandmark.value,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 18),
                          GestureDetector(
                            onTap: (){
                              ctrl.navigateWithGoogleMaps(destinationLat: ctrl.endLatitude.value,destinationLng: ctrl.endLongitude.value);
                            },
                            child: SizedBox(
                              width: 20,
                              height: 28,
                              child: Image.asset("assets/icons/remap.png"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  ctrl.showdetails.value == false
                      ? Text(
                          "ETA : ${ctrl.eta.value}",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              ctrl.distancetoLocation.value,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "ETA : ${ctrl.eta.value}",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                  ctrl.showdetails.value == false
                      ? SizedBox(height: 23)
                      : Column(
                          children: [
                            SizedBox(height: 18),
                            Divider(),
                            ctrl.showadditionalDetails.value == true
                                ? Column(
                                    children: [
                                      SizedBox(height: 24),
                                      ctrl.imageList.isNotEmpty
                                          ? Text(
                                              "Photos & videos",
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 18,
                                                color: Color(0xff353459),
                                              ),
                                            )
                                          : SizedBox(),
                                      SizedBox(height: 12),
                                      ctrl.imageList.isNotEmpty
                                          ? Container(
                                              height: 130,
                                              color: Colors.white,
                                              padding: EdgeInsets.only(
                                                top: 16,
                                                left: 16,
                                                right: 16,
                                                bottom: 16,
                                              ),
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount:
                                                    ctrl.imageList.length,
                                                itemBuilder: (context, index) {
                                                  return Container(
                                                    margin:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                        ),
                                                    width: 100,
                                                    color: Colors
                                                        .grey, // Adjust as needed
                                                    child: Image.network(
                                                      ctrl.imageList[index],
                                                      fit: BoxFit.cover,
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                          : SizedBox(),
                                      SizedBox(height: 24),
                                      ctrl.audioList.isNotEmpty
                                          ? Text(
                                              "Audio Recording",
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 18,
                                                color: Color(0xff353459),
                                              ),
                                            )
                                          : SizedBox(),
                                      SizedBox(height: 12),
                                      ctrl.audioList.isNotEmpty
                                          ? Container(
                                              padding: EdgeInsets.only(
                                                right: 16,
                                                left: 16,
                                              ),
                                              height: 110,
                                              color: Colors.white,
                                              child: ListView.builder(
                                                itemBuilder: (context, index) {
                                                  return RecTile(index: index);
                                                },
                                                itemCount:
                                                    ctrl.audioList.length,
                                              ),
                                            )
                                          : SizedBox(),
                                    ],
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(
                                      left: 24,
                                      right: 24,
                                      top: 18,
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        ctrl.toggleadditionalDetails();
                                      },
                                      child: Container(
                                        padding: EdgeInsets.only(
                                          top: 14,
                                          bottom: 14,
                                          left: 20,
                                          right: 20,
                                        ),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            32,
                                          ),
                                          border: Border.all(
                                            color: Color(0xff3534594d),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "View Additional Details",
                                              style: GoogleFonts.poppins(
                                                color: Color(0xff353459),
                                                fontWeight: FontWeight.w500,
                                                fontSize: 22,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 24,
                                right: 24,
                                top: 18,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  ctrl.makePhoneCall(
                                    ctrl.patientPhoneNumber.value,
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.only(
                                    top: 14,
                                    bottom: 14,
                                    left: 20,
                                    right: 20,
                                  ),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xffE75757),
                                        Color(0xff8C0707),
                                      ],
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(width: 10),
                                      SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: Image.asset(
                                          "assets/icons/phone.png",
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        "call Patient",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top: 14,
                                bottom: 14,
                                left: 20,
                                right: 20,
                              ),
                              child: Rideclosebutton(
                                onPressed: () {
                                  ctrl.onRideEnd(
                                    message: {
                                      "type": "ride_completed",
                                      "ride_id": ctrl.rideID.value,
                                      "driver_id": ctrl.id.value,
                                      "user_id": ctrl.patientId.value,
                                    },
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 24),
                          ],
                        ),
                ],
              );
            }),
          );
        }
      }),
    );
  }
}
