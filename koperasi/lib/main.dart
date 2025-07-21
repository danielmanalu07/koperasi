import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:koperasi/core/routes/app_routes.dart';
import 'package:koperasi/core/routes/initial_routes.dart';
import 'package:koperasi/core/utils/local_dataSource.dart';
import 'package:koperasi/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:koperasi/features/notifications/presentation/bloc/notification_event.dart';
import 'package:koperasi/features/riwayat_pembayaran/presentation/bloc/bayar_tagihan/bayar_tagihan_bloc.dart';
import 'package:koperasi/features/riwayat_pembayaran/presentation/bloc/bayar_tagihan/bayar_tagihan_event.dart';
import 'package:koperasi/features/riwayat_pembayaran/presentation/bloc/pinjaman_remaining/pinjaman_remaining_bloc.dart';
import 'package:koperasi/features/riwayat_pembayaran/presentation/bloc/pinjaman_remaining/pinjaman_remaining_event.dart';
import 'package:koperasi/features/riwayat_pembayaran/presentation/bloc/riwayat_pembayaran_bloc.dart';
import 'package:koperasi/features/riwayat_pembayaran/presentation/bloc/riwayat_pembayaran_event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'register_page.dart';
import 'forgot_password_page.dart';

import 'core/injection_container.dart' as di;

// --- MODIFIKASI FUNGSI main() ---
void main() async {
  // Pastikan semua binding Flutter siap sebelum menjalankan kode async
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  di.init();

  // Dapatkan instance SharedPreferences
  // final SharedPreferences prefs = await SharedPreferences.getInstance();
  // // Coba ambil token dari penyimpanan lokal
  // final String? token = prefs.getString('user_token');

  // Jalankan aplikasi dengan token awal (bisa null)
  runApp(MyApp());
}
// --- AKHIR MODIFIKASI ---

class MyApp extends StatelessWidget {
  // final String? initialToken; // Tambahkan parameter untuk token awal

  const MyApp({super.key});

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     title: 'Koperasi Modern',
  //     theme: ThemeData(
  //       primarySwatch: Colors.red,
  //       visualDensity: VisualDensity.adaptivePlatformDensity,
  //       fontFamily: 'Poppins',
  //     ),
  //     localizationsDelegates: const [
  //       GlobalMaterialLocalizations.delegate,
  //       GlobalWidgetsLocalizations.delegate,
  //       GlobalCupertinoLocalizations.delegate,
  //     ],
  //     supportedLocales: const [Locale('id', 'ID')],
  //     locale: const Locale('id', 'ID'),

  //     // --- Logika Halaman Awal Berdasarkan Token ---
  //     // Jika token ada dan tidak kosong, langsung ke HomePage.
  //     // Jika tidak, tampilkan LoginPage.
  //     home: initialToken != null && initialToken!.isNotEmpty
  //         ? HomePage(token: initialToken!)
  //         : const LoginPage(),
  //     // --- Akhir Logika Halaman Awal ---

  //     // Definisikan named routes untuk navigasi yang lebih bersih
  //     routes: {
  //       '/login': (context) => const LoginPage(),
  //       // Anda bisa menambahkan route lain di sini jika diperlukan
  //     },
  //     debugShowCheckedModeBanner: false,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RiwayatPembayaranBloc>(
          create: (_) =>
              di.sl<RiwayatPembayaranBloc>()..add(GetRiwayatPembayaranEvent()),
        ),
        BlocProvider<BayarTagihanBloc>(
          create: (_) => di.sl<BayarTagihanBloc>(),
        ),
        BlocProvider<PinjamanRemainingBloc>(
          create: (_) =>
              di.sl<PinjamanRemainingBloc>()..add(GetPinjamanRemainingEvent()),
        ),
        BlocProvider<NotificationBloc>(
          create: (_) => di.sl<NotificationBloc>()..add(GetNotificationEvent()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Koperasi Modern',
        theme: ThemeData(
          primarySwatch: Colors.red,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Poppins',
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('id', 'ID')],
        locale: const Locale('id', 'ID'),
        debugShowCheckedModeBanner: false,
        routerConfig: appRoute,
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final String email = _emailController.text;
      final String password = _passwordController.text;
      const String apiUrl = 'https://api-jatlinko.naditechno.id/api/v1/login';

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
          },
          body: jsonEncode(<String, String>{
            'email': email,
            'password': password,
          }),
        );

        if (mounted) {
          final responseData = jsonDecode(response.body);
          setState(() {
            _isLoading = false;
          });

          if (response.statusCode == 200 &&
              responseData['code'] == 200 &&
              responseData['data']?['token'] != null) {
            final String token = responseData['data']['token'];

            // Simpan token menggunakan SharedPreferences
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            final LocalDatasource localDatasource = LocalDatasourceImpl(prefs);
            await localDatasource.setToken(token);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login Berhasil! Mengarahkan ke Home...'),
                backgroundColor: Colors.red,
              ),
            );
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(builder: (context) => HomePage(token: token)),
            // );
            if (mounted) {
              context.go(InitialRoutes.homePage, extra: token);
            }
          } else {
            String errorMessage =
                responseData['message'] ??
                'Login gagal. Periksa kembali email dan password Anda.';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Color(0xFFE30031),
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
              content: Text('Tidak dapat terhubung ke server: ${e.toString()}'),
              backgroundColor: Color(0xFFE30031),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: screenSize.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Image.asset('assets/images/logo.jpg', height: 160),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Selamat Datang!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'Masuk untuk melanjutkan ke aplikasi Koperasi Anda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.0, color: Colors.black),
                  ),
                  const SizedBox(height: 40.0),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'Email atau Nomor Anggota',
                            prefixIcon: const Icon(
                              Icons.person,
                              color: Colors.black,
                            ),
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                            hintStyle: const TextStyle(color: Colors.black),
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
                          ),
                          style: const TextStyle(color: Colors.black),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Mohon masukkan email atau nomor anggota Anda';
                            }
                            if (!value.contains('@')) {
                              return 'Masukkan format email yang valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            hintText: 'Kata Sandi',
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Colors.black,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                            hintStyle: const TextStyle(color: Colors.black),
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
                          ),
                          style: const TextStyle(color: Colors.black),
                          obscureText: _obscureText,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Mohon masukkan kata sandi Anda';
                            }
                            if (value.length < 6) {
                              return 'Kata sandi minimal 6 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24.0),
                        _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFE30031),
                                  foregroundColor: Colors.red.shade700,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  minimumSize: const Size(double.infinity, 50),
                                  elevation: 5,
                                ),
                                onPressed: _loginUser,
                                child: const Text(
                                  'Masuk',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Lupa Kata Sandi?',
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Belum punya akun?',
                        style: TextStyle(color: Colors.black),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Daftar Sekarang',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
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
}
