import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:medicaredriver/src/core/network/failure.dart';
import 'package:medicaredriver/src/core/url.dart';
import 'package:medicaredriver/src/domain/repositories/response/driverresponse.dart';

class Driverresponseimpl extends Driverresponse {
  final Dio _dio = Dio();
  @override
  Future<Either<Failure, Map<String, dynamic>>> respondBooking({
    required String assignmentId,
    required String status,
    required String accesstoken,
  }) async {
    final url = '${Url.baseUrl}/${Url.respond}';
    log("POST: $url");

    try {
      final response = await _dio.post(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accesstoken',
          },
        ),
        data: {"assignment_id": assignmentId, "status": status},
      );

      log("Response Status: ${response.statusCode}");
      log("Response Body: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = response.data as Map<String, dynamic>;
        if (status == "accepted") {
          return right({
            "phoneNumber": responseBody['user']["mobile"],
            "landmark": responseBody['location']["landmark"],
          });
        } else {
          return right({});
        }
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
