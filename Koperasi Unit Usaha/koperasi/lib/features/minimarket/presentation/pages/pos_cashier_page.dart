import 'package:flutter/material.dart';
import 'package:koperasi/core/constants/color_constant.dart';
import 'package:koperasi/core/utils/currency_formatter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koperasi/features/minimarket/data/models/mini_market_product_model.dart'; // Import your product model
import 'package:koperasi/features/minimarket/presentation/bloc/mini_market_bloc.dart';
import 'package:koperasi/features/minimarket/presentation/bloc/mini_market_event.dart'; // Import event
import 'package:koperasi/features/minimarket/presentation/bloc/mini_market_state.dart';
import 'package:koperasi/features/minimarket/presentation/pages/cart_pages.dart'; // Import the new CartPage

class PosCashierPage extends StatefulWidget {
  final List<MiniMarketProductModel> productList; // Use concrete type

  const PosCashierPage({super.key, required this.productList});

  @override
  State<PosCashierPage> createState() => _PosCashierPageState();
}

class _PosCashierPageState extends State<PosCashierPage> {
  TextEditingController _searchController = TextEditingController();
  List<MiniMarketProductModel> _filteredProducts = []; // Use concrete type

  @override
  void initState() {
    super.initState();
    _filteredProducts = widget.productList;
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = widget.productList.where((product) {
        return product.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showProductDetailsModal(MiniMarketProductModel product) {
    int quantity = 1;
    double itemTotal = product.price;
    TextEditingController quantityController = TextEditingController(
      text: quantity.toString(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors
          .transparent, // Make background transparent to see border radius
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            itemTotal = product.price * quantity;

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25.0),
                  topRight: Radius.circular(25.0),
                ),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: ClipRRect(
                      // Rounded image/icon container
                      borderRadius: BorderRadius.circular(15.0),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          // Optional: if you have product images, load them here
                          // image: DecorationImage(
                          //   image: NetworkImage('product.imageUrl'), // Example
                          //   fit: BoxFit.cover,
                          // ),
                        ),
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.blue,
                          size: 60,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ColorConstant.blackColor, // Deeper color
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    formatCurrency(product.price),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.green, // Highlight price
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Stok Tersedia: ${product.stock}',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Jumlah:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, color: Colors.red),
                              onPressed: () {
                                modalSetState(() {
                                  if (quantity > 1) {
                                    quantity--;
                                    quantityController.text = quantity
                                        .toString();
                                  }
                                });
                              },
                              splashRadius: 20,
                            ),
                            SizedBox(
                              width: 50, // Fixed width for quantity input
                              child: TextField(
                                controller: quantityController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (value) {
                                  int? newQty = int.tryParse(value);
                                  modalSetState(() {
                                    if (newQty != null && newQty! > 0) {
                                      if (newQty! > product.stock) {
                                        newQty = product.stock;
                                        quantityController.text = newQty
                                            .toString();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Jumlah melebihi stok yang tersedia!',
                                            ),
                                          ),
                                        );
                                      }
                                      quantity = newQty!;
                                    } else if (value.isEmpty) {
                                      quantity =
                                          0; // Allow temporary empty input
                                    } else {
                                      quantity =
                                          1; // Default to 1 if invalid input
                                      quantityController.text = '1';
                                    }
                                    itemTotal = product.price * quantity;
                                  });
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.green),
                              onPressed: () {
                                modalSetState(() {
                                  if (quantity < product.stock) {
                                    quantity++;
                                    quantityController.text = quantity
                                        .toString();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Jumlah melebihi stok yang tersedia!',
                                        ),
                                      ),
                                    );
                                  }
                                });
                              },
                              splashRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Total: ${formatCurrency(itemTotal)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ColorConstant.blueColor, // Main accent color
                      ),
                    ),
                  ),
                  const SizedBox(height: 30), // Increased spacing for buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (quantity > 0) {
                              context.read<MiniMarketBloc>().add(
                                AddProductToCartEvent(
                                  product,
                                  quantity,
                                  itemTotal,
                                ),
                              );
                              Navigator.pop(context); // Close modal
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Jumlah tidak boleh kosong atau nol.',
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorConstant.blueColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5, // Add a subtle shadow
                          ),
                          child: const Text(
                            'Tambahkan ke Keranjang',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            if (quantity > 0) {
                              context.read<MiniMarketBloc>().add(
                                AddProductToCartEvent(
                                  product,
                                  quantity,
                                  itemTotal,
                                ),
                              );
                              Navigator.pop(context); // Close modal
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CartPage(),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Jumlah tidak boleh kosong atau nol.',
                                  ),
                                ),
                              );
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ColorConstant.blueColor,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: ColorConstant.blueColor,
                              width: 2,
                            ), // Thicker border
                          ),
                          child: const Text(
                            'Selesaikan Sekarang',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Kasir', style: TextStyle(color: Colors.white)),
        backgroundColor: ColorConstant.blueColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child:
                _filteredProducts.isEmpty && _searchController.text.isNotEmpty
                ? const Center(
                    child: Text(
                      'Produk tidak ditemukan.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return GestureDetector(
                        onTap: () => _showProductDetailsModal(product),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Stok: ${product.stock}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: product.stock > 10
                                            ? Colors.grey[700]
                                            : Colors.red,
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
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<MiniMarketBloc, MiniMarketState>(
        builder: (context, state) {
          if (state is MiniMarketLoaded) {
            final cartItems = state.miniMarketData.cartItems;
            final totalItems = cartItems.fold<int>(
              0,
              (sum, item) => sum + item['qty'] as int,
            );
            return FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartPage()),
                );
              },
              label: Text('$totalItems Barang'),
              icon: const Icon(Icons.shopping_cart),
              backgroundColor: ColorConstant.blueColor,
              foregroundColor: Colors.white,
            );
          }
          return Container();
        },
      ),
    );
  }
}
