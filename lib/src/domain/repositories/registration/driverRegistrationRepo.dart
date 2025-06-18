import 'package:dartz/dartz.dart';

import 'package:medicaredriver/src/core/network/failure.dart';

abstract class DriverRegistrationRepo {
  Future<Either<Failure, Map<String, dynamic>>> saveDriver({
    required String frstName,
    required String secondName,
    required String phoneNumber,
  });
}
