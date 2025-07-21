import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // Untuk DatePicker dan format tanggal
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // Import untuk File
import 'package:image_picker/image_picker.dart';
import 'package:koperasi/core/widgets/ktp_camera_screen.dart';

class ProfilFormPage extends StatefulWidget {
  final String token;

  const ProfilFormPage({super.key, required this.token});

  @override
  State<ProfilFormPage> createState() => _ProfilFormPageState();
}

class _ProfilFormPageState extends State<ProfilFormPage> {
  final _formKey = GlobalKey<FormState>();

  // State untuk loading
  bool _isLoadingData = true;
  bool _isSaving = false;

  // State untuk menyimpan ID
  int? _anggotaId;
  int? _cabangId; // Diambil dari data user, bukan dropdown

  // Controllers untuk setiap field
  final TextEditingController _namaLengkapController = TextEditingController();
  final TextEditingController _tempatLahirController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _alamatLengkapController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nomorWhatsappController =
      TextEditingController();
  final TextEditingController _pekerjaanController = TextEditingController();
  final TextEditingController _nomorKtpController = TextEditingController();

  String? _selectedJenisKelamin;
  final List<String> _jenisKelaminOptions = ['Laki-laki', 'Perempuan'];

  String? _selectedStatusMenikah;
  final List<String> _statusMenikahOptions = [
    'Belum Menikah',
    'Menikah',
    'Cerai Hidup',
    'Cerai Mati',
  ];

  DateTime? _selectedDate;
  File? _ktpImageFile;

  @override
  void initState() {
    super.initState();
    _fetchAndPopulateUserData();
  }

  Future<void> _fetchAndPopulateUserData() async {
    setState(() => _isLoadingData = true);
    const String apiUrl = 'https://api-jatlinko.naditechno.id/api/v1/me';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (mounted) {
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData['code'] == 200 && responseData['data'] != null) {
            var userData = responseData['data'];
            // Jika data anggota ada di dalam objek 'anggota', gunakan itu.
            var anggotaData = userData['anggota'] ?? userData;

            setState(() {
              _anggotaId = anggotaData['id'];
              _cabangId = anggotaData['cabang_id'];

              _namaLengkapController.text = anggotaData['name'] ?? '';
              _emailController.text = anggotaData['email'] ?? '';
              _nomorWhatsappController.text = anggotaData['phone'] ?? '';
              _alamatLengkapController.text = anggotaData['address'] ?? '';
              _nomorKtpController.text = anggotaData['nik'] ?? '';
              _tempatLahirController.text = anggotaData['birth_place'] ?? '';
              _tanggalLahirController.text = anggotaData['birth_date'] != null
                  ? DateFormat(
                      'dd MMMM yyyy',
                      'id_ID',
                    ).format(DateTime.parse(anggotaData['birth_date']))
                  : '';
              if (anggotaData['birth_date'] != null) {
                _selectedDate = DateTime.parse(anggotaData['birth_date']);
              }
              _pekerjaanController.text = anggotaData['job'] ?? '';
              _selectedJenisKelamin = anggotaData['gender'];
              _selectedStatusMenikah = anggotaData['marital_status'];
            });
          } else {
            throw Exception('Format data tidak valid');
          }
        } else {
          throw Exception('Gagal memuat data profil');
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
        setState(() => _isLoadingData = false);
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    // Gunakan ImageSource.camera untuk memastikan hanya kamera yang terbuka
    // final XFile? pickedFile = await picker.pickImage(
    //   source: ImageSource.camera,
    //   imageQuality: 80, // Kompresi kualitas gambar untuk mengurangi ukuran
    // );
    final File? pickedFile = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const KtpCameraScreen()),
    );

    if (pickedFile != null) {
      setState(() {
        _ktpImageFile = File(pickedFile.path);
      });
    } else {
      // Pengguna mungkin membatalkan pengambilan gambar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada gambar yang diambil.')),
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_anggotaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID Anggota tidak ditemukan, tidak dapat menyimpan.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_ktpImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap unggah foto KTP Anda.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final String apiUrl =
        'https://api-jatlinko.naditechno.id/api/v1/anggota/$_anggotaId';

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          // Data yang dikirimkan sesuai contoh, beberapa diambil dari form
          "anggota_category_id": "1", // Hardcoded sesuai contoh
          "cabang_id":
              _cabangId ??
              1, // Gunakan ID cabang dari data user, atau fallback ke 1
          "name": _namaLengkapController.text,
          "email": _emailController.text,
          "phone": _nomorWhatsappController.text,
          "address": _alamatLengkapController.text,
          "status": 1, // Hardcoded sesuai contoh
          // Field lain dari form
          "nik": _nomorKtpController.text,
          "birth_place": _tempatLahirController.text,
          "birth_date": _selectedDate != null
              ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
              : null,
          "gender": _selectedJenisKelamin,
          "marital_status": _selectedStatusMenikah,
          "job": _pekerjaanController.text,
        }),
      );

      if (mounted) {
        final responseData = jsonDecode(response.body);
        if (response.statusCode == 200 && responseData['code'] == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                responseData['message'] ?? 'Profil berhasil diperbarui!',
              ),
              backgroundColor: Colors.teal.shade700,
            ),
          );
          Navigator.pop(context, true); // Kembali & kirim sinyal untuk refresh
        } else {
          String errorMessage =
              responseData['message'] ?? 'Gagal menyimpan profil.';
          if (responseData['errors'] != null) {
            errorMessage = responseData['errors'].values.first[0];
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
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
  void dispose() {
    _namaLengkapController.dispose();
    _tempatLahirController.dispose();
    _tanggalLahirController.dispose();
    _alamatLengkapController.dispose();
    _emailController.dispose();
    _nomorWhatsappController.dispose();
    _pekerjaanController.dispose();
    _nomorKtpController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _tanggalLahirController.text = DateFormat(
          'dd MMMM yyyy',
          'id_ID',
        ).format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFE30031),
        elevation: 1,
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _buildTextFormField(
                      controller: _namaLengkapController,
                      labelText: 'Nama Lengkap*',
                      icon: Icons.person_outline,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Nama lengkap tidak boleh kosong'
                          : null,
                    ),
                    _buildTextFormField(
                      controller: _tempatLahirController,
                      labelText: 'Tempat Lahir',
                      icon: Icons.location_city_outlined,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: TextFormField(
                        controller: _tanggalLahirController,
                        decoration: _inputDecoration(
                          labelText: 'Tanggal Lahir*',
                          hintText: 'Pilih tanggal lahir',
                          icon: Icons.calendar_today_outlined,
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Tanggal lahir tidak boleh kosong'
                            : null,
                      ),
                    ),
                    _buildDropdownFormField(
                      value: _selectedJenisKelamin,
                      labelText: 'Jenis Kelamin*',
                      icon: Icons.wc_outlined,
                      items: _jenisKelaminOptions,
                      onChanged: (value) {
                        setState(() {
                          _selectedJenisKelamin = value;
                        });
                      },
                      validator: (value) => value == null
                          ? 'Jenis kelamin tidak boleh kosong'
                          : null,
                    ),
                    _buildTextFormField(
                      controller: _alamatLengkapController,
                      labelText: 'Alamat Lengkap*',
                      icon: Icons.home_outlined,
                      maxLines: 3,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Alamat tidak boleh kosong'
                          : null,
                    ),
                    _buildDropdownFormField(
                      value: _selectedStatusMenikah,
                      labelText: 'Status Menikah*',
                      icon: Icons.family_restroom_outlined,
                      items: _statusMenikahOptions,
                      onChanged: (value) {
                        setState(() {
                          _selectedStatusMenikah = value;
                        });
                      },
                      validator: (value) => value == null
                          ? 'Status menikah tidak boleh kosong'
                          : null,
                    ),
                    _buildTextFormField(
                      controller: _emailController,
                      labelText: 'Email*',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Email tidak boleh kosong';
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value))
                          return 'Format email tidak valid';
                        return null;
                      },
                    ),
                    _buildTextFormField(
                      controller: _nomorWhatsappController,
                      labelText: 'Nomor WhatsApp*',
                      icon: Icons.phone_android_outlined,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Nomor WhatsApp tidak boleh kosong';
                        if (value.length < 10 || value.length > 15)
                          return 'Nomor WhatsApp tidak valid';
                        return null;
                      },
                    ),
                    _buildTextFormField(
                      controller: _pekerjaanController,
                      labelText: 'Pekerjaan',
                      icon: Icons.work_outline,
                    ),
                    _buildTextFormField(
                      controller: _nomorKtpController,
                      labelText: 'Nomor KTP (NIK)',
                      hintText: 'Masukkan 16 digit Nomor KTP',
                      icon: Icons.badge_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                      ],
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            value.length != 16)
                          return 'Nomor KTP harus 16 digit';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20.0),
                    Text(
                      'Foto KTP*',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: Colors.grey.shade400,
                          width: 1.5,
                        ),
                      ),
                      child: _ktpImageFile == null
                          ? const Center(
                              child: Text(
                                'Belum ada gambar',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(8.5),
                              child: Image.file(
                                _ktpImageFile!,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                    const SizedBox(height: 10.0),
                    OutlinedButton.icon(
                      onPressed: _pickImageFromCamera,
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Buka Kamera'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFFE30031),
                        side: BorderSide(color: Color(0xFFE30031), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    _isSaving
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                            onPressed: _submitForm,
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('Simpan Perubahan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFE30031),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  InputDecoration _inputDecoration({
    required String labelText,
    String? hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icon(icon, color: Colors.black),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      filled: true,
      fillColor: Colors.black.withOpacity(0.1),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        decoration: _inputDecoration(
          labelText: labelText,
          hintText: hintText,
          icon: icon,
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
      ),
    );
  }

  Widget _buildDropdownFormField({
    required String? value,
    required String labelText,
    String? hintText,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: _inputDecoration(
          labelText: labelText,
          hintText: hintText,
          icon: icon,
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(value: item, child: Text(item));
        }).toList(),
        onChanged: onChanged,
        validator: validator,
        isExpanded: true,
      ),
    );
  }
}
