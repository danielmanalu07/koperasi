// lib/core/routes/initial_routes.dart
class InitialRoutes {
  InitialRoutes._(); // Pastikan constructor private

  // Rute Top-Level yang memiliki '/' di awal
  static const String splashScreen = '/'; // Ini adalah rute awal aplikasi
  static const String loginPage = '/login'; // Ubah dari /login_page
  static const String registerPage = '/register'; // Ubah dari /register_page
  static const String forgotPasswordPage =
      '/forgot-password'; // Ubah dari /forgot_password_page
  static const String ktpcameraScreen = '/ktp-screen'; // Ubah dari /ktp_screen

  static const String notification = '/notification';
  // Rute untuk TAB di Bottom Navigation Bar
  static const String homePage = '/home'; // Ubah dari /home_page
  static const String promo = '/promo';
  static const String riwayat = '/riwayat';
  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';

  static const String simpanan = 'simpanan';
  static const String tabungan = 'tabungan';
  static const String pinjaman = 'pinjaman';
  static const String pulsaDataForm = 'pulsa-data-form';
  static const String paketDataForm = 'paket-data-form';
  static const String tokenListrikForm = 'token-listrik-form';
  static const String bayarListrikForm = 'bayar-listrik-form';
  static const String bayarPDAMForm = 'bayar-pdam-form';
  static const String infoDetail = 'info-detail';
}
