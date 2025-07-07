import 'dart:convert';

import 'package:koperasi/core/constants/api_constant.dart';
import 'package:koperasi/core/errors/exceptions.dart';
import 'package:koperasi/features/riwayat_pembayaran/data/models/riwayat_pembayaran_model.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/entities/riwayat_pembayaran.dart';
import 'package:http/http.dart' as http;

abstract class RiwayatPemabayaranRemoteDatasource {
  Future<List<RiwayatPembayaran>> getRiwayatPembayaran(
    int pinjamanDetail,
    String token,
  );
}

class RiwayatPemabayaranRemoteDatasourceImpl
    implements RiwayatPemabayaranRemoteDatasource {
  final http.Client client;

  RiwayatPemabayaranRemoteDatasourceImpl(this.client);

  @override
  Future<List<RiwayatPembayaran>> getRiwayatPembayaran(
    int pinjamanDetail,
    String token,
  ) async {
    final uri = Uri.parse(
      '${ApiConstant.baseUrl}/pinjaman/$pinjamanDetail/payment',
    );

    try {
      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print(
        'DEBUG: Data Riwayat Pembayaran (raw): $jsonResponse',
      ); // Added for debugging

      if (response.statusCode == 200) {
        // Access 'data' field, then 'data' array inside it
        final List<dynamic> data = jsonResponse['data'];
        final List<RiwayatPembayaran> riwayat_pembayaran = data
            .map(
              (json) =>
                  RiwayatPembayaranModel.fromJson(json as Map<String, dynamic>),
            ) // Cast each item
            .toList();
        print(
          'DEBUG: Successfully parsed Riwayat Pembayaran: ${riwayat_pembayaran.length} items.',
        );
        return riwayat_pembayaran;
      } else if (response.statusCode == 404) {
        print('DEBUG: Server Exception 404: Riwayat Pembayaran Tidak Ada.');
        throw ServerException('Riwayat Pembayaran Tidak Ada');
      } else {
        final errorMessage = jsonResponse['message'] ?? response.reasonPhrase;
        print(
          'DEBUG: Failed to load riwayat pembayaran. Status: ${response.statusCode}, Message: $errorMessage',
        );
        throw Exception('Failed to load riwayat pembayaran: $errorMessage');
      }
    } catch (e) {
      print(
        'DEBUG: Unexpected error in RiwayatPemabayaranRemoteDatasourceImpl: $e',
      );
      throw ServerException('Failed to get riwayat pembayaran: $e');
    }
  }
}
