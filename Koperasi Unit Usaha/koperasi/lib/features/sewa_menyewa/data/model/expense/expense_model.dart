import 'package:koperasi/features/sewa_menyewa/domain/entities/expense.dart';

class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id,
    required super.date,
    required super.category,
    required super.amount,
    required super.description,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      date: DateTime.parse(json['tanggal']),
      category: json['kategori'],
      amount: json['jumlah'],
      description: json['keterangan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tanggal': date.toIso8601String().split('T')[0],
      'kategori': category,
      'jumlah': amount,
      'keterangan': description,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'tanggal': date.toIso8601String().split('T')[0],
      'kategori': category,
      'jumlah': amount,
      'keterangan': description,
    };
  }
}
