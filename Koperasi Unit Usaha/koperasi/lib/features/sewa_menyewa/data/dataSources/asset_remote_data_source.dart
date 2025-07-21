import 'dart:convert';

import 'package:koperasi/core/errors/exceptions.dart';
import 'package:koperasi/features/sewa_menyewa/data/model/asset_model.dart';
import 'package:koperasi/features/sewa_menyewa/domain/entities/asset.dart';
import 'package:http/http.dart' as http;

abstract class AssetRemoteDataSource {
  Future<List<Asset>> getAllAsset();
  Future<Asset> addAsset(
    String nama,
    DateTime tanggalBeli,
    double hargaBeli,
    String keterangan,
  );
}

class AssetRemoteDataSourceImpl implements AssetRemoteDataSource {
  final http.Client client;

  AssetRemoteDataSourceImpl({required this.client});

  @override
  Future<Asset> addAsset(
    String nama,
    DateTime tanggalBeli,
    double hargaBeli,
    String keterangan,
  ) async {
    final uri = Uri.parse('http://10.0.2.2:3001/api/sewa/aset/create');
    try {
      final response = await client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nama': nama,
          'tanggal_beli': tanggalBeli.toIso8601String(),
          'harga_beli': hargaBeli,
          'keterangan': keterangan,
        }),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print('Hasil Add Asset: $jsonResponse');

      if (response.statusCode == 200) {
        final asset = AssetModel.fromJson(jsonResponse['data']);
        return asset;
      } else {
        throw ServerException('Failed to add asset');
      }
    } catch (e) {
      throw ServerException('Failed to add asset: $e');
    }
  }

  @override
  Future<List<Asset>> getAllAsset() async {
    final uri = Uri.parse('http://10.0.2.2:3001/api/sewa/aset');
    try {
      final response = await client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print("Asset Data: $jsonResponse");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonResponse['data'];
        final List<Asset> assets = data
            .map((json) => AssetModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return assets;
      } else {
        throw ServerException('Failed to get data asset');
      }
    } catch (e) {
      throw ServerException('Internal Server Error');
    }
  }
}
