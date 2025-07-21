import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:koperasi/core/routes/initial_routes.dart';
import 'package:koperasi/core/utils/local_datasource.dart';
import 'package:koperasi/core/widgets/custom_flushbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'profil_form_page.dart'; // Pastikan path import ini benar

// Model data sederhana untuk informasi pengguna
class UserProfile {
  final String namaLengkap;
  final String email;
  final String nomorTelepon;
  final String alamat;
  final String fotoProfilUrl;

  UserProfile({
    required this.namaLengkap,
    required this.email,
    required this.nomorTelepon,
    required this.alamat,
    required this.fotoProfilUrl,
  });
}

class ProfilPage extends StatefulWidget {
  final String? token; // Parameter token ditambahkan di sini

  const ProfilPage({super.key, required this.token}); // Konstruktor diperbarui

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _userName = 'Pengguna';
  String _userEmail = '';
  String _userPhone = '';
  String _userAddress = '';
  String _userPhotoUrl =
      'https://placehold.co/150x150/A2C579/4F6F52?text=Foto'; // Default photo
  bool _isLoadingUserData = true;
  String? _sessionToken;
  late LocalDatasource _localDatasource;

  final _gantiPasswordFormKey = GlobalKey<FormState>();
  final TextEditingController _passwordLamaController = TextEditingController();
  final TextEditingController _passwordBaruController = TextEditingController();
  final TextEditingController _konfirmasiPasswordBaruController =
      TextEditingController();
  bool _obscurePasswordLama = true;
  bool _obscurePasswordBaru = true;
  bool _obscureKonfirmasiPassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Panggil _initializeLocalDatasourceAndLoadToken() di initState
    // Ini akan memuat token dan kemudian memanggil _fetchUserData()
    _initializeLocalDatasourceAndLoadToken();
  }

  Future<void> _initializeLocalDatasourceAndLoadToken() async {
    // Inisialisasi SharedPreferences dan LocalDatasource
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _localDatasource = LocalDatasourceImpl(prefs);

    // Prioritaskan token dari widget (GoRouter extra)
    _sessionToken = widget.token;
    if (_sessionToken == null) {
      // Jika widget.token null, coba ambil dari LocalDatasource
      _sessionToken = await _localDatasource.getToken();
    }

    if (_sessionToken != null) {
      // Jika token berhasil didapatkan (dari widget atau LocalDatasource), baru fetch data
      _fetchUserData();
    } else {
      // Jika token tetap null, sesi tidak valid
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          CustomFlushbar.showTopFlashbar(
            context,
            'Sesi Anda berakhir. Silakan login kembali.',
            false,
          );
          _logoutUser(showFlushbar: false); // Langsung logout
        });
      }
    }
  }

  Future<void> _fetchUserData() async {
    // Pastikan _sessionToken sudah terisi sebelum request API
    if (_sessionToken == null || _sessionToken!.isEmpty) {
      setState(() {
        _isLoadingUserData = false; // Hentikan loading
        _userName = 'Error';
        _userEmail = 'Tidak ada sesi';
        _userPhotoUrl =
            'https://placehold.co/150x150/FF0000/FFFFFF?text=Error'; // Foto error
      });
      CustomFlushbar.showTopFlashbar(
        context,
        'Token sesi tidak ditemukan. Harap login ulang.',
        false,
      );
      _logoutUser(showFlushbar: false); // Logout paksa
      return; // Hentikan eksekusi lebih lanjut
    }

    setState(() {
      _isLoadingUserData = true;
    });
    const String apiUrl = 'https://api-jatlinko.naditechno.id/api/v1/me';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_sessionToken', // Gunakan _sessionToken
        },
      );

      if (mounted) {
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          print(
            'data user from ProfilePage: $responseData',
          ); // Log untuk debugging
          if (responseData['code'] == 200 && responseData['data'] != null) {
            var userData =
                responseData['data']['anggota'] ?? responseData['data'];
            setState(() {
              _userName = userData['name'] ?? 'Nama Tidak Ditemukan';
              _userEmail = userData['email'] ?? 'Email Tidak Ditemukan';
              _userPhone = userData['phone'] ?? 'Telepon Tidak Ditemukan';
              _userAddress = userData['address'] ?? 'Alamat Tidak Ditemukan';
              _userPhotoUrl =
                  userData['profile_picture'] ??
                  _userPhotoUrl; // Sesuaikan field API
              _isLoadingUserData = false;
            });
          } else {
            CustomFlushbar.showTopFlashbar(
              context,
              responseData['message'] ?? 'Gagal mengambil data profil',
              false,
            );
            _logoutUser();
          }
        } else if (response.statusCode == 401) {
          if (mounted) {
            CustomFlushbar.showTopFlashbar(
              context,
              'Sesi Anda berakhir. Silakan login kembali.',
              false,
            );
            _logoutUser();
          }
        } else {
          CustomFlushbar.showTopFlashbar(
            context,
            'Gagal mengambil data profil (Status: ${response.statusCode})',
            false,
          );
          _logoutUser();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUserData = false;
          _userName = 'Error';
          _userEmail = 'Koneksi gagal';
          _userPhotoUrl =
              'https://placehold.co/150x150/FF0000/FFFFFF?text=Error';
        });
        CustomFlushbar.showTopFlashbar(
          context,
          'Error: Tidak dapat terhubung ke server.',
          false,
        );
        _logoutUser();
      }
    }
  }

  Future<void> _logoutUser({bool showFlushbar = true}) async {
    // Pastikan _localDatasource sudah diinisialisasi
    if (mounted && _localDatasource != null) {
      await _localDatasource.removeToken();
    } else {
      // Fallback jika _localDatasource belum diinisialisasi (jarang terjadi)
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_token');
    }

    _sessionToken = null;

    if (mounted) {
      context.go(InitialRoutes.loginPage);
      if (showFlushbar) {
        CustomFlushbar.showTopFlashbar(context, 'Logout Success', true);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _passwordLamaController.dispose();
    _passwordBaruController.dispose();
    _konfirmasiPasswordBaruController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 220.0,
              floating: false,
              pinned: true,
              elevation: 2.0,
              backgroundColor: const Color(
                0xFFE30031,
              ), // Sesuaikan warna AppBar
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: const EdgeInsets.only(bottom: 50.0),
                title: Text(
                  _isLoadingUserData ? 'Loading...' : _userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 2.0,
                        color: Colors.black38,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      _userPhotoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        size: 100,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.5),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                indicatorWeight: 3.0,
                tabs: const [
                  Tab(icon: Icon(Icons.person_outline), text: 'Data Pribadi'),
                  Tab(icon: Icon(Icons.lock_outline), text: 'Ganti Password'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [_buildDataPribadiTab(), _buildGantiPasswordTab()],
        ),
      ),
    );
  }

  Widget _buildDataPribadiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            Icons.email_outlined,
            'Email',
            _isLoadingUserData ? 'Loading...' : _userEmail,
          ),
          _buildInfoRow(
            Icons.phone_outlined,
            'Nomor Telepon',
            _isLoadingUserData ? 'Loading...' : _userPhone,
          ),
          _buildInfoRow(
            Icons.location_on_outlined,
            'Alamat',
            _isLoadingUserData ? 'Loading...' : _userAddress,
            maxLines: 3,
          ),
          const SizedBox(height: 30.0),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                if (_sessionToken != null) {
                  context.push(
                    '/profile/edit',
                    extra: _sessionToken!,
                  ); // Navigasi dengan GoRouter
                } else {
                  CustomFlushbar.showTopFlashbar(
                    context,
                    'Token tidak tersedia untuk mengedit profil. Silakan login kembali.',
                    false,
                  );
                  context.go(InitialRoutes.loginPage);
                }
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Profil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE30031), // Perbaiki konstanta
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30.0,
                  vertical: 12.0,
                ),
                textStyle: const TextStyle(fontSize: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFFE30031),
            size: 28.0,
          ), // Perbaiki konstanta
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Color(0xFFE30031),
                  ), // Perbaiki konstanta
                ),
                const SizedBox(height: 4.0),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGantiPasswordTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _gantiPasswordFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPasswordTextFormField(
              controller: _passwordLamaController,
              labelText: 'Password Lama*',
              obscureText: _obscurePasswordLama,
              toggleObscure: () {
                setState(() {
                  _obscurePasswordLama = !_obscurePasswordLama;
                });
              },
            ),
            const SizedBox(height: 20.0),
            _buildPasswordTextFormField(
              controller: _passwordBaruController,
              labelText: 'Password Baru*',
              obscureText: _obscurePasswordBaru,
              toggleObscure: () {
                setState(() {
                  _obscurePasswordBaru = !_obscurePasswordBaru;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password baru tidak boleh kosong';
                }
                if (value.length < 6) {
                  return 'Password baru minimal 6 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 20.0),
            _buildPasswordTextFormField(
              controller: _konfirmasiPasswordBaruController,
              labelText: 'Konfirmasi Password Baru*',
              obscureText: _obscureKonfirmasiPassword,
              toggleObscure: () {
                setState(() {
                  _obscureKonfirmasiPassword = !_obscureKonfirmasiPassword;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Konfirmasi password tidak boleh kosong';
                }
                if (value != _passwordBaruController.text) {
                  return 'Konfirmasi password tidak cocok';
                }
                return null;
              },
            ),
            const SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: () {
                if (_gantiPasswordFormKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Password berhasil diubah! (Simulasi)',
                      ),
                      backgroundColor: Colors.teal.shade700,
                    ),
                  );
                  _passwordLamaController.clear();
                  _passwordBaruController.clear();
                  _konfirmasiPasswordBaruController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Harap perbaiki error pada form.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                textStyle: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text('Simpan Password'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordTextFormField({
    required TextEditingController controller,
    required String labelText,
    required bool obscureText,
    required VoidCallback toggleObscure,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.grey,
          ),
          onPressed: toggleObscure,
        ),
      ),
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return '$labelText tidak boleh kosong';
            }
            return null;
          },
    );
  }
}
