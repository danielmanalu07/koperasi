import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koperasi/core/routes/initial_routes.dart';

class MainAppLayout extends StatefulWidget {
  final Widget child;
  final String currentPath; // Path GoRouter saat ini
  final String? token;

  const MainAppLayout({
    super.key,
    required this.child,
    required this.currentPath,
    this.token,
  });

  @override
  State<MainAppLayout> createState() => _MainAppLayoutState();
}

class _MainAppLayoutState extends State<MainAppLayout> {
  int _selectedIndex = 0;

  // Mendapatkan index dari path saat ini
  int _getCurrentIndex(String path) {
    if (path.startsWith('/home')) {
      return 0; // Beranda
    } else if (path.startsWith('/promo')) {
      return 1; // Promo
    } else if (path.startsWith('/riwayat')) {
      return 2; // Riwayat
    } else if (path.startsWith('/profile')) {
      return 3; // Profil
    }
    return 0; // Default ke Beranda
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // PERBAIKAN DI SINI: Gunakan widget.currentPath secara langsung
    // karena sudah merupakan path absolut seperti '/home' atau '/promo'
    final newIndex = _getCurrentIndex(widget.currentPath);
    if (newIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = newIndex;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigasi dengan GoRouter
    switch (index) {
      case 0:
        context.go(InitialRoutes.homePage); // Beranda
        break;
      case 1:
        context.go(InitialRoutes.promo); // Promo
        break;
      case 2:
        context.go(InitialRoutes.riwayat); // Riwayat
        break;
      case 3:
        context.go(InitialRoutes.profile); // Profil
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child, // GoRouter akan menempatkan halaman di sini

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, -3), // Bayangan ke atas
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.blue, // Warna biru untuk item terpilih
          unselectedItemColor:
              Colors.grey, // Warna abu-abu untuk item tidak terpilih
          backgroundColor: Colors.white, // Latar belakang putih
          type: BottomNavigationBarType.fixed, // Memastikan semua item terlihat

          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                _selectedIndex == 0
                    ? Icons.home
                    : Icons.home_outlined, // Icon solid jika terpilih
                size: 28,
              ),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _selectedIndex == 1 ? Icons.discount : Icons.discount_outlined,
                size: 28,
              ),
              label: 'Promo',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _selectedIndex == 2
                    ? Icons.receipt_long
                    : Icons.receipt_long_outlined,
                size: 28,
              ),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _selectedIndex == 3 ? Icons.person : Icons.person_outline,
                size: 28,
              ),
              label: 'Profil',
            ),
          ],
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          showUnselectedLabels: true, // Pastikan label muncul untuk semua item
        ),
      ),
    );
  }
}
