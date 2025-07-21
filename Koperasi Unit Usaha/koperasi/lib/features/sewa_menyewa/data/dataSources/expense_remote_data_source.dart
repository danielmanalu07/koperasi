import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:koperasi/core/errors/exceptions.dart';
import 'package:koperasi/features/sewa_menyewa/data/model/expense/expense_model.dart';

abstract class ExpenseRemoteDataSource {
  Future<List<ExpenseModel>> getExpenses();
  Future<ExpenseModel> addExpense(ExpenseModel expense);
  Future<ExpenseModel> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(int id);
}

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final http.Client client;
  final String baseUrl =
      'http://10.0.2.2:3001/api/sewa'; // Base URL for your API

  ExpenseRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ExpenseModel>> getExpenses() async {
    final response = await client.get(
      Uri.parse('$baseUrl/pengeluaran'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 200 && jsonResponse['data'] != null) {
        return (jsonResponse['data'] as List)
            .map((e) => ExpenseModel.fromJson(e))
            .toList();
      } else {
        throw ServerException(
          jsonResponse['message'] ?? 'Failed to load expenses',
        );
      }
    } else {
      throw ServerException('Failed to load expenses: ${response.statusCode}');
    }
  }

  @override
  Future<ExpenseModel> addExpense(ExpenseModel expense) async {
    final response = await client.post(
      Uri.parse('$baseUrl/pengeluaran/create'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(expense.toCreateJson()), // Use toCreateJson
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 200 && jsonResponse['data'] != null) {
        return ExpenseModel.fromJson(jsonResponse['data']);
      } else {
        throw ServerException(
          jsonResponse['message'] ?? 'Failed to add expense',
        );
      }
    } else {
      throw ServerException('Failed to add expense: ${response.statusCode}');
    }
  }

  @override
  Future<ExpenseModel> updateExpense(ExpenseModel expense) async {
    final response = await client.put(
      Uri.parse('$baseUrl/pengeluaran/${expense.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(expense.toJson()), // Use toJson which includes ID
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 200 && jsonResponse['data'] != null) {
        return ExpenseModel.fromJson(jsonResponse['data']);
      } else {
        throw ServerException(
          jsonResponse['message'] ?? 'Failed to update expense',
        );
      }
    } else {
      throw ServerException('Failed to update expense: ${response.statusCode}');
    }
  }

  @override
  Future<void> deleteExpense(int id) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/pengeluaran/$id'), // Assuming delete by ID in path
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] != 200) {
        throw ServerException(
          jsonResponse['message'] ?? 'Failed to delete expense',
        );
      }
    } else {
      throw ServerException('Failed to delete expense: ${response.statusCode}');
    }
  }
}
