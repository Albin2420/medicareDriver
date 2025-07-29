import 'package:hive/hive.dart';

part 'ride_model.g.dart';

@HiveType(typeId: 1)
class RideModel extends HiveObject {
  @HiveField(0)
  int rideId;

  @HiveField(1)
  String riderName;

  @HiveField(2)
  String riderMobile;

  @HiveField(3)
  double pickupLatitude;

  @HiveField(4)
  double pickupLongitude;

  @HiveField(5)
  String pickupLandmark;

  RideModel({
    required this.rideId,
    required this.riderName,
    required this.riderMobile,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.pickupLandmark,
  });
}
