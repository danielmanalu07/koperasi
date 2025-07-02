import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'bayar_tagihan_page.dart';
import 'pinjaman_form_page.dart';

// Model data disesuaikan dengan respons API
class RiwayatPinjaman {
  final double nominalPinjaman;
  final DateTime tanggalPengajuan;
  final String statusPinjaman;
  final String tujuanPinjaman;
  final double angsuranPerBulan;
  final int tenorBulan;

  RiwayatPinjaman({
    required this.nominalPinjaman,
    required this.tanggalPengajuan,
    required this.statusPinjaman,
    required this.tujuanPinjaman,
    required this.angsuranPerBulan,
    required this.tenorBulan,
  });

  factory RiwayatPinjaman.fromJson(Map<String, dynamic> json) {
    String getStatusFromInt(int status) {
      switch (status) {
        case 1:
          return 'Aktif';
        case 0:
          return 'Diajukan';
        case -1:
          return 'Ditolak';
        default:
          return 'Aktif';
      }
    }

    return RiwayatPinjaman(
      nominalPinjaman: (json['nominal'] as num).toDouble(),
      tanggalPengajuan: DateTime.parse(json['date'] as String),
      statusPinjaman: getStatusFromInt(json['status'] as int),
      tujuanPinjaman: json['description'] as String,
      angsuranPerBulan: (json['monthly_amortization'] as num).toDouble(),
      tenorBulan: json['tenor'] as int,
    );
  }
}

// Model untuk Riwayat Pembayaran (tetap menggunakan placeholder)
class RiwayatPembayaranPinjaman {
  final double nominalBayar;
  final DateTime tanggalBayar;
  final String metodePembayaran;
  final String status;

  RiwayatPembayaranPinjaman({
    required this.nominalBayar,
    required this.tanggalBayar,
    required this.metodePembayaran,
    required this.status,
  });
}

class PinjamanPage extends StatefulWidget {
  final String? token; // Halaman ini membutuhkan token

  const PinjamanPage({super.key, required this.token});

  @override
  State<PinjamanPage> createState() => _PinjamanPageState();
}

class _PinjamanPageState extends State<PinjamanPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  // State untuk data dari API
  double _totalSisaPinjaman = 0;
  double _pinjamanBulanIni = 0;
  List<RiwayatPinjaman> _listRiwayatPinjaman = [];
  bool get _memilikiPinjamanAktif => _totalSisaPinjaman > 0;

  // Data placeholder untuk riwayat pembayaran (API belum ada)
  final List<RiwayatPembayaranPinjaman> _listRiwayatPembayaran = [
    RiwayatPembayaranPinjaman(
      nominalBayar: 1500000,
      tanggalBayar: DateTime(2024, 5, 5),
      metodePembayaran: 'Transfer Bank BCA',
      status: 'Lunas',
    ),
    RiwayatPembayaranPinjaman(
      nominalBayar: 1500000,
      tanggalBayar: DateTime(2024, 4, 5),
      metodePembayaran: 'Auto Debit',
      status: 'Lunas',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchPinjamanData();
  }

  Future<void> _fetchPinjamanData() async {
    setState(() => _isLoading = true);
    const String apiUrl = 'https://api-jatlinko.naditechno.id/api/v1/pinjaman';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (mounted) {
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData['code'] == 200 && responseData['data'] != null) {
            List<dynamic> pinjamanJson = responseData['data']['data'];
            final List<RiwayatPinjaman> pinjamanList = pinjamanJson
                .map((json) => RiwayatPinjaman.fromJson(json))
                .toList();

            // Kalkulasi ringkasan dari data pinjaman yang aktif
            double totalSisa = 0;
            double tagihanBulanIni = 0;
            for (var pinjaman in pinjamanList) {
              if (pinjaman.statusPinjaman == 'Aktif') {
                // Asumsi: API tidak memberikan sisa pinjaman, jadi kita tampilkan nominal awal.
                // Di aplikasi nyata, API harusnya memberikan sisa pokok.
                totalSisa += pinjaman.nominalPinjaman;
                tagihanBulanIni += pinjaman.angsuranPerBulan;
              }
            }

            setState(() {
              _listRiwayatPinjaman = pinjamanList;
              _totalSisaPinjaman = totalSisa;
              _pinjamanBulanIni = tagihanBulanIni;
            });
          } else {
            throw Exception(
              responseData['message'] ?? 'Format data tidak valid',
            );
          }
        } else {
          throw Exception('Gagal memuat data (Status: ${response.statusCode})');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  Color _getStatusColor(String status) {
    String lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('disetujui') ||
        lowerStatus.contains('lunas') ||
        lowerStatus.contains('aktif'))
      return Colors.green.shade700;
    if (lowerStatus.contains('ditolak')) return Colors.red.shade700;
    if (lowerStatus.contains('diajukan')) return Colors.orange.shade700;
    return Colors.grey.shade700;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Informasi Pinjaman',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red.shade700,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchPinjamanData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildPinjamanSummaryCard(),
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.red.shade800,
                  unselectedLabelColor: Colors.grey.shade600,
                  indicatorColor: Colors.red.shade700,
                  indicatorWeight: 3.0,
                  tabs: const [
                    Tab(text: 'Riwayat Pembayaran'),
                    Tab(text: 'Riwayat Pinjaman'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildHistoryPembayaranListView(),
                      _buildHistoryPinjamanListView(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPinjamanSummaryCard() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Pinjaman Anda',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Sisa Pinjaman:',
                  style: TextStyle(fontSize: 16.0, color: Colors.black54),
                ),
                Text(
                  _formatCurrency(_totalSisaPinjaman),
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tagihan Bulan Ini:',
                  style: TextStyle(fontSize: 16.0, color: Colors.black54),
                ),
                Text(
                  _formatCurrency(_pinjamanBulanIni),
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: _pinjamanBulanIni > 0
                        ? Colors.orange.shade800
                        : Colors.green.shade800,
                  ),
                ),
              ],
            ),
            if (_memilikiPinjamanAktif || _pinjamanBulanIni > 0) ...[
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PinjamanFormPage(token: widget.token!),
                          ),
                        ).then((value) {
                          if (value == true) _fetchPinjamanData();
                        });
                      },
                      icon: const Icon(Icons.add_card),
                      label: const Text('Ajukan'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFFE30031),
                        side: BorderSide(color: Color(0xFFE30031), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        textStyle: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  if (_pinjamanBulanIni > 0) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BayarTagihanPage(
                                tagihanBulanIni: _pinjamanBulanIni,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.payment),
                        label: const Text('Bayar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          textStyle: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryPembayaranListView() {
    if (_listRiwayatPembayaran.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Belum ada riwayat pembayaran.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: _listRiwayatPembayaran.length,
      itemBuilder: (context, index) {
        final item = _listRiwayatPembayaran[index];
        return Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatCurrency(item.nominalBayar),
                      style: const TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatDate(item.tanggalBayar),
                      style: TextStyle(
                        fontSize: 13.0,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),
                Text(
                  'Metode: ${item.metodePembayaran}',
                  style: TextStyle(fontSize: 14.0, color: Colors.grey.shade800),
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const Divider(height: 16.0),
    );
  }

  Widget _buildHistoryPinjamanListView() {
    if (_listRiwayatPinjaman.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Belum ada riwayat pengajuan pinjaman.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: _listRiwayatPinjaman.length,
      itemBuilder: (context, index) {
        final item = _listRiwayatPinjaman[index];
        return _buildHistoryPinjamanItem(item);
      },
      separatorBuilder: (context, index) => const Divider(height: 16.0),
    );
  }

  Widget _buildHistoryPinjamanItem(RiwayatPinjaman item) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatCurrency(item.nominalPinjaman),
                  style: const TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatDate(item.tanggalPengajuan),
                  style: TextStyle(fontSize: 13.0, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 6.0),
            Text(
              'Tujuan: ${item.tujuanPinjaman}',
              style: TextStyle(fontSize: 14.0, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Angsuran: ${_formatCurrency(item.angsuranPerBulan)} / ${item.tenorBulan} bln',
              style: TextStyle(fontSize: 13.0, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 4.0),
            Row(
              children: [
                Text(
                  'Status: ',
                  style: TextStyle(fontSize: 14.0, color: Colors.grey.shade700),
                ),
                Text(
                  item.statusPinjaman,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(item.statusPinjaman),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
