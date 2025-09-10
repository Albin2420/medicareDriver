import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:medicaredriver/src/core/network/failure.dart';
import 'package:medicaredriver/src/core/url.dart';
import 'package:medicaredriver/src/domain/repositories/token/tokenRepo.dart';

class Tokenrepoimpl extends Tokenrepo {
  final Dio _dio = Dio();
  @override
  Future<Either<Failure, Map<String, dynamic>>> checkToken({
    required String accesstoken,
  }) async {
    final url = '${Url.baseUrl}/${Url.checkExpiry}';

    try {
      log(" 🔌 GET : $url");

      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accesstoken',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("✅ Response Status of $url: ${response.statusCode}");
        final responseBody = response.data as Map<String, dynamic>;
        return Right({"expired": responseBody['expired']});
      } else {
        log("❌ Response Status of $url: ${response.statusCode}");
        return left(Failure(message: 'Server error: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      log("❌ Dio error in $url : ${e.message}");
      return left(Failure(message: 'Network error: ${e.message}'));
    } catch (e) {
      log("💥 Unexpected error in checkToken() : $e");
      return left(Failure(message: 'Unexpected error occurred'));
    }
  }
}
