abstract class MiniMarketRemoteDatasource {
  Future<Map<String, dynamic>> getMiniMarketData();
}

class MiniMarketRemoteDatasourceimpl implements MiniMarketRemoteDatasource {
  @override
  Future<Map<String, dynamic>> getMiniMarketData() async {
    // Simulasikan penundaan jaringan
    await Future.delayed(const Duration(milliseconds: 700));

    // Data JSON Mock untuk Mini Market
    return {
      "statusCode": 200,
      "message": "Data Mini Market fetched successfully",
      "data": {
        "financialSummary": {
          "totalBalance": 20000000.0,
          "totalIncome": 30000000.0,
          "totalExpense": 10000000.0,
        },
        "expenses": [
          {
            "category": "Gaji Karyawan",
            "amount": 4000000.0,
            "description": "Gaji bulan Juli",
          },
          {
            "category": "Beli untuk Aset",
            "amount": 2000000.0,
            "description": "Pembelian freezer baru",
          },
          {
            "category": "Beli Produk / Pengadaan Barang",
            "amount": 3000000.0,
            "description": "Pengadaan stok makanan & minuman",
          },
          {
            "category": "Lainnya",
            "amount": 1000000.0,
            "description": "Biaya listrik dan air",
          },
        ],
        "incomes": [
          {
            "category": "Terjual Produk",
            "amount": 28000000.0,
            "description": "Penjualan harian (POS) Juli",
          },
          {
            "category": "Terjual Aset",
            "amount": 2000000.0,
            "description": "Penjualan rak display bekas",
          },
        ],
        "productList": [
          {"name": "Indomie Goreng", "price": 3000.0, "stock": 100},
          {"name": "Teh Botol Sosro", "price": 5000.0, "stock": 50},
          {"name": "Sabun Mandi Lux", "price": 10000.0, "stock": 30},
          {"name": "Beras 5kg", "price": 60000.0, "stock": 20},
          {"name": "Minyak Goreng 1L", "price": 18000.0, "stock": 40},
        ],
        "procurementList": [
          {
            "item": "Beras 5kg",
            "quantity": 10,
            "cost": 600000.0,
            "date": "2025-07-01",
          },
          {
            "item": "Minyak Goreng 1L",
            "quantity": 20,
            "cost": 360000.0,
            "date": "2025-07-02",
          },
          {
            "item": "Indomie Goreng",
            "quantity": 50,
            "cost": 150000.0,
            "date": "2025-07-03",
          },
        ],
        "posTransactions": [
          {
            "id": "TRX001",
            "total": 15000.0,
            "date": "2025-07-04 10:30",
            "items": [
              {"name": "Indomie Goreng", "qty": 3},
              {"name": "Teh Botol Sosro", "qty": 1},
            ],
          },
          {
            "id": "TRX002",
            "total": 25000.0,
            "date": "2025-07-04 11:00",
            "items": [
              {"name": "Sabun Mandi Lux", "qty": 1},
              {"name": "Teh Botol Sosro", "qty": 2},
            ],
          },
          {
            "id": "TRX003",
            "total": 65000.0,
            "date": "2025-07-04 12:15",
            "items": [
              {"name": "Beras 5kg", "qty": 1},
              {"name": "Minyak Goreng 1L", "qty": 1},
            ],
          },
        ],
        "assets": [
          {
            "name": "Freezer Minuman",
            "value": 2000000.0,
            "purchaseDate": "2024-03-20",
          },
          {
            "name": "Rak Display",
            "value": 500000.0,
            "purchaseDate": "2024-05-10",
          },
          {
            "name": "Komputer POS",
            "value": 3500000.0,
            "purchaseDate": "2025-01-05",
          },
        ],
        "cartItems":
            [], // Added empty cartItems to match the expected structure
      },
    };
  }
}
