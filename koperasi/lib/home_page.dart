import 'package:flutter/material.dart' hide CarouselController;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:koperasi/core/routes/initial_routes.dart';
import 'package:koperasi/core/utils/local_dataSource.dart';
import 'package:koperasi/core/widgets/custom_flushbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import flutter_bloc
import 'package:koperasi/features/notifications/presentation/bloc/notification_bloc.dart'; // Import NotificationBloc
import 'package:koperasi/features/notifications/presentation/bloc/notification_state.dart'; // Import NotificationState
import 'package:koperasi/features/notifications/presentation/bloc/notification_event.dart'; // Import NotificationEvent
import 'package:koperasi/core/constants/color_constant.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Assuming ColorConstant is defined here

class HomePage extends StatefulWidget {
  final String? token; // Token yang mungkin berasal dari GoRouter extra

  const HomePage({super.key, required this.token});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, String>> imgList = [
    {
      "image": 'assets/images/promo-1.webp',
      "title": "Promo Spesial Awal Bulan",
      "description":
          "Nikmati diskon hingga 20% untuk semua pengajuan pinjaman di awal bulan ini. Syarat dan ketentuan berlaku. Hubungi customer service kami untuk informasi lebih lanjut dan jangan lewatkan kesempatan emas ini!",
    },
    {
      "image": 'assets/images/promo-1.webp',
      "title": "Layanan Tabungan Pendidikan",
      "description":
          "Rencanakan masa depan pendidikan anak Anda bersama kami. Dengan bunga yang kompetitif dan persyaratan yang mudah, kami siap membantu mewujudkan impian pendidikan terbaik untuk buah hati Anda.",
    },
    {
      "image": 'assets/images/promo-1.webp',
      "title": "Tips Cerdas Mengelola Keuangan",
      "description":
          "Ikuti seminar online gratis bersama ahli keuangan dari Koperasi Jacklinko. Pelajari cara cerdas mengelola keuangan pribadi dan keluarga Anda. Acara akan diadakan pada hari Sabtu, jam 10:00 WIB. Daftar sekarang!",
    },
  ];

  int _currentPage = 0;
  late PageController _pageController;
  bool _isDateFormatterInitialized = false;

  String _userName = 'Pengguna';
  String _userEmail = '';
  String _userPhotoUrl =
      'https://hips.hearstapps.com/hmg-prod/images/cristiano-ronaldo-of-portugal-during-the-uefa-nations-news-photo-1748359673.pjpeg?crop=0.610xw:0.917xh;0.317xw,0.0829xh&resize=640:*';
  bool _isLoadingUserData = true;
  String? _sessionToken; // Token yang akan digunakan setelah load
  late LocalDatasource _localDatasource; // Inisialisasi LocalDatasource

  // State untuk jumlah notifikasi belum dibaca
  int _unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 0.85);
    _initializeDateFormatter();
    _initializeLocalDatasourceAndLoadToken(); // Panggil fungsi baru
  }

  Future<void> _initializeLocalDatasourceAndLoadToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _localDatasource = LocalDatasourceImpl(prefs); // Inisialisasi di sini

    // Prioritaskan token dari widget (jika dikirim oleh GoRouter extra)
    // Jika null, coba ambil dari LocalDatasource
    _sessionToken = widget.token;
    if (_sessionToken == null) {
      _sessionToken = await _localDatasource
          .getToken(); // Gunakan getToken dari LocalDatasource
    }

    if (_sessionToken != null) {
      _fetchUserData();
      // Dispatch event to load notifications immediately after token is available
      context.read<NotificationBloc>().add(GetNotificationEvent());
    } else {
      // Jika setelah mencoba semua, token masih null, berarti sesi tidak valid
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomFlushbar.showTopFlashbar(
          context,
          'Sesi Anda berakhir. Silakan login kembali.',
          false,
        );
        _logoutUser(showFlushbar: false); // Jangan tampilkan flushbar lagi
      });
    }
  }

  Future<void> _initializeDateFormatter() async {
    try {
      await initializeDateFormatting('id_ID', null);
      if (mounted) {
        setState(() {
          _isDateFormatterInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDateFormatterInitialized = true;
        });
      }
    }
  }

  Future<void> _fetchUserData() async {
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
          'Authorization':
              'Bearer ${_sessionToken ?? ''}', // Gunakan _sessionToken
        },
      );

      if (mounted) {
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData['code'] == 200 && responseData['data'] != null) {
            setState(() {
              _userName = responseData['data']['name'] ?? 'Pengguna';
              _userEmail = responseData['data']['email'] ?? '';
              _isLoadingUserData = false;
            });
            print("respon json : ${responseData['data']}");
          } else {
            CustomFlushbar.showTopFlashbar(
              context,
              responseData['message'] ?? 'Gagal mengambil data pengguna',
              false,
            );
            _logoutUser(showFlushbar: false);
          }
        } else if (response.statusCode == 401) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            CustomFlushbar.showTopFlashbar(
              context,
              'Sesi Anda berakhir. Silakan login kembali.',
              false,
            );
            _logoutUser(showFlushbar: false);
          });
        } else {
          CustomFlushbar.showTopFlashbar(
            context,
            'Gagal mengambil data pengguna (Status: ${response.statusCode})',
            false,
          );
          _logoutUser(showFlushbar: false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUserData = false;
        });
        CustomFlushbar.showTopFlashbar(
          context,
          'Error: Tidak dapat terhubung ke server.',
          false,
        );
        _logoutUser(showFlushbar: false);
      }
    }
  }

  Future<void> _logoutUser({bool showFlushbar = true}) async {
    await _localDatasource
        .removeToken(); // Gunakan removeToken dari LocalDatasource
    _sessionToken = null; // Bersihkan token internal

    if (mounted) {
      context.go(InitialRoutes.loginPage);
      if (showFlushbar) {
        CustomFlushbar.showTopFlashbar(context, 'Logout Success', true);
      }
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'Apakah Anda yakin ingin keluar?',
                style: TextStyle(fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 10.0,
                      ),
                    ),
                    child: const Text(
                      'Tidak',
                      style: TextStyle(color: Colors.blue, fontSize: 16.0),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 35.0,
                        vertical: 10.0,
                      ),
                    ),
                    child: const Text('Ya', style: TextStyle(fontSize: 16.0)),
                  ),
                ],
              ),
            ],
          ),
          contentPadding: const EdgeInsets.all(25.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        );
      },
    ).then((confirmed) {
      if (confirmed == true) {
        _logoutUser();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Koperasi Merah Putih',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFE30031),
        actions: [
          // BlocBuilder for Notification Icon with Badge
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              int currentUnreadCount = 0;
              if (state is NotificationLoaded) {
                currentUnreadCount = state.notifications.length;
              }

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    tooltip: 'Notification',
                    onPressed: () async {
                      if (_sessionToken != null) {
                        // Navigate to NotificationPage and await result to refresh count
                        await context.push(InitialRoutes.notification);
                        // After returning from NotificationPage, refresh notifications to update count
                        if (mounted) {
                          context.read<NotificationBloc>().add(
                            GetNotificationEvent(),
                          );
                        }
                      } else {
                        CustomFlushbar.showTopFlashbar(
                          context,
                          'Token tidak tersedia. Silakan login kembali.',
                          false,
                        );
                        _logoutUser(showFlushbar: false);
                      }
                    },
                  ),
                  if (currentUnreadCount > 0)
                    Positioned(
                      right: 5,
                      top: 5,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '$currentUnreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildHeader(context),
            _buildCooperativeInfoSection(context),
            _buildPurchaseSection(context),
            _buildInfoSliderSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final String formattedDate = _isDateFormatterInitialized
        ? DateFormat('dd MMMM', 'id_ID').format(
            DateTime.now(),
          ) // Format date without year
        : '...';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 20.0,
        left: 20.0,
        right: 20.0,
        bottom: 20.0,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE30031), Color(0xFFE30031)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _isLoadingUserData
                  ? CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white.withOpacity(0.5),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.blue,
                      ), // Indikator loading
                    )
                  : CircleAvatar(
                      radius: 25.0,
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(_userPhotoUrl),
                      onBackgroundImageError: (exception, stackTrace) {
                        if (mounted) {
                          setState(() {
                            _userPhotoUrl =
                                ''; // Set ke string kosong untuk menampilkan icon default
                          });
                          print('Error loading image: $exception');
                        }
                      },
                      child:
                          _userPhotoUrl.isEmpty ||
                              !_userPhotoUrl.startsWith('http')
                          ? Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.blue.shade700, // Warna icon default
                            )
                          : null,
                    ),
              const SizedBox(width: 15.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isLoadingUserData ? 'Loading...' : 'Hello, $_userName',
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.0),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 3.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Text(
                      'Anggota Aktif',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25.0),
          Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Saldo Terakhir',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          const Text(
                            'Rp 0',
                            style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 15.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildBalanceInfoBox(
                        icon: Icons.arrow_downward_rounded,
                        iconColor: Colors.green,
                        title: 'Simpanan',
                        amount: 'Rp 0',
                      ),
                      Container(
                        height: 50,
                        width: 1,
                        color: Colors.grey.shade300,
                      ),
                      _buildBalanceInfoBox(
                        icon: Icons.arrow_upward_rounded,
                        iconColor: Colors.orange,
                        title: 'Pinjaman',
                        amount: 'Rp 0',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceInfoBox({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String amount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 13.0,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6.0),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 15.0,
        right: 15.0,
        top: 25.0,
        bottom: 15.0,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCooperativeInfoSection(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double itemWidth = 100.0;
    int crossAxisCount = (screenWidth / itemWidth).floor();
    if (crossAxisCount < 2) crossAxisCount = 2;
    if (crossAxisCount > 4) crossAxisCount = 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Informasi Koperasi'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: GridView.count(
            crossAxisCount: crossAxisCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 1.0,
            crossAxisSpacing: 1.0,
            children: <Widget>[
              _buildFeatureItem(
                context,
                Icons.account_balance_wallet,
                'Simpanan',
                onTap: () {
                  if (_sessionToken != null) {
                    context.push('/home/simpanan', extra: _sessionToken!);
                  } else {
                    CustomFlushbar.showTopFlashbar(
                      context,
                      'Token tidak tersedia. Silakan login kembali.',
                      false,
                    );
                    _logoutUser(showFlushbar: false);
                  }
                },
              ),
              _buildFeatureItem(
                context,
                Icons.savings,
                'Tabungan',
                onTap: () {
                  if (_sessionToken != null) {
                    context.push('/home/tabungan', extra: _sessionToken!);
                  } else {
                    CustomFlushbar.showTopFlashbar(
                      context,
                      'Token tidak tersedia. Silakan login kembali.',
                      false,
                    );
                    _logoutUser(showFlushbar: false);
                  }
                },
              ),
              _buildFeatureItem(
                context,
                Icons.monetization_on,
                'Pinjaman',
                onTap: () {
                  if (_sessionToken != null) {
                    context.push('/home/pinjaman', extra: _sessionToken!);
                  } else {
                    CustomFlushbar.showTopFlashbar(
                      context,
                      'Token tidak tersedia. Silakan login kembali.',
                      false,
                    );
                    _logoutUser(showFlushbar: false);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseSection(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double itemWidth = 100.0;
    int crossAxisCount = (screenWidth / itemWidth).floor();
    if (crossAxisCount < 2) crossAxisCount = 2;
    if (crossAxisCount > 4) crossAxisCount = 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Pembelian & Pembayaran'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: GridView.count(
            crossAxisCount: crossAxisCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: <Widget>[
              _buildFeatureItem(
                context,
                Icons.phone_android,
                'Paket Data',
                onTap: () {
                  if (_sessionToken != null) {
                    context.push('/home/paket-data-form');
                  } else {
                    CustomFlushbar.showTopFlashbar(
                      context,
                      'Token tidak tersedia. Silakan login kembali.',
                      false,
                    );
                    _logoutUser(showFlushbar: false);
                  }
                },
              ),
              _buildFeatureItem(
                context,
                Icons.phone_disabled_rounded,
                'Pulsa',
                onTap: () {
                  if (_sessionToken != null) {
                    context.push('/home/pulsa-data-form');
                  } else {
                    CustomFlushbar.showTopFlashbar(
                      context,
                      'Token tidak tersedia. Silakan login kembali.',
                      false,
                    );
                    _logoutUser(showFlushbar: false);
                  }
                },
              ),
              _buildFeatureItem(
                context,
                Icons.electrical_services,
                'PLN',
                onTap: () {
                  if (_sessionToken != null) {
                    context.push('/home/token-listrik-form');
                  } else {
                    CustomFlushbar.showTopFlashbar(
                      context,
                      'Token tidak tersedia. Silakan login kembali.',
                      false,
                    );
                    _logoutUser(showFlushbar: false);
                  }
                },
              ),
              _buildFeatureItem(
                context,
                Icons.receipt_long,
                'Top Up E-Wallet',
                onTap: () {
                  if (_sessionToken != null) {
                    context.push('/home/bayar-listrik-form');
                  } else {
                    CustomFlushbar.showTopFlashbar(
                      context,
                      'Token tidak tersedia. Silakan login kembali.',
                      false,
                    );
                    _logoutUser(showFlushbar: false);
                  }
                },
              ),
              _buildFeatureItem(
                context,
                Icons.water,
                'Bayar PDAM',
                onTap: () {
                  if (_sessionToken != null) {
                    context.push('/home/bayar-pdam-form');
                  } else {
                    CustomFlushbar.showTopFlashbar(
                      context,
                      'Token tidak tersedia. Silakan login kembali.',
                      false,
                    );
                    _logoutUser(showFlushbar: false);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String label, {
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap:
            onTap ??
            () {
              CustomFlushbar.showTopFlashbar(
                context,
                'Fitur $label diklik (Belum Diimplementasi)',
                false,
              );
            },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 30.0, color: const Color(0xFFE30031)),
              const SizedBox(height: 6.0),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE30031),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSliderSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 15.0,
            right: 15.0,
            top: 25.0,
            bottom: 15.0,
          ),
          child: const Text(
            'Informasi & Promo',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(
          height: 180.0,
          child: PageView.builder(
            controller: _pageController,
            itemCount: imgList.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (BuildContext context, int index) {
              final item = imgList[index];
              double scale = _currentPage == index ? 1.0 : 0.9;
              if (_pageController.position.haveDimensions) {
                scale = 1 - (_pageController.page! - index).abs() * 0.15;
                scale = scale.clamp(0.85, 1.0);
              }

              return GestureDetector(
                onTap: () {
                  context.push('/home/info-detail', extra: item);
                },
                child: Transform.scale(
                  scale: scale,
                  child: Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Stack(
                        children: [
                          // Gambar (sebagai latar belakang)
                          Positioned.fill(
                            child: Image.asset(
                              item['image']!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.grey.shade500,
                                      size: 40,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          // Overlay Gradient (untuk membantu keterbacaan teks)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(
                                      0.7,
                                    ), // Dari bawah gelap
                                    Colors.transparent, // Ke atas transparan
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  stops: const [
                                    0.0,
                                    0.7,
                                  ], // Kontrol seberapa jauh gradient
                                ),
                              ),
                            ),
                          ),
                          // Teks Judul di Bawah
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 8.0,
                              ),
                              child: Text(
                                item['title']!, // Mengambil judul dari item
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color:
                                      Colors.white, // Teks putih agar kontras
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    // Tambahkan shadow untuk keterbacaan lebih baik
                                    Shadow(
                                      blurRadius: 3.0,
                                      color: Colors.black,
                                      offset: Offset(1.0, 1.0),
                                    ),
                                  ],
                                ),
                                maxLines:
                                    2, // Batasi jumlah baris jika judul panjang
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(imgList.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(
                horizontal: 4.0,
                vertical: 10.0,
              ),
              height: _currentPage == index ? 10.0 : 8.0,
              width: _currentPage == index ? 10.0 : 8.0,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? const Color(0xFFE30031)
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(5.0),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
