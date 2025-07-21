import 'dart:convert';

import 'package:koperasi/core/errors/exceptions.dart';
import 'package:http/http.dart' as http;
import 'package:koperasi/features/sewa_menyewa/data/model/Transaction/transaction_model.dart';

abstract class TransactionRemoteDatasource {
  Future<List<TransactionModel>> getTransactions();
  Future<TransactionModel> createTransaction(TransactionModel transaction);
}

class TransactionRemoteDatasourceImpl implements TransactionRemoteDatasource {
  final http.Client client;
  final String baseUrl = 'http://10.0.2.2:3001/api/sewa/aset';

  TransactionRemoteDatasourceImpl({required this.client});

  @override
  Future<TransactionModel> createTransaction(
    TransactionModel transaction,
  ) async {
    final uri = Uri.parse('$baseUrl/transaction/create');
    try {
      final response = await client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(transaction.toJson()),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          final transactionData = jsonResponse['data'];
          if (transactionData is Map<String, dynamic>) {
            return TransactionModel.fromJson(transactionData);
          } else {
            throw ServerException(
              'Invalid data format in response: $jsonResponse',
            );
          }
        } catch (e) {
          throw ServerException('Failed to parse JSON response: $e');
        }
      } else {
        throw ServerException(
          'Failed to create transaction. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      print('Error during createTransaction: $e');
      throw ServerException('Failed to create transaction: $e');
    }
  }

  @override
  Future<List<TransactionModel>> getTransactions() async {
    final uri = Uri.parse('$baseUrl/transaction');
    try {
      final response = await client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          final List<dynamic> data = jsonResponse['data'];
          return data.map((json) => TransactionModel.fromJson(json)).toList();
        } catch (e) {
          throw ServerException('Failed to parse JSON response: $e');
        }
      } else {
        throw ServerException(
          "Failed to get transactions. Status: ${response.statusCode}, Body: ${response.body}",
        );
      }
    } catch (e) {
      print('Error during getTransactions: $e');
      throw ServerException("Failed to get transactions: $e");
    }
  }
}
