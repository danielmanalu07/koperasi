import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PinjamanFormPage extends StatefulWidget {
  final String token; // Halaman ini sekarang membutuhkan token

  const PinjamanFormPage({super.key, required this.token});

  @override
  State<PinjamanFormPage> createState() => _PinjamanFormPageState();
}

class _PinjamanFormPageState extends State<PinjamanFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false; // State untuk loading indicator

  // Controllers untuk input
  final TextEditingController _nominalController = TextEditingController();
  final TextEditingController _tujuanController = TextEditingController();
  
  // State untuk Dropdown
  String? _selectedJangkaWaktu;
  final List<String> _jangkaWaktuOptions = [
    '3 Bulan',
    '6 Bulan',
    '12 Bulan',
    '18 Bulan',
    '24 Bulan',
    '36 Bulan'
  ];

  @override
  void dispose() {
    _nominalController.dispose();
    _tujuanController.dispose();
    super.dispose();
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

    const String apiUrl = 'https://api-jatlinko.naditechno.id/api/v1/pinjaman';
    
    // Ekstrak angka dari string tenor, contoh: "12 Bulan" -> 12
    final tenor = int.tryParse(_selectedJangkaWaktu!.split(' ')[0]) ?? 0;

    // Siapkan body request sesuai format API
    final Map<String, dynamic> requestBody = {
      "pinjaman_category_id": 1, // Hardcoded sesuai contoh
      "anggota_id": 6, // Placeholder, idealnya ini didapat dari data user yang login
      "description": _tujuanController.text,
      "date": DateFormat('yyyy-MM-dd').format(DateTime.now()), // Tanggal hari ini
      "tenor": tenor,
      "interest_rate": 2, // Hardcoded sesuai contoh
      "nominal": int.tryParse(_nominalController.text) ?? 0,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}', // Menggunakan Bearer Token
        },
        body: jsonEncode(requestBody),
      );

      if (mounted) {
        final responseData = jsonDecode(response.body);

        if ((response.statusCode == 201 || response.statusCode == 200) && (responseData['code'] == 200 || responseData['code'] == 201)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? 'Pengajuan pinjaman berhasil!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Kembali & kirim sinyal untuk refresh data
        } else {
           String errorMessage = responseData['message'] ?? 'Gagal mengajukan pinjaman.';
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
        title: const Text('Form Ajukan Pinjaman',
        style: TextStyle(
          color: Colors.white
        )),
        backgroundColor: Colors.red.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Nominal Pinjaman
              _buildTextFormField(
                controller: _nominalController,
                labelText: 'Nominal Pinjaman (Rp)*',
                hintText: 'Masukkan jumlah nominal pinjaman',
                prefixText: 'Rp ',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                 validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nominal pinjaman tidak boleh kosong';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Masukkan nominal yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),

              // Tujuan Pinjaman
              _buildTextFormField(
                controller: _tujuanController,
                labelText: 'Tujuan Pinjaman*',
                hintText: 'Contoh: Modal Usaha, Renovasi Rumah',
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tujuan pinjaman tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),

              // Jangka Waktu (Bulan)
              _buildDropdownFormField(
                value: _selectedJangkaWaktu,
                hintText: 'Pilih Jangka Waktu',
                labelText: 'Jangka Waktu (Bulan)*',
                items: _jangkaWaktuOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedJangkaWaktu = value;
                  });
                },
                validator: (value) => value == null ? 'Jangka waktu tidak boleh kosong' : null,
              ),
              const SizedBox(height: 30.0),

              // Tombol Ajukan
              _isSaving
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: const Icon(Icons.send_outlined),
                  label: const Text('Ajukan Pinjaman'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)
                    )
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget untuk TextFormField
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    String? prefixText,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixText: prefixText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
      );
  }

  // Helper widget untuk DropdownButtonFormField
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
