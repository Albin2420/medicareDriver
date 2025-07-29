import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:medicaredriver/src/app.dart';
import 'package:medicaredriver/src/data/services/hive_services/rideDetails/ride_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  Hive.registerAdapter(RideModelAdapter());
  await Hive.openBox<RideModel>('ridemodel');
  runApp(MyApp());
}
