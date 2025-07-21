import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:koperasi/core/widgets/ktp_camera_screen.dart';

// Model untuk Cabang
class Cabang {
  final int id;
  final String name;

  Cabang({required this.id, required this.name});

  factory Cabang.fromJson(Map<String, dynamic> json) {
    return Cabang(id: json['id'] as int, name: json['name'] as String);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cabang && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  File? _ktpImageFile;

  Cabang? _selectedCabang;
  List<Cabang> _cabangOptions = [];
  bool _isLoadingCabang = true;

  bool _obscureTextPassword = true;
  bool _obscureTextConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    _fetchCabang();
  }

  Future<void> _fetchCabang() async {
    setState(() {
      _isLoadingCabang = true;
    });
    try {
      final response = await http.get(
        Uri.parse(
          'https://api-jatlinko.naditechno.id/api/v1/master/guest/cabang/level/2',
        ),
        headers: {'Accept': 'application/json'},
      );

      if (mounted) {
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData['code'] == 200 &&
              responseData['data'] != null &&
              responseData['data']['data'] is List) {
            List<dynamic> cabangListJson = responseData['data']['data'];
            setState(() {
              _cabangOptions = cabangListJson
                  .map((json) => Cabang.fromJson(json))
                  .toList();
              // Removed: _selectedCabang = _cabangOptions.first;
              // This ensures the hint text is displayed initially.
              _isLoadingCabang = false;
            });
          } else {
            throw Exception('Format data cabang tidak sesuai');
          }
        } else {
          throw Exception(
            'Gagal memuat data cabang (Status: ${response.statusCode})',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCabang = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error memuat cabang: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    final File? pickedFile = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const KtpCameraScreen()),
    );

    if (pickedFile != null) {
      setState(() {
        _ktpImageFile = pickedFile;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada gambar yang diambil.')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: const Text(
            'Syarat & Ketentuan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const SingleChildScrollView(
            child: Text(
              'Ini adalah detail Syarat & Ketentuan penggunaan aplikasi Koperasi Modern. \n\n'
              '1. Pengguna setuju untuk memberikan data yang akurat dan valid saat pendaftaran.\n'
              '2. Pengguna bertanggung jawab penuh atas kerahasiaan akun dan kata sandi.\n'
              '3. Aplikasi ini ditujukan untuk anggota koperasi yang terdaftar.\n'
              '4. Segala bentuk penyalahgunaan akan ditindak sesuai kebijakan yang berlaku.\n'
              '5. Kebijakan Privasi: Kami menghargai privasi Anda. Data pribadi Anda akan digunakan sesuai dengan kebutuhan layanan aplikasi dan tidak akan dibagikan kepada pihak ketiga tanpa persetujuan Anda, kecuali diwajibkan oleh hukum.\n'
              '6. Dengan mencentang kotak persetujuan, Anda dianggap telah membaca, memahami, dan menyetujui seluruh syarat dan ketentuan ini.',
              style: TextStyle(fontSize: 14.0),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Tutup',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi semua field yang wajib diisi.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Anda harus menyetujui Syarat & Ketentuan untuk mendaftar.',
          ),
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

    setState(() {
      _isLoading = true;
    });

    const String apiUrl = 'https://api-jatlinko.naditechno.id/api/v1/register';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "anggota_category_id": "",
          "cabang_id": _selectedCabang?.id.toString() ?? "",
          "name": _nameController.text,
          "email": _emailController.text,
          "password": _passwordController.text,
          "password_confirmation": _confirmPasswordController.text,
          "phone": _phoneController.text,
          "address": _addressController.text,
        }),
      );

      if (mounted) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 201 || response.statusCode == 200) {
          if (responseData['code'] == 200 || responseData['code'] == 201) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  responseData['message'] ??
                      'Pendaftaran berhasil! Silakan login.',
                ),
                backgroundColor: Colors.green.shade700,
              ),
            );
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  responseData['message'] ?? 'Pendaftaran gagal. Coba lagi.',
                ),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
        } else {
          String errorMessage =
              'Pendaftaran gagal (Code: ${response.statusCode}).';
          if (responseData['message'] != null) {
            errorMessage = responseData['message'];
          } else if (responseData['errors'] != null &&
              responseData['errors'] is Map) {
            Map<String, dynamic> errors = responseData['errors'];
            if (errors.isNotEmpty) {
              errorMessage =
                  errors.values.first[0] ?? 'Terjadi kesalahan validasi.';
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: screenSize.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 40.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text(
                    'Buat Akun Baru',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'Isi data diri Anda untuk mendaftar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.0, color: Colors.black),
                  ),
                  const SizedBox(height: 30.0),

                  _buildTextFormField(
                    controller: _nameController,
                    hintText: 'Nama Lengkap',
                    prefixIcon: Icons.person_outline,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Nama lengkap tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 16.0),
                  _buildTextFormField(
                    controller: _emailController,
                    hintText: 'Email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Email tidak boleh kosong';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value))
                        return 'Format email tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  _buildTextFormField(
                    controller: _phoneController,
                    hintText: 'Nomor WhatsApp',
                    prefixIcon: Icons.phone_iphone_outlined,
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
                  const SizedBox(height: 16.0),
                  _buildTextFormField(
                    controller: _addressController,
                    hintText: 'Alamat Lengkap',
                    prefixIcon: Icons.home_outlined,
                    maxLines: 2,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Alamat tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 16.0),

                  // --- Menggunakan DropdownMenu untuk pilihan Cabang ---
                  _isLoadingCabang
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          ),
                        )
                      : DropdownMenu<Cabang>(
                          initialSelection: _selectedCabang,
                          hintText:
                              'Pilih Cabang Koperasi', // This will now show
                          leadingIcon: const Icon(
                            Icons.store_mall_directory_outlined,
                            color: Colors.black,
                          ),
                          width:
                              screenSize.width -
                              48, // Adjust width based on padding
                          inputDecorationTheme: InputDecorationTheme(
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                            hintStyle: const TextStyle(color: Colors.black),
                            errorStyle: const TextStyle(
                              color: Colors
                                  .redAccent, // Adjusted for better visibility against white
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          textStyle: const TextStyle(
                            color: Colors.black,
                          ), // Style for selected text
                          dropdownMenuEntries: _cabangOptions
                              .map<DropdownMenuEntry<Cabang>>((Cabang cabang) {
                                return DropdownMenuEntry<Cabang>(
                                  value: cabang,
                                  label: cabang.name,
                                  style: MenuItemButton.styleFrom(
                                    textStyle: const TextStyle(
                                      color: Colors.black,
                                    ), // Style for dropdown items
                                  ),
                                );
                              })
                              .toList(),
                          onSelected: (Cabang? value) {
                            setState(() {
                              _selectedCabang = value;
                            });
                          },
                          // You'll need a way to validate DropdownMenu if it's required.
                          // Consider using a separate validator function or wrapping it in FormField.
                        ),
                  const SizedBox(height: 16.0),

                  _buildTextFormField(
                    controller: _passwordController,
                    hintText: 'Kata Sandi',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureTextPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureTextPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.black,
                      ),
                      onPressed: () => setState(
                        () => _obscureTextPassword = !_obscureTextPassword,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Kata sandi tidak boleh kosong';
                      if (value.length < 6)
                        return 'Kata sandi minimal 6 karakter';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  _buildTextFormField(
                    controller: _confirmPasswordController,
                    hintText: 'Konfirmasi Kata Sandi',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureTextConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureTextConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.black,
                      ),
                      onPressed: () => setState(
                        () => _obscureTextConfirmPassword =
                            !_obscureTextConfirmPassword,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Konfirmasi kata sandi tidak boleh kosong';
                      if (value != _passwordController.text)
                        return 'Kata sandi tidak cocok';
                      return null;
                    },
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
                              'Belum ada gambar KTP',
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
                    label: const Text('Ambil Foto KTP'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE30031),
                      side: const BorderSide(
                        color: Color(0xFFE30031),
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: (bool? value) =>
                            setState(() => _agreeToTerms = value ?? false),
                        checkColor: Colors.green.shade700,
                        activeColor: Colors.black,
                        side: const BorderSide(color: Colors.black),
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: 'Saya menyetujui ',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Syarat & Ketentuan',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  fontFamily: 'Poppins',
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = _showTermsAndConditions,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.black),
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE30031),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            textStyle: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            minimumSize: const Size(double.infinity, 50),
                            elevation: 5,
                          ),
                          onPressed: _registerUser,
                          child: const Text(
                            'Daftar Sekarang',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sudah punya akun?',
                        style: TextStyle(color: Colors.black),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Masuk Sekarang',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(prefixIcon, color: Colors.black),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.black.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: Colors.black),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.black, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      errorStyle: const TextStyle(
        color: Colors.redAccent, // Adjusted for better visibility
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
    int? maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
      style: const TextStyle(color: Colors.black),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
    );
  }
}
