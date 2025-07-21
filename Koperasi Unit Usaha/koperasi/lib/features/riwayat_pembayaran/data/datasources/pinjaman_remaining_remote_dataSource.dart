import 'dart:convert';

import 'package:koperasi/core/constants/api_constant.dart';
import 'package:koperasi/core/errors/exceptions.dart';
import 'package:koperasi/features/riwayat_pembayaran/data/models/pinjaman_remaining_model.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/entities/pinjaman_remaining_entity.dart';
import 'package:http/http.dart' as http;

abstract class PinjamanRemainingRemoteDatasource {
  Future<PinjamanRemainingEntity> getPinjamanRemaining(String token);
}

class PinjamanRemainingRemoteDatasourceImpl
    implements PinjamanRemainingRemoteDatasource {
  final http.Client client;

  PinjamanRemainingRemoteDatasourceImpl(this.client);

  @override
  Future<PinjamanRemainingEntity> getPinjamanRemaining(String token) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/pinjaman/remaining-total');

    try {
      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print('Data Pinjaman Remaining : $jsonResponse');

      if (response.statusCode == 200) {
        final PinjamanRemainingModel pinjamanRemainingModel =
            PinjamanRemainingModel.fromJson(jsonResponse['data']);
        return pinjamanRemainingModel;
      } else {
        throw ServerException('Failed to load pinjaman remaining');
      }
    } catch (e) {
      throw ServerException('Failed to get pinjaman remaining $e');
    }
  }
}
