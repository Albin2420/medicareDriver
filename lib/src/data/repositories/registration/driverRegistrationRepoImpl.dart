// import 'dart:convert';
// import 'dart:developer';

// import 'package:dartz/dartz.dart';
// import 'package:http/http.dart' as http;
// import 'package:medicare/src/core/network/failure.dart';
// import 'package:medicare/src/core/url.dart';
// import 'package:medicare/src/domain/repositories/registration/userRegistrationRepo.dart';

// class UserRegistrationRepoImpl extends UserRegistrationRepo {
//   @override
//   Future<Either<Failure, Map<String, dynamic>>> saveStudent({
//     required String frstName,
//     required String secondName,
//     required String phoneNumber,
//   }) async {
//     final url = Uri.parse('${Url.baseUrl}/${Url.users}');
//     log("POST: $url");

//     try {
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'first_name': frstName,
//           'last_name': secondName,
//           'mobile': phoneNumber,
//         }),
//       );

//       log("Response Status: ${response.statusCode}");
//       log("Response Body: ${response.body}");

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
//         log("response body:$responseBody");
//         return right({"access_token": responseBody["access_token"]});
//       } else {
//         return left(Failure(message: 'Server error: ${response.statusCode}'));
//       }
//     } catch (e) {
//       log("HTTP error: $e");
//       return left(Failure(message: 'Network error occurred'));
//     }
//   }
// }

import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:medicaredriver/src/core/network/failure.dart';
import 'package:medicaredriver/src/core/url.dart';
import 'package:medicaredriver/src/domain/repositories/registration/driverRegistrationRepo.dart';

class DriverRegistrationRepoImpl extends DriverRegistrationRepo {
  final Dio _dio = Dio();

  @override
  Future<Either<Failure, Map<String, dynamic>>> saveDriver({
    required String ownerName,
    required String ownerNumber,
    required String ownerEmail,
    required String ambulanceNumber,
    required String driverName,
    required String driverPhoneNumber,
  }) async {
    final url = '${Url.baseUrl}/${Url.registration}';

    try {
      final requestedData = jsonEncode({
        'owner_name': ownerName,
        'owner_number': ownerNumber,
        'owner_email': ownerEmail,
        'ambulance_number': ambulanceNumber,
        'driver_name': driverName,
        'mobile': driverPhoneNumber,
      });

      log(" 🔌 POST : $url");
      log("📤 Sending Request Data:\n$requestedData");

      final response = await _dio.post(
        url,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: requestedData
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("✅ Response Status of $url: ${response.statusCode}");
        final responseBody = response.data as Map<String, dynamic>;
        return right({
          "access_token": responseBody["access_token"],
          "id": responseBody["driver"]['id'],
        });
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
