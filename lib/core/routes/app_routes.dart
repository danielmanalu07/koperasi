import 'package:go_router/go_router.dart';
import 'package:koperasi/core/routes/initial_routes.dart';
import 'package:koperasi/core/utils/local_datasource.dart';
import 'package:koperasi/core/widgets/main_app_layout.dart';
import 'package:koperasi/features/notifications/presentation/pages/notification_page.dart';
import 'package:koperasi/main.dart';
import 'package:koperasi/profil_form_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import semua halaman yang akan digunakan di routing
import 'package:koperasi/register_page.dart';
import 'package:koperasi/forgot_password_page.dart';
import 'package:koperasi/home_page.dart';
import 'package:koperasi/core/widgets/ktp_camera_screen.dart';
import 'package:koperasi/features/promo/presentation/pages/promo_page.dart';
import 'package:koperasi/features/riwayat/presentation/pages/riwayat_page.dart';
import 'package:koperasi/profil_page.dart';

// Import halaman yang menjadi sub-routes (muncul di atas Bottom Nav)
import 'package:koperasi/simpanan_page.dart';
import 'package:koperasi/tabungan_page.dart';
import 'package:koperasi/pinjaman_page.dart';
import 'package:koperasi/pulsa_data_form_page.dart';
import 'package:koperasi/paket_data_form_page.dart';
import 'package:koperasi/token_listrik_form_page.dart';
import 'package:koperasi/bayar_listrik_form_page.dart';
import 'package:koperasi/bayar_pdam_form_page.dart';
import 'package:koperasi/info_detail_page.dart';

final GoRouter appRoute = GoRouter(
  initialLocation:
      InitialRoutes.loginPage, // Tetap di LoginPage sebagai initial
  debugLogDiagnostics: true,

  redirect: (context, state) async {
    final String currentPath = state.matchedLocation;

    final sharedPreferences = await SharedPreferences.getInstance();
    final localdataSource = LocalDatasourceImpl(sharedPreferences);
    final token = await localdataSource
        .getToken(); // Dapatkan token secara async

    final isLoggedIn = token != null && token.isNotEmpty;

    // --- Logika Redirect ---

    // Skenario 1: Pengguna sudah login, dan mencoba mengakses halaman autentikasi.
    if (isLoggedIn &&
        (currentPath == InitialRoutes.loginPage ||
            currentPath == InitialRoutes.registerPage ||
            currentPath == InitialRoutes.forgotPasswordPage)) {
      return InitialRoutes.homePage; // Cukup kembalikan path ke HomePage
    }

    // Skenario 2: Pengguna tidak login, dan mencoba mengakses halaman yang memerlukan login.
    final bool isProtectedPath =
        currentPath.startsWith(
          InitialRoutes.homePage,
        ) || // Mencakup /home dan sub-rutanya
        currentPath == InitialRoutes.promo ||
        currentPath == InitialRoutes.riwayat ||
        currentPath == InitialRoutes.profile ||
        currentPath == InitialRoutes.ktpcameraScreen;
    // Tidak perlu list panjang sub-routes jika startsWith('/home') sudah mencakup

    if (!isLoggedIn && isProtectedPath) {
      await localdataSource.removeToken();
      return InitialRoutes.loginPage; // Redirect ke halaman login
    }

    // Jika tidak ada kondisi redirect yang terpenuhi, biarkan GoRouter melanjutkan
    return null;
  },
  routes: [
    // Rute Top-Level yang tidak memiliki BottomNavigationBar
    GoRoute(
      path: InitialRoutes.loginPage,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: InitialRoutes.registerPage,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: InitialRoutes.forgotPasswordPage,
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: InitialRoutes.ktpcameraScreen,
      builder: (context, state) => const KtpCameraScreen(),
    ),
    GoRoute(
      path: InitialRoutes.notification,
      builder: (context, state) => const NotificationPage(),
    ),

    // ShellRoute: Untuk halaman-halaman dengan BottomNavigationBar
    ShellRoute(
      builder: (context, state, child) {
        return MainAppLayout(child: child, currentPath: state.matchedLocation);
      },
      routes: [
        GoRoute(
          path: InitialRoutes.homePage,
          name: InitialRoutes.homePage.substring(1),
          builder: (context, state) {
            final token = state.extra as String?;
            return HomePage(token: token);
          },
          routes: [
            GoRoute(
              path: InitialRoutes.simpanan,
              builder: (context, state) {
                final token = state.extra as String?;
                return SimpananPage(token: token);
              },
            ),
            GoRoute(
              path: InitialRoutes.tabungan,
              builder: (context, state) {
                final token = state.extra as String?;
                return TabunganPage(token: token);
              },
            ),
            GoRoute(
              path: InitialRoutes.pinjaman,
              builder: (context, state) {
                final token = state.extra as String?;
                return PinjamanPage(token: token);
              },
            ),
            GoRoute(
              path: InitialRoutes.pulsaDataForm,
              builder: (context, state) => const PulsaDataFormPage(),
            ),
            GoRoute(
              path: InitialRoutes.paketDataForm,
              builder: (context, state) => const PaketDataFormPage(),
            ),
            GoRoute(
              path: InitialRoutes.tokenListrikForm,
              builder: (context, state) => const TokenListrikFormPage(),
            ),
            GoRoute(
              path: InitialRoutes.bayarPDAMForm,
              builder: (context, state) => const BayarPdamFormPage(),
            ),
            GoRoute(
              path: InitialRoutes.bayarListrikForm,
              builder: (context, state) => const BayarListrikFormPage(),
            ),
            GoRoute(
              path: InitialRoutes.infoDetail,
              builder: (context, state) {
                final Map<String, String>? extraData =
                    state.extra as Map<String, String>?;
                return InfoDetailPage(
                  imageUrl: extraData?['image'] ?? '',
                  title: extraData?['title'] ?? '',
                  description: extraData?['description'] ?? '',
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: InitialRoutes.promo,
          name: InitialRoutes.promo.substring(1), // Nama rute: 'promo'
          builder: (context, state) => const PromoPage(),
        ),
        GoRoute(
          path: InitialRoutes.riwayat,
          name: InitialRoutes.riwayat.substring(1), // Nama rute: 'riwayat'
          builder: (context, state) => const RiwayatPage(),
        ),
        GoRoute(
          path: InitialRoutes.profile,
          name: InitialRoutes.profile.substring(1), // Nama rute: 'profile'
          builder: (context, state) {
            final token = state.extra as String?;
            return ProfilPage(token: token);
          },
        ),
        GoRoute(
          path: InitialRoutes.profileEdit,
          name: InitialRoutes.profileEdit.substring(1), // Nama rute: 'profile'
          builder: (context, state) {
            final token = state.extra as String?;
            return ProfilFormPage(token: token!);
          },
        ),
      ],
    ),
  ],
);
