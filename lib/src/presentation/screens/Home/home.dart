import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' as lat;
import 'package:medicaredriver/src/presentation/controller/homecontroller/Homecontroller.dart';

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
        () => FlutterMap(
          options: MapOptions(
            initialCenter: lat.LatLng(ctrl.lat.value, ctrl.long.value),
            initialZoom: 17.5,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              // no subdomains to avoid OSM warning
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: ctrl.start,
                  width: 40,
                  height: 40,
                  child: Image.asset("assets/icons/accident.png"),
                ),
                Marker(
                  point: ctrl.end,
                  width: 40,
                  height: 40,
                  child: Image.asset("assets/icons/loc.png"),
                ),
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
      ),
    );
  }
}
