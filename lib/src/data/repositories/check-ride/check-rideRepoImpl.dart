import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:medicaredriver/src/core/network/failure.dart';
import 'package:medicaredriver/src/core/url.dart';
import 'package:medicaredriver/src/domain/repositories/check-ride/check-rideRepo.dart';

class CheckRiderepoimpl extends CheckRiderepo {
  final Dio _dio = Dio();
  @override
  Future<Either<Failure, Map<String, dynamic>>> checkRidestatus({
    required String accesstoken,
    required int rideId,
  }) async {
    final url = '${Url.baseUrl}/${Url.driverCheckonGoingRide}';

    try {
      log(" 🔌 POST : $url");

      log("📤 Sending Request Data:\n{'ride_id':$rideId}");

      final response = await _dio.post(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accesstoken',
          },
        ),
        data: jsonEncode({"ride_id": rideId}),
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        log("✅ Response Status of $url: ${response.statusCode}");
        final responseBody = response.data as Map<String, dynamic>;

        if (responseBody['ongoing'] == true) {
          return right({
            "ongoing": responseBody['ongoing'],
            "latitude": responseBody['user_location']['latitude'],
            "longitude": responseBody['user_location']['longitude'],
            "landmark": responseBody['user_location']['landmark'],
            "mobile": responseBody['user_location']['mobile'],
            "user_id": responseBody['user_id'],
          });
        } else {
          return right({"ongoing": responseBody['ongoing']});
        }
      } else {
        log("❌ Response Status of $url: ${response.statusCode}");
        return left(Failure(message: 'Server error: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      log("❌ Dio error: ${e.message}");
      return left(Failure(message: 'Network error: ${e.message}'));
    } catch (e) {
      log("💥 Unexpected error in checkRidestatus(): $e");
      return left(Failure(message: 'Unexpected error occurred'));
    }
  }
}
