import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class SimpananFormPage extends StatefulWidget {
  final String token;

  const SimpananFormPage({super.key, required this.token});

  @override
  State<SimpananFormPage> createState() => _SimpananFormPageState();
}

class _SimpananFormPageState extends State<SimpananFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  final Map<String, int> _kategoriSimpananMap = {
    'Simpanan Pokok': 1,
    'Simpanan Wajib': 2,
    'Simpanan Sukarela': 3,
  };
  String? _selectedKategoriSimpanan;
  final List<String> _kategoriSimpananOptions = [
    'Simpanan Pokok',
    'Simpanan Wajib',
    'Simpanan Sukarela',
  ];

  final TextEditingController _nominalController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();

  String? _selectedJenisPembayaran;
  final List<String> _jenisPembayaranOptions = ['Manual Transfer', 'Otomatis'];

  String? _selectedRekeningTujuan;
  final List<String> _rekeningTujuanOptions = [
    'BCA - 123456789 (Koperasi Sejahtera)',
    'Mandiri - 0987654321 (Koperasi Makmur)',
    'BNI - 1122334455 (Koperasi Bersama)',
  ];

  File? _transferProofImageFile;

  @override
  void dispose() {
    _nominalController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Compress image quality to reduce size
    );

    if (pickedFile != null) {
      // You can also compress the image further if needed before setting the state
      // For example, using the 'flutter_image_compress' package
      setState(() {
        _transferProofImageFile = File(pickedFile.path);
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada gambar yang dipilih.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat membuka URL: $url'),
            backgroundColor: Colors.red,
          ),
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

    if (_selectedJenisPembayaran == 'Manual Transfer' &&
        _transferProofImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap unggah bukti transfer.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    const String apiUrl = 'https://api-jatlinko.naditechno.id/api/v1/simpanan';

    String type;
    if (_selectedJenisPembayaran == 'Otomatis') {
      type = 'automatic';
    } else {
      type = 'manual';
    }

    try {
      // Use MultipartRequest for file upload
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      });

      // Add form fields
      request.fields['simpanan_category_id'] =
          (_kategoriSimpananMap[_selectedKategoriSimpanan]).toString();
      request.fields['anggota_id'] =
          '6'; // Placeholder, get from logged-in user
      request.fields['description'] = _keteranganController.text;
      request.fields['date'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
      request.fields['nominal'] = (int.tryParse(_nominalController.text) ?? 0)
          .toString();
      request.fields['type'] = type;

      // Add image file if Manual Transfer is selected
      if (_selectedJenisPembayaran == 'Manual Transfer' &&
          _transferProofImageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image', // This is the field name your API expects for the image file
            _transferProofImageFile!.path,
            // Optional: contentType to specify image type if known, e.g., MediaType('image', 'jpeg')
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (mounted) {
        final responseData = jsonDecode(response.body);
        print('Data Simpanan Baru: $responseData');

        if ((response.statusCode == 201 || response.statusCode == 200) &&
            (responseData['code'] == 200 || responseData['code'] == 201)) {
          if (_selectedJenisPembayaran == 'Otomatis') {
            String? paymentUrl =
                responseData['data']?['transaction']?['payment_link'];

            if (paymentUrl != null && paymentUrl.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Transaksi dibuat, mengalihkan ke pembayaran...',
                  ),
                  backgroundColor: Colors.blue,
                ),
              );
              await _launchURL(paymentUrl);
              Navigator.pop(context, true);
            } else {
              throw Exception(
                'URL pembayaran tidak ditemukan pada respons API.',
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Pengajuan simpanan berhasil! Silakan lakukan transfer manual.',
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
        } else {
          String errorMessage =
              responseData['message'] ?? 'Gagal menyimpan data.';
          if (responseData['errors'] != null && responseData['errors'] is Map) {
            // Iterate through errors to get all messages
            List<String> errorsList = [];
            (responseData['errors'] as Map).forEach((key, value) {
              if (value is List) {
                errorsList.addAll(value.map((e) => e.toString()));
              } else {
                errorsList.add(value.toString());
              }
            });
            errorMessage = errorsList.join(
              '\n',
            ); // Join multiple errors with newline
          }
          throw Exception(errorMessage);
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
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Form Tambah Simpanan',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFE30031),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildDropdownFormField(
                value: _selectedKategoriSimpanan,
                hintText: 'Pilih Kategori Simpanan',
                labelText: 'Kategori Simpanan*',
                items: _kategoriSimpananOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedKategoriSimpanan = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Kategori tidak boleh kosong' : null,
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _nominalController,
                decoration: InputDecoration(
                  labelText: 'Nominal (Rp)*',
                  hintText: 'Masukkan jumlah nominal',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nominal tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Masukkan nominal yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _keteranganController,
                decoration: InputDecoration(
                  labelText: 'Keterangan*',
                  hintText: 'Contoh: Setoran simpanan sukarela',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Keterangan tidak boleh kosong';
                  }
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
                    _transferProofImageFile = null;
                  });
                },
                validator: (value) => value == null
                    ? 'Jenis pembayaran tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 20.0),
              if (_selectedJenisPembayaran == 'Manual Transfer') ...[
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
                  validator: (value) => value == null
                      ? 'Rekening tujuan tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 20.0),
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey.shade400, width: 1.0),
                  ),
                  child: _transferProofImageFile == null
                      ? const Center(
                          child: Text(
                            'Belum ada bukti transfer',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(7.5),
                          child: Image.file(
                            _transferProofImageFile!,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                const SizedBox(height: 10.0),
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Unggah Bukti Transfer'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE30031),
                    side: const BorderSide(color: Color(0xFFE30031)),
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 30.0),
              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE30031),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 16.0,
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      isExpanded: true,
    );
  }
}
