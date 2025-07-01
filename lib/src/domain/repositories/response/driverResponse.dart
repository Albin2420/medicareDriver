import 'package:dartz/dartz.dart';
import 'package:medicaredriver/src/core/network/failure.dart';

abstract class Driverresponse {
  Future<Either<Failure, Map<String, dynamic>>> respondBooking({
    required String assignmentId,
    required String status,
    required String accesstoken,
  });
}
