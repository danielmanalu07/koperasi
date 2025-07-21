import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:koperasi/core/constants/color_constant.dart';
import 'package:koperasi/features/sewa_menyewa/presentation/bloc/Transaction/transaction_bloc.dart';
import 'package:koperasi/features/sewa_menyewa/presentation/bloc/Transaction/transaction_event.dart';
import 'package:koperasi/features/sewa_menyewa/presentation/bloc/Transaction/transaction_state.dart';
import 'package:koperasi/features/sewa_menyewa/presentation/widgets/Transaction/add_transaction_form_modal.dart';
import 'package:koperasi/core/injection_container.dart'
    as di; // Assuming di.sl is correctly configured

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage>
    with SingleTickerProviderStateMixin {
  final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController =
      TextEditingController(); // Added
  String _selectedStatusFilter = 'Semua'; // Added for status filter

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(LoadTransactionEvent());

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Listen to search input
    _searchController.addListener(() {
      context.read<TransactionBloc>().add(
        SearchTransactionsEvent(_searchController.text),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose(); // Dispose search controller
    super.dispose();
  }

  Future<void> _refreshTransactions() async {
    context.read<TransactionBloc>().add(LoadTransactionEvent());
  }

  void _showAddTransactionForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BlocProvider.value(
          value: di.sl<TransactionBloc>(),
          child: const AddTransactionFormModal(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Daftar Transaksi",
          style: TextStyle(color: ColorConstant.whiteColor),
        ),
        backgroundColor: ColorConstant.blueColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: _showAddTransactionForm,
            tooltip: 'Tambah Transaksi',
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: _refreshTransactions,
        color: ColorConstant.blueColor,
        child: Column(
          // Added Column for search and filter
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText:
                            'Cari berdasarkan nama pelanggan atau aset...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: ColorConstant.blueColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 16,
                        ),
                      ),
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _selectedStatusFilter,
                    icon: Icon(
                      Icons.filter_list,
                      color: ColorConstant.blueColor,
                    ),
                    elevation: 16,
                    style: TextStyle(
                      color: ColorConstant.blueColor,
                      fontSize: 14,
                    ),
                    underline: Container(
                      height: 2,
                      color: ColorConstant.blueColor,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedStatusFilter = newValue!;
                      });
                      context.read<TransactionBloc>().add(
                        FilterTransactionsByStatusEvent(newValue!),
                      );
                    },
                    items: <String>['Semua', 'Aktif', 'Selesai']
                        .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        })
                        .toList(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, state) {
                  if (state is TransactionLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              ColorConstant.blueColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Memuat data transaksi...',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  } else if (state is TransactionLoaded) {
                    if (state.transactions.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada transaksi ditemukan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tekan tombol tambah untuk membuat transaksi baru',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      );
                    }
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: state.transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = state.transactions[index];
                          return TweenAnimationBuilder(
                            duration: Duration(
                              milliseconds: 300 + (index * 50),
                            ),
                            tween: Tween<double>(begin: 0, end: 1),
                            builder: (context, double value, child) {
                              return Transform.translate(
                                offset: Offset(0, 50 * (1 - value)),
                                child: Opacity(opacity: value, child: child),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            transaction.customerName,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1A202C),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: transaction.status == 'Aktif'
                                                ? Colors.green.withOpacity(0.1)
                                                : Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            transaction.status,
                                            style: TextStyle(
                                              color:
                                                  transaction.status == 'Aktif'
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Aset: ${transaction.assetName}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tanggal: ${dateFormat.format(transaction.date)}', // Display date here
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      transaction.description,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: TextButton.icon(
                                        onPressed: () {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Detail transaksi: ${transaction.customerName}',
                                              ),
                                            ),
                                          );
                                        },
                                        icon: Icon(
                                          Icons.info_outline,
                                          color: ColorConstant.blueColor,
                                        ),
                                        label: Text(
                                          'Lihat Detail',
                                          style: TextStyle(
                                            color: ColorConstant.blueColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  } else if (state is TransactionError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 80,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Terjadi Kesalahan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.red[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _refreshTransactions,
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Coba Lagi',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorConstant.blueColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
