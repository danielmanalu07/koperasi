import 'dart:convert';

import 'package:koperasi/core/errors/exceptions.dart';
import 'package:koperasi/features/sewa_menyewa/data/model/dashboard_model.dart';
import 'package:http/http.dart' as http;

abstract class DashboardRemoteDataSource {
  Future<DashboardModel> getDashboard();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final http.Client client;

  DashboardRemoteDataSourceImpl({required this.client});

  @override
  Future<DashboardModel> getDashboard() async {
    final uri = Uri.parse('http://10.0.2.2:3001/api/sewa/dashboard');
    try {
      final response = await client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      // Cek jika response body kosong
      if (response.body.isEmpty) {
        throw ServerException('Empty response body');
      }

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print("Parsed JSON: $jsonResponse");

      if (response.statusCode == 200) {
        // Validasi struktur response
        if (!jsonResponse.containsKey('data')) {
          throw ServerException('Invalid response format: missing data field');
        }

        final DashboardModel dashboardModel = DashboardModel.fromJson(
          jsonResponse['data'],
        );
        return dashboardModel;
      } else {
        // Handle error response dengan pesan yang lebih spesifik
        final String errorMessage = jsonResponse['message'] ?? 'Unknown error';
        throw ServerException(
          'Failed to load dashboard data: $errorMessage (Status: ${response.statusCode})',
        );
      }
    } on FormatException catch (e) {
      // Handle JSON parsing error
      throw ServerException('Invalid JSON response: ${e.message}');
    } on http.ClientException catch (e) {
      // Handle network errors
      throw ServerException('Network error: ${e.message}');
    } catch (e) {
      // Handle other unexpected errors
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }
}
