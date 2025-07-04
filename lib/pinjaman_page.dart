// --- PinjamanPage Update ---
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:koperasi/core/constants/color_constant.dart';
// Important: Make sure this import matches your file structure for the updated entity
import 'package:koperasi/features/riwayat_pembayaran/domain/entities/riwayat_pembayaran.dart'
    as rp_entity;
import 'package:koperasi/features/riwayat_pembayaran/presentation/bloc/riwayat_pembayaran_bloc.dart';
import 'package:koperasi/features/riwayat_pembayaran/presentation/bloc/riwayat_pembayaran_event.dart';
import 'package:koperasi/features/riwayat_pembayaran/presentation/bloc/riwayat_pembayaran_state.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Still needed if LocalDatasource requires it
import 'package:url_launcher/url_launcher.dart'; // **Pastikan import ini ada dan benar**
import 'bayar_tagihan_page.dart'; // Ensure this path is correct
import 'pinjaman_form_page.dart'; // Ensure this path is correct

// Data model for RiwayatPinjaman (Loan History) - remains as is
class RiwayatPinjaman {
  final int id;
  final double nominalPinjaman;
  final DateTime tanggalPengajuan;
  final String statusPinjaman;
  final String tujuanPinjaman;
  final double angsuranPerBulan;
  final int tenorBulan;

  RiwayatPinjaman({
    required this.id,
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
          return 'Aktif'; // Default to Aktif or adjust as needed
      }
    }

    return RiwayatPinjaman(
      id: json['id'] as int,
      nominalPinjaman: double.parse(
        (json['nominal'] ?? 0).toString(),
      ), // Handle null or non-string nominal
      tanggalPengajuan: DateTime.parse(json['date'] as String),
      statusPinjaman: getStatusFromInt(json['status'] as int),
      tujuanPinjaman: json['description'] as String,
      angsuranPerBulan: (json['monthly_amortization'] ?? 0.0)
          .toDouble(), // Handle null
      tenorBulan: json['tenor'] as int,
    );
  }
}

class PinjamanPage extends StatefulWidget {
  final String? token; // This page requires a token

  const PinjamanPage({super.key, required this.token});

  @override
  State<PinjamanPage> createState() => _PinjamanPageState();
}

class _PinjamanPageState extends State<PinjamanPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  double _totalSisaPinjaman = 0;
  double _pinjamanBulanIni = 0;
  int?
  _activePinjamanDetailId; // To store the ID of the active loan for payment
  List<RiwayatPinjaman> _listRiwayatPinjaman = [];
  bool get _memilikiPinjamanAktif => _totalSisaPinjaman > 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _refresh(); // Call refresh to fetch both loan and payment data
  }

  // Unified refresh function to fetch both loan data and payment history
  Future<void> _refresh() async {
    if (!mounted) return; // Ensure widget is still mounted before setState
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _fetchPinjamanData(), // Fetch loan data
        _fetchRiwayatPembayaranData(), // Fetch payment history via Bloc
      ]);
    } catch (e) {
      // Errors are already handled by individual fetch methods with SnackBars
      debugPrint('Refresh failed with error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Fetches loan application data
  Future<void> _fetchPinjamanData() async {
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

            double totalSisa = 0;
            double tagihanBulanIni = 0;
            int? activeLoanId;

            for (var pinjaman in pinjamanList) {
              if (pinjaman.statusPinjaman == 'Aktif') {
                totalSisa += pinjaman.nominalPinjaman;
                tagihanBulanIni += pinjaman.angsuranPerBulan;
                if (activeLoanId == null) {
                  activeLoanId = pinjaman.id;
                }
              }
            }

            setState(() {
              _listRiwayatPinjaman = pinjamanList;
              _totalSisaPinjaman = totalSisa;
              _pinjamanBulanIni = tagihanBulanIni;
              _activePinjamanDetailId = activeLoanId;
            });
          } else {
            throw Exception(responseData['message'] ?? 'Invalid data format');
          }
        } else {
          throw Exception(
            'Failed to load loan data (Status: ${response.statusCode})',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching loan data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Calls the bloc to fetch payment history
  Future<void> _fetchRiwayatPembayaranData() async {
    context.read<RiwayatPembayaranBloc>().add(GetRiwayatPembayaranEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatCurrency(num amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String _formatDate(DateTime date) {
    return DateFormat(
      'dd MMMyyyy HH:mm', // Added HH:mm for more precise time
      'id_ID',
    ).format(date);
  }

  // --- Utility functions for status colors and text ---
  Color _getLoanStatusColor(String status) {
    String lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('disetujui') ||
        lowerStatus.contains('lunas') ||
        lowerStatus.contains('aktif')) {
      return Colors.green.shade700;
    }
    if (lowerStatus.contains('ditolak')) {
      return Colors.red.shade700;
    }
    if (lowerStatus.contains('diajukan')) {
      return Colors.orange.shade700;
    }
    return Colors.grey.shade700;
  }

  // Status for the payment record itself (from `riwayat_pembayaran` entity's `status` field)
  String _getPaymentRecordStatusText(int status, String type) {
    if (type == 'automatic') {
      if (status == 1) {
        return 'Diterima';
      } else if (status == 0) {
        return 'Menunggu';
      } else if (status == -1) {
        return 'Ditolak';
      }
    } else if (type == 'manual') {
      if (status == 1) {
        return 'Diterima';
      } else if (status == 0) {
        return 'Menunggu';
      } else if (status == -1) {
        return 'Ditolak';
      }
    }
    return 'Status Tidak Diketahui'; // Fallback
  }

  Color _getPaymentRecordStatusColor(int status, String type) {
    if (type == 'automatic') {
      if (status == 1) return Colors.green.shade700;
      if (status == 0) return Colors.orange.shade800;
      if (status == -1) return Colors.red.shade700;
    } else if (type == 'manual') {
      if (status == 1) return Colors.green.shade700;
      if (status == 0) return Colors.orange.shade800;
      if (status == -1) return Colors.red.shade700;
    }
    return Colors.grey.shade700;
  }

  // Status for the nested 'transaction' object (from `transaction.status` field)
  String _getTransactionStatusText(int transactionStatus) {
    switch (transactionStatus) {
      case 0:
        return 'Pending'; // Payment is created but not yet paid
      case 1:
        return 'Settlement'; // Payment received and being processed
      case 2:
        return 'Success'; // Payment completed
      case 3:
        return 'Denied'; // Payment denied by bank/system
      case 4:
        return 'Expired'; // Payment link expired
      case 5:
        return 'Cancelled'; // Payment cancelled by user
      default:
        return 'Tidak Diketahui';
    }
  }

  Color _getTransactionStatusColor(int transactionStatus) {
    switch (transactionStatus) {
      case 0:
        return Colors.orange.shade800;
      case 1:
        return Colors.green.shade600;
      case 2:
        return Colors.green.shade800;
      case 3:
        return Colors.red.shade700;
      case 4:
        return Colors.red.shade700;
      case 5:
        return Colors.grey.shade600;
      default:
        return Colors.grey.shade700;
    }
  }

  // New function to show payment detail modal
  void _showPaymentDetailModal(
    BuildContext context,
    rp_entity.RiwayatPembayaran paymentItem,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Detail Pembayaran',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            24,
            20,
            24,
            0,
          ), // Default padding for content
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInfoRow('ID Pembayaran:', paymentItem.id.toString()),
                _buildInfoRow('Nominal:', _formatCurrency(paymentItem.amount)),
                _buildInfoRow(
                  'Tanggal Pengajuan:',
                  _formatDate(paymentItem.createdAt),
                ),
                _buildInfoRow(
                  'Tipe Pembayaran:',
                  paymentItem.type == 'manual' ? 'Manual Transfer' : 'Otomatis',
                ),
                // Display payment record status (from the main status field of the payment record)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status Pembayaran:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getPaymentRecordStatusText(
                            paymentItem.status,
                            paymentItem.type,
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getPaymentRecordStatusColor(
                              paymentItem.status,
                              paymentItem.type,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Display transaction details if available
                if (paymentItem.transaction != null) ...[
                  const Divider(height: 24),
                  const Text(
                    'Detail Transaksi Terkait:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'ID Transaksi:',
                    paymentItem.transaction!.id.toString(),
                  ),
                  _buildInfoRow('Order ID:', paymentItem.transaction!.orderId),
                  _buildInfoRow(
                    'Waktu Kadaluarsa:',
                    _formatDate(paymentItem.transaction!.expiresAt),
                  ),
                  if (paymentItem.transaction!.paidAt != null)
                    _buildInfoRow(
                      'Waktu Pembayaran:',
                      _formatDate(paymentItem.transaction!.paidAt!),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Status Transaksi:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getTransactionStatusText(
                              paymentItem.transaction!.status,
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getTransactionStatusColor(
                                paymentItem.transaction!.status,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Display payment link as a clickable text if exists and payment is automatic
                  // and transaction is not yet success/settlement/paid
                  if (paymentItem.type == 'automatic' &&
                      paymentItem.transaction!.paymentLink != null &&
                      (paymentItem.transaction!.status == 0 || // Pending
                          paymentItem.transaction!.status == 3 || // Denied
                          paymentItem.transaction!.status ==
                              4 // Expired
                              ))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextButton.icon(
                        icon: const Icon(Icons.link, color: Colors.blue),
                        label: Text(
                          'Buka Link Pembayaran',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        onPressed: () async {
                          final Uri url = Uri.parse(
                            paymentItem.transaction!.paymentLink!,
                          );
                          if (await canLaunchUrl(url)) {
                            await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                            // Refresh after launching URL, as status might change
                            _refresh();
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Tidak dapat membuka link pembayaran: ${url.toString()}',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                ],
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // Show 'Bayar Sekarang' only for automatic payments that are still actionable
            // (transaction status: Pending (0), Denied (3), Expired (4))
            if (paymentItem.type == 'automatic' &&
                paymentItem.transaction?.paymentLink != null &&
                (paymentItem.transaction?.status == 0 ||
                    paymentItem.transaction?.status == 3 ||
                    paymentItem.transaction?.status == 4))
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Bayar Sekarang'),
                onPressed: () async {
                  Navigator.of(context).pop(); // Close the dialog
                  final Uri url = Uri.parse(
                    paymentItem.transaction!.paymentLink!,
                  );
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Tidak dapat membuka link pembayaran: ${url.toString()}',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                  // Refresh payment history after attempting to open link,
                  // as status might change if payment is successful.
                  _refresh();
                },
              ),
          ],
        );
      },
    );
  }

  // Helper function to build info rows for readability
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
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
            onPressed: _isLoading ? null : _refresh,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: ColorConstant.whiteColor),
            ) // Using primaryColor constant
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
                        foregroundColor: const Color(0xFFE30031),
                        side: const BorderSide(
                          color: Color(0xFFE30031),
                          width: 1.5,
                        ),
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
                  if (_pinjamanBulanIni > 0 &&
                      _activePinjamanDetailId != null) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BayarTagihanPage(
                                tagihanBulanIni: _pinjamanBulanIni,
                                pinjamanDetailId:
                                    _activePinjamanDetailId!, // Pass the ID
                                token: widget.token!, // Pass the token
                              ),
                            ),
                          ).then((value) {
                            if (value == true) {
                              _refresh(); // Refresh data after payment
                            }
                          });
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
    return BlocBuilder<RiwayatPembayaranBloc, RiwayatPembayaranState>(
      builder: (context, state) {
        if (state is RiwayatPembayaranLoading) {
          return const Center(
            child: CircularProgressIndicator(color: ColorConstant.whiteColor),
          );
        } else if (state is RiwayatPembayaranLoaded) {
          debugPrint(
            'Data Riwayat Pembayaran Loaded: ${state.riwayatPembayaran.length} items',
          );
          for (var item in state.riwayatPembayaran) {
            debugPrint(
              '   - ID: ${item.id}, Amount: ${item.amount}, Type: ${item.type}, Created: ${item.createdAt}, Status: ${item.status}, Transaction: ${item.transaction != null ? item.transaction!.id : 'N/A'}, Transaction Status: ${item.transaction?.status ?? 'N/A'}, PaidAt: ${item.transaction?.paidAt ?? 'N/A'}, PaymentLink: ${item.transaction?.paymentLink ?? 'N/A'}',
            );
          }
          if (state.riwayatPembayaran.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Belum ada Riwayat Pembayaran. Silahkan refresh data!',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<RiwayatPembayaranBloc>().add(
                        GetRiwayatPembayaranEvent(),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConstant.foregroundColor,
                      foregroundColor: ColorConstant.whiteColor,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: state.riwayatPembayaran.length,
            itemBuilder: (context, index) {
              final item = state.riwayatPembayaran[index];
              return Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: InkWell(
                  // Make the card tappable
                  onTap: () => _showPaymentDetailModal(
                    context,
                    item,
                  ), // Show detail modal on tap
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatCurrency(item.amount),
                              style: const TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _formatDate(item.createdAt),
                              style: TextStyle(
                                fontSize: 13.0,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6.0),
                        Text(
                          'Metode: ${item.type == 'manual' ? 'Manual Transfer' : 'Otomatis'}',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        // Display payment record status
                        Text(
                          'Status: ${_getPaymentRecordStatusText(item.status, item.type)}',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: _getPaymentRecordStatusColor(
                              item.status,
                              item.type,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } else if (state is RiwayatPembayaranError) {
          return Center(
            child: Column(
              // Wrap in Column for refresh button
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${state.message}',
                  style: const TextStyle(
                    color: ColorConstant.redColor,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16.0),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<RiwayatPembayaranBloc>().add(
                      GetRiwayatPembayaranEvent(),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConstant.foregroundColor,
                    foregroundColor: ColorConstant.whiteColor,
                  ),
                ),
              ],
            ),
          );
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Belum ada Riwayat Pembayaran. Silahkan refresh data!',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<RiwayatPembayaranBloc>().add(
                    GetRiwayatPembayaranEvent(),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstant.foregroundColor,
                  foregroundColor: ColorConstant.whiteColor,
                ),
              ),
            ],
          ),
        );
      },
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
            textAlign: TextAlign.center,
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
                    color: _getLoanStatusColor(item.statusPinjaman),
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
