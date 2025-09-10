import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:medicaredriver/src/core/network/failure.dart';
import 'package:medicaredriver/src/core/url.dart';

import 'package:medicaredriver/src/domain/repositories/location/commonLocation/locationrepo.dart';

class Locationrepoimpl extends Locationrepo {
  final Dio _dio = Dio();
  @override
  Future<Either<Failure, Map<String, dynamic>>> location({
    required double longitude,
    required double latitude,

    required String accesstoken,
  }) async {
    final url = '${Url.baseUrl}/${Url.driverloc}';

    try {

      final requestData = jsonEncode({
        "latitude": latitude,
        "longitude":longitude
      });

      log(" 🔌 POST : $url");
      log("📤 Sending Request Data:$requestData");

      final response = await _dio.post(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accesstoken',
          },
        ),
        data: requestData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("✅ Response Status of $url: ${response.statusCode}");
        return right({});
      } else {
        log("❌ Response Status of $url: ${response.statusCode}");
        return left(Failure(message: 'Server error: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      log("❌ Dio error: ${e.message}");
      return left(Failure(message: 'Network error: ${e.message}'));
    } catch (e) {
      log("💥 Unexpected error: $e");
      return left(Failure(message: 'Unexpected error occurred'));
    }
  }
}
