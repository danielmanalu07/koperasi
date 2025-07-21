import 'package:koperasi/features/minimarket/data/models/mini_market_asset_model.dart';
import 'package:koperasi/features/minimarket/data/models/mini_market_expense_model.dart';
import 'package:koperasi/features/minimarket/data/models/mini_market_financial_summary_model.dart';
import 'package:koperasi/features/minimarket/data/models/mini_market_income_model.dart';
import 'package:koperasi/features/minimarket/data/models/mini_market_pos_transaction_model.dart';
import 'package:koperasi/features/minimarket/data/models/mini_market_procurement_model.dart';
import 'package:koperasi/features/minimarket/data/models/mini_market_product_model.dart';
import 'package:koperasi/features/minimarket/domain/repositories/mini_market_repository.dart';

class MiniMarketAllData {
  final MiniMarketFinancialSummaryModel financialSummary;
  final List<MiniMarketExpenseModel> expenses;
  final List<MiniMarketIncomeModel> incomes;
  final List<MiniMarketProductModel> productList;
  final List<MiniMarketProcurementModel> procurementList;
  final List<MiniMarketPosTransactionModel> posTransactions;
  final List<MiniMarketAssetModel> assets;
  final List<Map<String, dynamic>> cartItems; // Added cartItems field

  MiniMarketAllData({
    required this.financialSummary,
    required this.expenses,
    required this.incomes,
    required this.productList,
    required this.procurementList,
    required this.posTransactions,
    required this.assets,
    this.cartItems = const [], // Initialize as an empty list by default
  });

  // Add a copyWith method for easier state updates in Bloc
  MiniMarketAllData copyWith({
    MiniMarketFinancialSummaryModel? financialSummary,
    List<MiniMarketExpenseModel>? expenses,
    List<MiniMarketIncomeModel>? incomes,
    List<MiniMarketProductModel>? productList,
    List<MiniMarketProcurementModel>? procurementList,
    List<MiniMarketPosTransactionModel>? posTransactions,
    List<MiniMarketAssetModel>? assets,
    List<Map<String, dynamic>>? cartItems,
  }) {
    return MiniMarketAllData(
      financialSummary: financialSummary ?? this.financialSummary,
      expenses: expenses ?? this.expenses,
      incomes: incomes ?? this.incomes,
      productList: productList ?? this.productList,
      procurementList: procurementList ?? this.procurementList,
      posTransactions: posTransactions ?? this.posTransactions,
      assets: assets ?? this.assets,
      cartItems: cartItems ?? this.cartItems,
    );
  }
}

class GetMiniMarketData {
  final MiniMarketRepository repository;

  GetMiniMarketData(this.repository);

  Future<MiniMarketAllData> execute() async {
    final data = await repository.getMiniMarketData();

    // Mapping raw data (Map<String, dynamic>) ke entities
    final financialSummary = MiniMarketFinancialSummaryModel.fromJson(
      data['financialSummary'],
    );
    final expenses = (data['expenses'] as List)
        .map((e) => MiniMarketExpenseModel.fromJson(e))
        .toList();
    final incomes = (data['incomes'] as List)
        .map((i) => MiniMarketIncomeModel.fromJson(i))
        .toList();
    final productList = (data['productList'] as List)
        .map((p) => MiniMarketProductModel.fromJson(p))
        .toList();
    final procurementList = (data['procurementList'] as List)
        .map((p) => MiniMarketProcurementModel.fromJson(p))
        .toList();
    final posTransactions = (data['posTransactions'] as List)
        .map((t) => MiniMarketPosTransactionModel.fromJson(t))
        .toList();
    final assets = (data['assets'] as List)
        .map((a) => MiniMarketAssetModel.fromJson(a))
        .toList();

    // Initialize cartItems from data if available, otherwise an empty list
    // Assuming cartItems might be part of the initial data fetch if persisted
    // Otherwise, it will start empty as defined in the model constructor.
    final List<Map<String, dynamic>> cartItems =
        (data['cartItems'] as List? ?? [])
            .map((item) => item as Map<String, dynamic>)
            .toList();

    return MiniMarketAllData(
      financialSummary: financialSummary,
      expenses: expenses,
      incomes: incomes,
      productList: productList,
      procurementList: procurementList,
      posTransactions: posTransactions,
      assets: assets,
      cartItems: cartItems, // Pass cartItems to the constructor
    );
  }
}
