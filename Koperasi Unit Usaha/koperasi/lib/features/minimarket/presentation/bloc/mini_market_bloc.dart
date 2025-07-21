import 'package:bloc/bloc.dart';
import 'package:koperasi/features/minimarket/data/dataSources/mini_market_remote_datasource.dart';
import 'package:koperasi/features/minimarket/data/models/mini_market_product_model.dart';
import 'package:koperasi/features/minimarket/data/models/mini_market_pos_transaction_model.dart'; // Make sure this is imported
import 'package:koperasi/features/minimarket/data/models/mini_market_financial_summary_model.dart'; // Make sure this is imported
import 'package:koperasi/features/minimarket/data/models/mini_market_expense_model.dart'; // Make sure this is imported
import 'package:koperasi/features/minimarket/data/models/mini_market_income_model.dart'; // Make sure this is imported
import 'package:koperasi/features/minimarket/data/models/mini_market_procurement_model.dart'; // Make sure this is imported
import 'package:koperasi/features/minimarket/data/models/mini_market_asset_model.dart'; // Make sure this is imported

import 'package:koperasi/features/minimarket/domain/usecases/get_mini_market_data.dart';
import 'mini_market_event.dart';
import 'mini_market_state.dart';

class MiniMarketBloc extends Bloc<MiniMarketEvent, MiniMarketState> {
  final GetMiniMarketData getMiniMarketData;
  final MiniMarketRemoteDatasource remoteDatasource;

  MiniMarketBloc({
    required this.getMiniMarketData,
    required this.remoteDatasource,
  }) : super(MiniMarketInitial()) {
    on<GetMiniMarketDataEvent>(_onGetMiniMarketData);
    on<AddProductToCartEvent>(_onAddProductToCart);
    on<UpdateCartItemQuantityEvent>(_onUpdateCartItemQuantity);
    on<RemoveProductFromCartEvent>(_onRemoveProductFromCart);
    on<CheckoutCartEvent>(_onCheckoutCart);
    on<ClearCartEvent>(_onClearCart);
  }

  Future<void> _onGetMiniMarketData(
    GetMiniMarketDataEvent event,
    Emitter<MiniMarketState> emit,
  ) async {
    emit(MiniMarketLoading());
    try {
      final miniMarketAllData = await getMiniMarketData.execute();
      emit(MiniMarketLoaded(miniMarketData: miniMarketAllData));
    } catch (e) {
      emit(MiniMarketError(message: e.toString()));
    }
  }

  void _onAddProductToCart(
    AddProductToCartEvent event,
    Emitter<MiniMarketState> emit,
  ) {
    if (state is MiniMarketLoaded) {
      final currentState = state as MiniMarketLoaded;
      final List<Map<String, dynamic>> updatedCartItems = List.from(
        currentState.miniMarketData.cartItems,
      );

      bool found = false;
      for (int i = 0; i < updatedCartItems.length; i++) {
        // Assuming product in cart item has a 'name' to identify
        if (updatedCartItems[i]['name'] == event.product.name) {
          final int currentQty = updatedCartItems[i]['qty'] as int;
          final double currentSubtotal =
              updatedCartItems[i]['subtotal'] as double;

          if (currentQty + event.quantity <= event.product.stock) {
            updatedCartItems[i]['qty'] = currentQty + event.quantity;
            updatedCartItems[i]['subtotal'] = currentSubtotal + event.itemTotal;
            found = true;
          } else {
            print(
              'Cannot add more. Stock limit reached for ${event.product.name}',
            );
            return;
          }
          break;
        }
      }

      if (!found) {
        if (event.quantity <= event.product.stock) {
          updatedCartItems.add({
            'name': event.product.name,
            'price': event.product.price,
            'qty': event.quantity,
            'subtotal': event.itemTotal,
            'originalProduct':
                event.product, // Keep a reference to the original product model
          });
        } else {
          print(
            'Cannot add. Initial quantity exceeds stock for ${event.product.name}',
          );
          return;
        }
      }

      emit(
        MiniMarketLoaded(
          miniMarketData: currentState.miniMarketData.copyWith(
            cartItems: updatedCartItems,
          ),
        ),
      );
    }
  }

  void _onUpdateCartItemQuantity(
    UpdateCartItemQuantityEvent event,
    Emitter<MiniMarketState> emit,
  ) {
    if (state is MiniMarketLoaded) {
      final currentState = state as MiniMarketLoaded;
      final List<Map<String, dynamic>> updatedCartItems = List.from(
        currentState.miniMarketData.cartItems,
      );

      final int index = updatedCartItems.indexWhere(
        (item) => item['name'] == event.productName,
      );

      if (index != -1) {
        final MiniMarketProductModel originalProduct =
            updatedCartItems[index]['originalProduct'];

        if (event.newQuantity > 0 &&
            event.newQuantity <= originalProduct.stock) {
          updatedCartItems[index]['qty'] = event.newQuantity;
          updatedCartItems[index]['subtotal'] =
              originalProduct.price * event.newQuantity;
        } else if (event.newQuantity == 0) {
          updatedCartItems.removeAt(index);
        } else if (event.newQuantity > originalProduct.stock) {
          print(
            'Cannot update. New quantity exceeds stock for ${event.productName}',
          );
          return;
        }
      }

      emit(
        MiniMarketLoaded(
          miniMarketData: currentState.miniMarketData.copyWith(
            cartItems: updatedCartItems,
          ),
        ),
      );
    }
  }

  void _onRemoveProductFromCart(
    RemoveProductFromCartEvent event,
    Emitter<MiniMarketState> emit,
  ) {
    if (state is MiniMarketLoaded) {
      final currentState = state as MiniMarketLoaded;
      final List<Map<String, dynamic>> updatedCartItems = List.from(
        currentState.miniMarketData.cartItems,
      );

      updatedCartItems.removeWhere((item) => item['name'] == event.productName);

      emit(
        MiniMarketLoaded(
          miniMarketData: currentState.miniMarketData.copyWith(
            cartItems: updatedCartItems,
          ),
        ),
      );
    }
  }

  void _onCheckoutCart(CheckoutCartEvent event, Emitter<MiniMarketState> emit) {
    if (state is MiniMarketLoaded) {
      final currentState = state as MiniMarketLoaded;
      List<MiniMarketProductModel> updatedProductList = List.from(
        currentState.miniMarketData.productList,
      );
      // Change type to MiniMarketPosTransactionModel
      List<MiniMarketPosTransactionModel> updatedPosTransactions = List.from(
        currentState.miniMarketData.posTransactions,
      );

      // 1. Update Product Stock
      bool stockSufficient = true;
      for (var cartItem in event.items) {
        final String productName = cartItem['name'];
        final int quantitySold = cartItem['qty'] as int;

        final productIndex = updatedProductList.indexWhere(
          (p) => p.name == productName,
        );
        if (productIndex != -1) {
          final currentStock = updatedProductList[productIndex].stock as int;
          if (currentStock >= quantitySold) {
            updatedProductList[productIndex] =
                (updatedProductList[productIndex] as MiniMarketProductModel)
                    .copyWith(stock: currentStock - quantitySold);
          } else {
            print('Error: Not enough stock for $productName during checkout.');
            stockSufficient = false;
            break;
          }
        }
      }

      if (!stockSufficient) {
        emit(currentState);
        return;
      }

      // 2. Add new POS transaction
      // Instantiate MiniMarketPosTransactionModel directly
      final newTransaction = MiniMarketPosTransactionModel(
        id: "TRX${DateTime.now().millisecondsSinceEpoch}", // Unique ID
        total: event.total,
        date: DateTime.now(), // YYYY-MM-DD HH:MM
        items: (event.items as List)
            .map(
              (item) => {
                "name": item['name'] as String, // Ensure type for mapping
                "qty": item['qty'] as int, // Ensure type for mapping
              },
            )
            .toList(),
      );
      updatedPosTransactions.add(newTransaction);

      // 3. Update financial summary (increase total income and total balance)
      final currentFinancialSummary =
          currentState.miniMarketData.financialSummary;
      final updatedFinancialSummary = currentFinancialSummary.copyWith(
        totalIncome: currentFinancialSummary.totalIncome + event.total,
        totalBalance: currentFinancialSummary.totalBalance + event.total,
      );

      // 4. Emit new state with updated data and clear cart
      emit(
        MiniMarketLoaded(
          miniMarketData: currentState.miniMarketData.copyWith(
            productList: updatedProductList,
            posTransactions:
                updatedPosTransactions, // Now it's the correct type
            financialSummary: updatedFinancialSummary,
            cartItems: [], // Clear the cart after successful checkout
          ),
        ),
      );
    }
  }

  void _onClearCart(ClearCartEvent event, Emitter<MiniMarketState> emit) {
    if (state is MiniMarketLoaded) {
      final currentState = state as MiniMarketLoaded;
      emit(
        MiniMarketLoaded(
          miniMarketData: currentState.miniMarketData.copyWith(
            cartItems: [], // Set cartItems to an empty list
          ),
        ),
      );
    }
  }
}
