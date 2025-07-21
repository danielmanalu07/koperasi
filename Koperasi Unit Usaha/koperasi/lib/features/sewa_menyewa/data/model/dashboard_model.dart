import 'package:koperasi/features/sewa_menyewa/domain/entities/dashboard.dart';

class DashboardModel extends Dashboard {
  const DashboardModel({
    required super.totalSaldo,
    required super.totalPemasukan,
    required super.totalPengeluaran,
    required super.totalAset,
    required super.monthlySummary,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalSaldo: json['total_saldo'].toDouble(),
      totalPemasukan: json['total_pemasukan'].toDouble(),
      totalPengeluaran: json['total_pengeluaran'].toDouble(),
      totalAset: json['total_aset'].toDouble(),
      monthlySummary: List<MonthlySummary>.from(
        json['monthly_summary'].map(
          (x) => MonthlySummary(
            month: x['month'],
            pemasukan: x['pemasukan'].toDouble(),
            pengeluaran: x['pengeluaran'].toDouble(),
          ),
        ),
      ),
    );
  }
}
