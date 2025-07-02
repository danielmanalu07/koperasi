import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class TabunganFormPage extends StatefulWidget {
  final String token;

  const TabunganFormPage({super.key, required this.token});

  @override
  State<TabunganFormPage> createState() => _TabunganFormPageState();
}

class _TabunganFormPageState extends State<TabunganFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  final Map<String, int> _kategoriTabunganMap = {
    'Tabungan Umroh': 1,
    'Tabungan Qurban': 2,
    'Tabungan Pendidikan': 3,
    'Tabungan Lainnya': 4,
  };
  String? _selectedKategoriTabungan;
  final List<String> _kategoriTabunganOptions = [
    'Tabungan Umroh',
    'Tabungan Qurban',
    'Tabungan Pendidikan',
    'Tabungan Lainnya'
  ];

  final TextEditingController _nominalController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();

  String? _selectedJenisPembayaran;
  final List<String> _jenisPembayaranOptions = ['Manual Transfer', 'Otomatis'];

  String? _selectedRekeningTujuan;
  final List<String> _rekeningTujuanOptions = [
    'BCA - 123456789 (Koperasi Sejahtera)',
    'Mandiri - 0987654321 (Koperasi Makmur)',
  ];

  @override
  void dispose() {
    _nominalController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak dapat membuka URL: $url'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi semua field yang wajib diisi.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    const String apiUrl = 'https://api-jatlinko.naditechno.id/api/v1/tabungan';
    
    // --- PERBAIKAN LOGIKA 'type' ---
    String type;
    if (_selectedJenisPembayaran == 'Otomatis') {
      type = 'automatic';
    } else {
      type = 'manual';
    }
    // --- AKHIR PERBAIKAN ---
    
    final Map<String, dynamic> requestBody = {
      "tabungan_category_id": _kategoriTabunganMap[_selectedKategoriTabungan],
      "anggota_id": 6, // Placeholder
      "description": _keteranganController.text,
      "date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
      "nominal": int.tryParse(_nominalController.text) ?? 0,
      "type": type, // Menggunakan variabel 'type' yang sudah diperbaiki
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode(requestBody),
      );

      if (mounted) {
        final responseData = jsonDecode(response.body);

        if ((response.statusCode == 201 || response.statusCode == 200) && (responseData['code'] == 200 || responseData['code'] == 201)) {
          
          if (_selectedJenisPembayaran == 'Otomatis') {
            // --- PERBAIKAN PENGAMBILAN URL PEMBAYARAN ---
            String? paymentUrl = responseData['data']?['transaction']?['payment_link'];

            if (paymentUrl != null && paymentUrl.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transaksi dibuat, mengalihkan ke pembayaran...'), backgroundColor: Colors.blue),
              );
              
              await _launchURL(paymentUrl);
              Navigator.pop(context, true); // Kembali & kirim sinyal refresh
            } else {
              // Jika URL tidak ditemukan di respons
              throw Exception('URL pembayaran tidak ditemukan pada respons API.');
            }
            // --- AKHIR PERBAIKAN ---

          } else { // Untuk 'Manual Transfer'
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pengajuan tabungan berhasil! Silakan lakukan transfer.'), backgroundColor: Colors.green),
            );
            Navigator.pop(context, true); // Kembali & kirim sinyal untuk refresh data
          }
        } else {
           String errorMessage = responseData['message'] ?? 'Gagal menyimpan data.';
           if (responseData['errors'] != null && responseData['errors'] is Map) {
              errorMessage = (responseData['errors'] as Map).values.first[0];
           }
           throw Exception(errorMessage);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if(mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Tambah Tabungan', 
          style: TextStyle(
            color: Colors.white // Mengubah warna teks judul menjadi putih
          )
        ),
        backgroundColor: Color(0xFFE30031),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildDropdownFormField(
                value: _selectedKategoriTabungan,
                hintText: 'Pilih Kategori Tabungan',
                labelText: 'Kategori Tabungan*',
                items: _kategoriTabunganOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedKategoriTabungan = value;
                  });
                },
                validator: (value) => value == null ? 'Kategori tabungan tidak boleh kosong' : null,
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _nominalController,
                decoration: InputDecoration(
                  labelText: 'Nominal (Rp)*',
                  hintText: 'Masukkan jumlah nominal tabungan',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Nominal tidak boleh kosong';
                  if (int.tryParse(value) == null || int.parse(value) <= 0) return 'Masukkan nominal yang valid';
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
               TextFormField(
                controller: _keteranganController,
                decoration: InputDecoration(
                  labelText: 'Keterangan*',
                  hintText: 'Contoh: Setoran tabungan umroh',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Keterangan tidak boleh kosong';
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              _buildDropdownFormField(
                value: _selectedJenisPembayaran,
                hintText: 'Pilih Jenis Pembayaran',
                labelText: 'Jenis Pembayaran*',
                items: _jenisPembayaranOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedJenisPembayaran = value;
                    _selectedRekeningTujuan = null;
                  });
                },
                validator: (value) => value == null ? 'Jenis pembayaran tidak boleh kosong' : null,
              ),
              const SizedBox(height: 20.0),
              if (_selectedJenisPembayaran == 'Manual Transfer')
                _buildDropdownFormField(
                  value: _selectedRekeningTujuan,
                  hintText: 'Pilih Rekening Tujuan',
                  labelText: 'Rekening Tujuan*',
                  items: _rekeningTujuanOptions,
                  onChanged: (value) {
                    setState(() {
                      _selectedRekeningTujuan = value;
                    });
                  },
                  validator: (value) => value == null ? 'Rekening tujuan tidak boleh kosong' : null,
                ),
              
              const SizedBox(height: 30.0),

              _isSaving
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE30031),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)
                  )
                ),
                child: const Text('Proses Tabungan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownFormField({
    required String? value,
    required String hintText,
    required String labelText,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      isExpanded: true,
    );
  }
}
