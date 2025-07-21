import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koperasi/core/constants/color_constant.dart';
import 'package:koperasi/core/utils/currency_formatter.dart';
import 'package:koperasi/features/minimarket/presentation/bloc/mini_market_bloc.dart';
import 'package:koperasi/features/minimarket/presentation/bloc/mini_market_event.dart';
import 'package:koperasi/features/minimarket/presentation/bloc/mini_market_state.dart';
import 'package:koperasi/features/minimarket/presentation/pages/pos_cashier_page.dart'; // Import the new page

class MiniMarketPage extends StatefulWidget {
  const MiniMarketPage({super.key});

  @override
  State<MiniMarketPage> createState() => _MiniMarketPageState();
}

class _MiniMarketPageState extends State<MiniMarketPage> {
  String selectedTab = 'dashboard';

  @override
  void initState() {
    super.initState();
    context.read<MiniMarketBloc>().add(GetMiniMarketDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Unit Usaha: Mini Market',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: ColorConstant.blueColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: BlocBuilder<MiniMarketBloc, MiniMarketState>(
        builder: (context, state) {
          if (state is MiniMarketLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MiniMarketLoaded) {
            final data = state.miniMarketData;
            return Column(children: [Expanded(child: _buildContent(data))]);
          } else if (state is MiniMarketError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Terjadi kesalahan: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<MiniMarketBloc>().add(
                        GetMiniMarketDataEvent(),
                      );
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Tidak ada data mini market.'));
        },
      ),
    );
  }

  Widget _buildContent(dynamic data) {
    // We no longer navigate to PosCashierPage via selectedTab
    // It's now navigated via Navigator.push
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (selectedTab == 'dashboard') _buildDashboard(data),
          if (selectedTab == 'pengeluaran') _buildPengeluaranSection(data),
          if (selectedTab == 'pemasukan') _buildPemasukanSection(data),
          if (selectedTab == 'produk')
            _buildListProductSection(data.productList),
          if (selectedTab == 'pengadaan')
            _buildProcurementSection(data.procurementList),
          if (selectedTab == 'pos')
            _buildPosKasirSection(
              data.posTransactions,
            ), // Re-added to show history if 'pos' tab is selected
          if (selectedTab == 'aset') _buildAssetSection(data.assets),
        ],
      ),
    );
  }

  Widget _buildDashboard(dynamic data) {
    return Column(
      children: [
        _buildFinancialSummary(data.financialSummary),
        const SizedBox(height: 20),
        _buildQuickActionsGrid(),
        const SizedBox(height: 20),
        _buildRecentTransactions(data),
      ],
    );
  }

  Widget _buildFinancialSummary(dynamic summary) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ColorConstant.blueColor,
              ColorConstant.blueColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Ringkasan Keuangan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Saldo',
                      formatCurrency(summary.totalBalance),
                      Icons.account_balance,
                      Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Pemasukan',
                      formatCurrency(summary.totalIncome),
                      Icons.trending_up,
                      Colors.green[100]!,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Pengeluaran',
                      formatCurrency(summary.totalExpense),
                      Icons.expand_less_outlined,
                      Colors.red[100]!,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String amount,
    IconData icon,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey[700], size: 20),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aksi Cepat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildQuickActionButton(
                  'Kasir',
                  Icons.point_of_sale,
                  Colors.green,
                  () {
                    // Navigate to PosCashierPage using Navigator.push
                    final state = context.read<MiniMarketBloc>().state;
                    if (state is MiniMarketLoaded) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PosCashierPage(
                            productList: state.miniMarketData.productList,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Produk belum dimuat, coba lagi.'),
                        ),
                      );
                    }
                  },
                ),
                _buildQuickActionButton(
                  'Pengeluaran',
                  Icons.money_off,
                  Colors.red,
                  () => setState(() => selectedTab = 'pengeluaran'),
                ),
                _buildQuickActionButton(
                  'Pemasukan',
                  Icons.attach_money,
                  Colors.teal,
                  () => setState(() => selectedTab = 'pemasukan'),
                ),
                _buildQuickActionButton(
                  'Pengadaan',
                  Icons.shopping_cart,
                  Colors.orange,
                  () => setState(() => selectedTab = 'pengadaan'),
                ),
                _buildQuickActionButton(
                  'Produk',
                  Icons.inventory,
                  Colors.blue,
                  () => setState(() => selectedTab = 'produk'),
                ),
                _buildQuickActionButton(
                  'Aset',
                  Icons.business,
                  Colors.purple,
                  () => setState(() => selectedTab = 'aset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(dynamic data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transaksi Terakhir',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (data.posTransactions.isNotEmpty)
              ...data.posTransactions
                  .take(3)
                  .map((transaction) => _buildTransactionTile(transaction))
            else
              const Text('Belum ada transaksi.'),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(dynamic transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.receipt, color: Colors.green, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID: ${transaction.id}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  transaction.date.toString(),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            formatCurrency(transaction.total),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPengeluaranSection(dynamic data) {
    return Column(
      children: [
        _buildSectionHeader(
          'Pengeluaran',
          Icons.money_off,
          () => _showExpenseDialog(),
        ),
        const SizedBox(height: 16),
        _buildActionButtons([
          {
            'title': 'Gaji Karyawan',
            'icon': Icons.people,
            'color': Colors.blueGrey,
          },
          {
            'title': 'Beli Aset',
            'icon': Icons.business_center,
            'color': Colors.indigo,
          },
          {
            'title': 'Pengadaan Produk',
            'icon': Icons.shopping_bag,
            'color': Colors.deepOrange,
          },
          {'title': 'Lainnya', 'icon': Icons.more_horiz, 'color': Colors.grey},
        ]),
        const SizedBox(height: 20),
        _buildSubSectionTitle('Riwayat Pengeluaran'),
        const SizedBox(height: 12),
        if (data.expenses.isEmpty)
          _buildEmptyState('Belum ada riwayat pengeluaran.', Icons.money_off)
        else
          ...data.expenses
              .map(
                (e) => _buildTransactionItemCard(
                  title: e.category,
                  description: e.description,
                  amount: e.amount,
                  isExpense: true,
                  icon: _getExpenseIcon(e.category),
                  iconColor: Colors.red[400]!,
                ),
              )
              .toList(),
      ],
    );
  }

  Widget _buildPemasukanSection(dynamic data) {
    return Column(
      children: [
        _buildSectionHeader(
          'Pemasukan',
          Icons.attach_money,
          () => _showIncomeDialog(),
        ),
        const SizedBox(height: 16),
        _buildActionButtons([
          {
            'title': 'Terjual Produk',
            'icon': Icons.point_of_sale,
            'color': Colors.green,
          },
          {
            'title': 'Terjual Aset',
            'icon': Icons.apartment,
            'color': Colors.cyan,
          },
        ]),
        const SizedBox(height: 20),
        _buildSubSectionTitle('Riwayat Pemasukan'),
        const SizedBox(height: 12),
        if (data.incomes.isEmpty)
          _buildEmptyState('Belum ada riwayat pemasukan.', Icons.attach_money)
        else
          ...data.incomes
              .map(
                (i) => _buildTransactionItemCard(
                  title: i.category,
                  description: i.description,
                  amount: i.amount,
                  isExpense: false,
                  icon: _getIncomeIcon(i.category),
                  iconColor: Colors.green[400]!,
                ),
              )
              .toList(),
      ],
    );
  }

  Widget _buildActionButtons(List<Map<String, dynamic>> actions) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Kategori',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: actions.map((action) {
                return ElevatedButton.icon(
                  onPressed: () {
                    _handleCategoryAction(action['title']);
                  },
                  icon: Icon(action['icon']),
                  label: Text(
                    action['title'],
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: action['color'],
                    backgroundColor: action['color'].withOpacity(0.1),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItemCard({
    required String title,
    required String description,
    required double amount,
    required bool isExpense,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              formatCurrency(amount),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isExpense ? Colors.red[700] : Colors.green[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListProductSection(List<dynamic> products) {
    return Column(
      children: [
        _buildSectionHeader(
          'List Produk',
          Icons.inventory_2,
          () => _showAddProductDialog(),
        ),
        const SizedBox(height: 16),
        _buildSubSectionTitle('Daftar Stok Barang'),
        const SizedBox(height: 12),
        if (products.isEmpty)
          _buildEmptyState('Belum ada produk dalam daftar.', Icons.inventory_2)
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildProductGridCard(product);
            },
          ),
      ],
    );
  }

  Widget _buildProductGridCard(dynamic product) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Detail Produk: ${product.name}')),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.blue,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                formatCurrency(product.price),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Stok: ${product.stock}',
                    style: TextStyle(
                      fontSize: 13,
                      color: product.stock > 10 ? Colors.grey[700] : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (product.stock <= 10)
                    const Icon(
                      Icons.warning_amber,
                      color: Colors.amber,
                      size: 18,
                    ),
                ],
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcurementSection(List<dynamic> procurements) {
    return Column(
      children: [
        _buildSectionHeader(
          'Pengadaan Barang',
          Icons.shopping_cart,
          () => _showProcurementDialog(),
        ),
        const SizedBox(height: 16),
        if (procurements.isEmpty)
          _buildEmptyState(
            'Belum ada riwayat pengadaan barang.',
            Icons.shopping_cart,
          )
        else
          ...procurements.map(
            (procurement) => _buildProcurementCard(procurement),
          ),
      ],
    );
  }

  Widget _buildProcurementCard(dynamic procurement) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shopping_cart, color: Colors.orange),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    procurement.item,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Jumlah: ${procurement.quantity}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Text(
                    'Biaya: ${formatCurrency(procurement.cost)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Tanggal: ${procurement.date}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPosKasirSection(List<dynamic> transactions) {
    return Column(
      children: [
        _buildSectionHeader(
          'Riwayat Transaksi POS',
          Icons.point_of_sale,
          // This button will now take you to the *new* PosCashierPage if pressed
          () {
            final state = context.read<MiniMarketBloc>().state;
            if (state is MiniMarketLoaded) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PosCashierPage(
                    productList: state.miniMarketData.productList,
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Produk belum dimuat, coba lagi.'),
                ),
              );
            }
          },
        ),
        const SizedBox(height: 16),
        if (transactions.isEmpty)
          _buildEmptyState(
            'Belum ada riwayat transaksi POS.',
            Icons.point_of_sale,
          )
        else
          ...transactions.map(
            (transaction) => _buildTransactionCard(transaction),
          ),
      ],
    );
  }

  Widget _buildTransactionCard(dynamic transaction) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.receipt, color: Colors.green),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ID Transaksi: ${transaction.id}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tanggal: ${transaction.date}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatCurrency(transaction.total),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Item:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(
              (transaction.items as List)
                  .map((item) => '${item['name']} (${item['qty']})')
                  .join(', '),
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetSection(List<dynamic> assets) {
    return Column(
      children: [
        _buildSectionHeader('Aset', Icons.business, () => _showAssetDialog()),
        const SizedBox(height: 16),
        if (assets.isEmpty)
          _buildEmptyState('Belum ada aset yang tercatat.', Icons.business)
        else
          ...assets.map((asset) => _buildAssetCard(asset)),
      ],
    );
  }

  Widget _buildAssetCard(dynamic asset) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.business, color: Colors.purple),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nilai: ${formatCurrency(asset.value)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Tanggal Beli: ${asset.purchaseDate}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, VoidCallback onAdd) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: ColorConstant.blueColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Tambah'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstant.blueColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(icon, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getExpenseIcon(String category) {
    switch (category) {
      case 'Gaji Karyawan':
        return Icons.people;
      case 'Beli untuk Aset':
        return Icons.business_center;
      case 'Beli Produk / Pengadaan Barang':
        return Icons.shopping_bag;
      default:
        return Icons.category;
    }
  }

  IconData _getIncomeIcon(String category) {
    switch (category) {
      case 'Terjual Produk':
        return Icons.point_of_sale;
      case 'Terjual Aset':
        return Icons.apartment;
      default:
        return Icons.category;
    }
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Produk'),
        content: const Text('Fitur tambah produk akan segera tersedia.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCreateTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buat Transaksi'),
        content: const Text('Fitur buat transaksi akan segera tersedia.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showProcurementDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pengadaan Barang'),
        content: const Text('Fitur pengadaan barang akan segera tersedia.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Catat Pengeluaran'),
        content: const Text('Fitur catat pengeluaran akan segera tersedia.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showIncomeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Catat Pemasukan'),
        content: const Text('Fitur catat pemasukan akan segera tersedia.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAssetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Aset'),
        content: const Text('Fitur tambah aset akan segera tersedia.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleCategoryAction(String category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category),
        content: Text('Fitur $category akan segera tersedia.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
