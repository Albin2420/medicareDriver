import 'package:dartz/dartz.dart';

import 'package:medicaredriver/src/core/network/failure.dart';

abstract class DriverRegistrationRepo {
  Future<Either<Failure, Map<String, dynamic>>> saveDriver({
    required String ownerName,
    required String ownerNumber,
    required String ownerEmail,
    required String ambulanceNumber,
    required String driverName,
    required String driverPhoneNumber,
  });
}
