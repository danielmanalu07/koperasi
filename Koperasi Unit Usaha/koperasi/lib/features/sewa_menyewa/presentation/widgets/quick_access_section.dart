import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koperasi/core/constants/color_constant.dart';
import 'package:koperasi/core/routes/initial_routes.dart';
import 'package:koperasi/features/sewa_menyewa/presentation/widgets/menu_item_card.dart';

class QuickAccessSection extends StatefulWidget {
  const QuickAccessSection({super.key});

  @override
  State<QuickAccessSection> createState() => _QuickAccessSectionState();
}

class _QuickAccessSectionState extends State<QuickAccessSection> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modernized title with a cleaner font and subtle shadow
          Text(
            "Menu",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey[900],
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  blurRadius: 4.0,
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              MenuItemCard(
                title: "Aset",
                icon: Icons.business_center_rounded,
                color: Colors.purple.shade700,
                onTap: () {
                  context.push(InitialRoutes.assetPage);
                },
              ),
              MenuItemCard(
                title: "Pengeluaran",
                icon: Icons.money_off_csred_rounded,
                color: Colors.orange.shade700,
                onTap: () {
                  context.push(InitialRoutes.expansePage);
                },
              ),
              MenuItemCard(
                title: "Pemasukan",
                icon: Icons.monetization_on_rounded,
                color: ColorConstant.greenColor,
                onTap: () {
                  print('Navigasi ke Menu Pemasukan');
                },
              ),
              MenuItemCard(
                title: "Laporan",
                icon: Icons.bar_chart_rounded,
                color: ColorConstant.blueColor,
                onTap: () {
                  print('Navigasi ke Menu Laporan');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
