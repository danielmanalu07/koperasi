import 'package:equatable/equatable.dart';

class Dashboard extends Equatable {
  final double totalSaldo;
  final double totalPemasukan;
  final double totalPengeluaran;
  final double totalAset;
  final List<MonthlySummary> monthlySummary;

  const Dashboard({
    required this.totalSaldo,
    required this.totalPemasukan,
    required this.totalPengeluaran,
    required this.totalAset,
    required this.monthlySummary,
  });

  @override
  List<Object> get props => [
    totalSaldo,
    totalPemasukan,
    totalPengeluaran,
    totalAset,
    monthlySummary,
  ];
}

class MonthlySummary extends Equatable {
  final String month;
  final double pemasukan;
  final double pengeluaran;

  const MonthlySummary({
    required this.month,
    required this.pemasukan,
    required this.pengeluaran,
  });

  @override
  List<Object?> get props => [month, pemasukan, pengeluaran];
}
