import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:medicaredriver/src/core/network/failure.dart';
import 'package:medicaredriver/src/core/url.dart';

import 'package:medicaredriver/src/domain/repositories/login/loginrepo.dart';

class Loginrepoimpl extends Loginrepo {
  final Dio _dio = Dio();

  @override
  Future<Either<Failure, Map<String, dynamic>>> login({
    required String phoneNumber,
  }) async {
    final url = '${Url.baseUrl}/${Url.login}';

    try {
      log(" 🔌 POST : $url");

      final response = await _dio.post(
        url,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {'phone_number': phoneNumber},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("✅ Response Status of $url: ${response.statusCode}");
        final responseBody = response.data as Map<String, dynamic>;
        return right({
          "access_token": responseBody["access_token"],
          "id": responseBody['driver_id'],
        });
      } else {
        log("❌ Response Status of $url: ${response.statusCode}");
        return left(Failure(message: 'Server error: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      log("❌ Dio error: ${e.message}");
      if (e.response != null) {
        log("❌ Dio error response: ${e.response?.data}");
      }
      return left(Failure(message: 'Network error: ${e.message}'));
    } catch (e) {
      log("💥 Unexpected error: $e");
      return left(Failure(message: 'Unexpected error occurred'));
    }
  }
}
