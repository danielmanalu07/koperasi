import 'package:flutter/material.dart';
import 'main.dart';   // Asumsi file ini masih ada dan relevan

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Koperasi Modern', // Judul aplikasi bisa lebih umum
      theme: ThemeData(
        primarySwatch: Colors.red, // Warna tema bisa disesuaikan untuk Lupa Password
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Poppins',
      ),
      home: const ForgotPasswordPage(), // Halaman utama sekarang adalah Lupa Password
      debugShowCheckedModeBanner: false,
    );
  }
}



// --- HALAMAN LUPA PASSWORD BARU ---
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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
              colors: [Colors.white, Colors.white], // Warna tema Lupa Password
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
                  Icon(Icons.lock_reset_outlined, size: 80, color: Color(0xFFE30031)), // Icon Lupa Password
                  const SizedBox(height: 16.0),
                  const Text(
                    'Lupa Kata Sandi?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE30031),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  const Text(
                    'Masukkan alamat email Anda yang terdaftar. Kami akan mengirimkan instruksi untuk mengatur ulang kata sandi Anda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Color(0xFFE30031),
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'Alamat Email',
                            prefixIcon: const Icon(Icons.email_outlined, color: Colors.black),
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                            hintStyle: const TextStyle(color: Colors.black),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(color: Colors.white, width: 1.5),
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
                              return 'Mohon masukkan alamat email Anda';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'Masukkan format email yang valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24.0),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFE30031),
                            foregroundColor: Colors.red.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            minimumSize: const Size(double.infinity, 50),
                            elevation: 5,
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Proses kirim instruksi reset password di sini
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Instruksi reset password telah dikirim ke ${_emailController.text} (jika terdaftar).'),
                                  backgroundColor: Color(0xFFE30031),
                                ),
                              );
                              // Anda mungkin ingin kembali ke halaman login atau menampilkan pesan sukses
                            }
                          },
                          child: const Text(
                            'Kirim Instruksi Reset',
                            style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  TextButton(
                    onPressed: () {
                      // Kembali ke halaman login
                      Navigator.pushReplacement( // Mengganti halaman ini dengan LoginPage
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      'Kembali ke Halaman Login',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                    ),
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
