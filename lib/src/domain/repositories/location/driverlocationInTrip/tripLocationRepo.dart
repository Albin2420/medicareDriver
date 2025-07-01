import 'package:dartz/dartz.dart';
import 'package:medicaredriver/src/core/network/failure.dart';

abstract class Triplocationrepo {
  Future<Either<Failure, Map<String, dynamic>>> location({
    required int rideId,
    required double longitude,
    required double latitude,
    required String accesstoken,
  });
}
