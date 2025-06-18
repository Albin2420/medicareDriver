import 'package:dartz/dartz.dart';
import 'package:medicaredriver/src/core/network/failure.dart';

abstract class Locationrepo {
  Future<Either<Failure, Map<String, dynamic>>> location({
    required double longitude,
    required double latitude,
    required String landmark,
    required String accesstoken,
  });
}
