import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' as lat;
import 'package:medicaredriver/src/presentation/controller/homecontroller/Homecontroller.dart';
import 'package:medicaredriver/src/presentation/screens/Home/widgets/acceptButton.dart';
import 'package:medicaredriver/src/presentation/screens/Home/widgets/rejectButton.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(Homecontroller());
    return Scaffold(
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
        // METHOD 2: Add action button in AppBar to show bottom sheet
        // actions: [
        //   IconButton(
        //     onPressed: () => _showEmergencySheet(context),
        //     icon: Icon(Icons.emergency, color: Colors.red),
        //   ),
        // ],
      ),
      body: Obx(
        () => Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: lat.LatLng(10.1081324, 76.3585433),
                initialZoom: 18,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  // no subdomains to avoid OSM warning
                ),
                MarkerLayer(
                  markers: [
                    // Marker(
                    //   point: ctrl.start,
                    //   width: 40,
                    //   height: 40,
                    //   child: Image.asset("assets/icons/accident.png"),
                    // ),
                    // Marker(
                    //   point: ctrl.end,
                    //   width: 40,
                    //   height: 40,
                    //   child: Image.asset("assets/icons/loc.png"),
                    // ),
                  ],
                ),
                if (ctrl.routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: ctrl.routePoints.value,
                        strokeWidth: 4.0,
                        color: Colors.blue,
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            0.2,
                          ), // Adjust opacity as needed
                          offset: Offset(6, 6),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    margin: EdgeInsets.only(top: 30),
                    width: MediaQuery.of(context).size.width - 60,
                    padding: EdgeInsets.only(top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Centered Request ID
                        Text(
                          "Request ID: 112323",
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

                        Row(
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
                            Text(
                              'Destination',
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
                              'Distance : ',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Color(0xff353459),
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              '6 km',
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
                              '6 min',
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
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: SizedBox(
                            height: 40,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Acceptbutton(
                                    onPressed: () {
                                      log("Accepted");
                                    },
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: RejectBtn(
                                    onPressed: () {
                                      log("rejected");
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
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
