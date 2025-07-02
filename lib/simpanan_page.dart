import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'simpanan_form_page.dart';

// Model data disesuaikan dengan respons API
class RiwayatSimpanan {
  final double nominal;
  final DateTime tanggal;
  final String status; // Berhasil, Menunggu, Gagal
  final String keterangan;
  final String kategori; // Simpanan Pokok, Wajib, dll.

  RiwayatSimpanan({
    required this.nominal,
    required this.tanggal,
    required this.status,
    required this.keterangan,
    required this.kategori,
  });

  // Factory constructor untuk membuat instance dari JSON
  factory RiwayatSimpanan.fromJson(Map<String, dynamic> json) {
    // Fungsi untuk mengubah status integer dari API menjadi string
    String getStatusFromInt(int status) {
      switch (status) {
        case 1:
          return 'Berhasil';
        case 0:
          return 'Menunggu';
        case -1:
          return 'Gagal';
        default:
          return 'Tidak Diketahui';
      }
    }

    return RiwayatSimpanan(
      // Pastikan konversi tipe data aman
      nominal: (json['nominal'] as num).toDouble(),
      tanggal: DateTime.parse(json['date'] as String),
      status: getStatusFromInt(json['status'] as int),
      keterangan: json['description'] as String,
      kategori: json['simpanan_category_name'] as String,
    );
  }
}

class SimpananPage extends StatefulWidget {
  final String? token; // Halaman ini sekarang membutuhkan token

  const SimpananPage({super.key, required this.token});

  @override
  State<SimpananPage> createState() => _SimpananPageState();
}

class _SimpananPageState extends State<SimpananPage> {
  // State untuk data dari API
  bool _isLoading = true;
  double _totalSimpanan = 0;
  double _simpananPokok = 0;
  double _simpananWajib = 0;
  double _simpananSukarela = 0;
  List<RiwayatSimpanan> _listRiwayat = [];

  @override
  void initState() {
    super.initState();
    _fetchSimpananData();
  }

  Future<void> _fetchSimpananData() async {
    setState(() => _isLoading = true);
    const String apiUrl = 'https://api-jatlinko.naditechno.id/api/v1/simpanan';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}', // Menggunakan token
        },
      );

      if (mounted) {
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData['code'] == 200 && responseData['data'] != null) {
            final data = responseData['data'];
            List<dynamic> riwayatJson = data['data'];

            // Proses data riwayat
            final List<RiwayatSimpanan> riwayat = riwayatJson
                .map((json) => RiwayatSimpanan.fromJson(json))
                .toList();

            // Kalkulasi total dan rincian simpanan (contoh kalkulasi dari riwayat)
            double total = 0;
            double pokok = 0;
            double wajib = 0;
            double sukarela = 0;

            for (var item in riwayat) {
              if (item.status == 'Berhasil') {
                // Hanya hitung yang berhasil
                total += item.nominal;
                if (item.kategori == 'Simpanan Pokok') {
                  pokok += item.nominal;
                } else if (item.kategori == 'Simpanan Wajib') {
                  wajib += item.nominal;
                } else {
                  // Asumsikan sisanya sukarela
                  sukarela += item.nominal;
                }
              }
            }

            setState(() {
              _listRiwayat = riwayat;
              _totalSimpanan = total;
              _simpananPokok = pokok;
              _simpananWajib = wajib;
              _simpananSukarela = sukarela;
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
    switch (status.toLowerCase()) {
      case 'berhasil':
        return Colors.green.shade700;
      case 'menunggu':
        return Colors.orange.shade700;
      case 'gagal':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Simpanan Saya',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFFE30031),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchSimpananData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchSimpananData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderSection(),
                    const SizedBox(height: 24.0),
                    _buildSummaryCard(),
                    const SizedBox(height: 24.0),
                    _buildHistorySection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Simpanan Anda',
              style: TextStyle(fontSize: 16.0, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 4.0),
            Text(
              _formatCurrency(_totalSimpanan),
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE30031),
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SimpananFormPage(token: widget.token!),
              ),
            ).then((_) => _fetchSimpananData());
          },
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Tambah'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFE30031),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rincian Saldo Simpanan',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16.0),
            _buildSummaryRow('Simpanan Pokok', _formatCurrency(_simpananPokok)),
            const Divider(height: 20.0),
            _buildSummaryRow('Simpanan Wajib', _formatCurrency(_simpananWajib)),
            const Divider(height: 20.0),
            _buildSummaryRow(
              'Simpanan Sukarela',
              _formatCurrency(_simpananSukarela),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 15.0, color: Colors.grey.shade800),
        ),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Riwayat Simpanan',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12.0),
        _listRiwayat.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    'Belum ada riwayat simpanan.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _listRiwayat.length,
                itemBuilder: (context, index) {
                  final item = _listRiwayat[index];
                  return _buildHistoryItem(item);
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12.0),
              ),
      ],
    );
  }

  Widget _buildHistoryItem(RiwayatSimpanan item) {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatCurrency(item.nominal),
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatDate(item.tanggal),
                  style: TextStyle(fontSize: 12.0, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 6.0),
            Row(
              children: [
                Text(
                  'Status: ',
                  style: TextStyle(fontSize: 13.0, color: Colors.grey.shade700),
                ),
                Text(
                  item.status,
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(item.status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            Text(
              'Kategori: ${item.kategori}',
              style: TextStyle(fontSize: 13.0, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 6.0),
            Text(
              item.keterangan,
              style: TextStyle(
                fontSize: 13.0,
                color: Colors.grey.shade800,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
