import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:medicaredriver/src/core/network/failure.dart';
import 'package:medicaredriver/src/core/url.dart';
import 'package:medicaredriver/src/domain/repositories/location/driverlocationInTrip/tripLocationRepo.dart';

class Triplocationrepoimpl extends Triplocationrepo {
  final Dio _dio = Dio();
  @override
  Future<Either<Failure, Map<String, dynamic>>> location({
    required int rideId,
    required double longitude,
    required double latitude,
    required String accesstoken,
  }) async {
    final url =
        '${Url.baseUrl}/${Url.driverlocOnTrip}?ride_id=$rideId&latitude=$latitude&longitude=$longitude';
    log("POST: $url    rideId:$rideId");

    try {
      final response = await _dio.post(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accesstoken',
          },
        ),
        // data: {"ride_id": rideId, "latitude": latitude, "longitude": longitude},
      );

      log("Response Status: ${response.statusCode}");
      log("Response Body: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = response.data as Map<String, dynamic>;

        return right({});
      } else {
        return left(Failure(message: 'Server error: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      log("Dio error: ${e.message}");
      return left(Failure(message: 'Network error: ${e.message}'));
    } catch (e) {
      log("Unexpected error: $e");
      return left(Failure(message: 'Unexpected error occurred'));
    }
  }
}
