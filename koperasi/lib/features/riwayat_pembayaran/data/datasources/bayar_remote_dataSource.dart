import 'dart:convert';
import 'dart:io';

import 'package:koperasi/core/constants/api_constant.dart';
import 'package:koperasi/core/errors/exceptions.dart';
import 'package:koperasi/features/riwayat_pembayaran/data/models/bayar_model.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/entities/bayar_entity.dart';
import 'package:http/http.dart' as http;

abstract class BayarRemoteDatasource {
  Future<BayarEntity> bayarTagihan(
    int pinjamanDetail,
    String? image,
    num amount,
    String type,
    String token,
  );
}

class BayarRemoteDatasourceImpl implements BayarRemoteDatasource {
  final http.Client client;

  BayarRemoteDatasourceImpl(this.client);

  @override
  Future<BayarEntity> bayarTagihan(
    int pinjamanDetail,
    String? image,
    num amount,
    String type,
    String token,
  ) async {
    final uri = Uri.parse(
      '${ApiConstant.baseUrl}/pinjaman/$pinjamanDetail/payment',
    );

    var request = http.MultipartRequest('POST', uri);

    try {
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['amount'] = amount.toString();
      request.fields['type'] = type;

      // In BayarRemoteDatasourceImpl
      if (type == 'manual' && image != null) {
        // Ensure the file actually exists and is readable
        final file = File(image);
        if (!await file.exists()) {
          print('Error: Image file does not exist at path: $image');
          throw ServerException('Local image file not found for upload.');
        }
        try {
          request.files.add(await http.MultipartFile.fromPath('image', image));
        } catch (fileError) {
          print('Error adding file to multipart request: $fileError');
          throw ServerException(
            'Failed to attach image for upload: $fileError',
          );
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // In BayarRemoteDatasourceImpl
      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print('Hasil bayar: $jsonResponse');
        if (jsonResponse['data'] != null) {
          return BayarModel.fromJson(
            jsonResponse['data'] as Map<String, dynamic>,
          );
        } else {
          throw Exception('Failed to parse BayarEntity: Data field is null');
        }
      } else {
        final Map<String, dynamic> errorResponse = json.decode(response.body);
        throw Exception(
          'Failed to bayar tagihan: ${response.statusCode} - ${errorResponse['message'] ?? response.reasonPhrase}',
        );
      }
    } on http.ClientException catch (e) {
      throw ServerException('HTTP Client Error: ${e.message}');
    } catch (e) {
      // Catch any other unexpected errors
      throw ServerException('An unexpected error occurred: $e');
    }
  }
}
