import 'package:equatable/equatable.dart';

abstract class MiniMarketEvent extends Equatable {
  const MiniMarketEvent();

  @override
  List<Object> get props => [];
}

class GetMiniMarketDataEvent extends MiniMarketEvent {}

// ... (existing imports and MiniMarketEvent abstract class)

class AddProductToCartEvent extends MiniMarketEvent {
  final dynamic product;
  final int quantity;
  final double itemTotal;

  const AddProductToCartEvent(this.product, this.quantity, this.itemTotal);

  @override
  List<Object> get props => [product, quantity, itemTotal];
}

class UpdateCartItemQuantityEvent extends MiniMarketEvent {
  final String productName;
  final int newQuantity;

  const UpdateCartItemQuantityEvent(this.productName, this.newQuantity);

  @override
  List<Object> get props => [productName, newQuantity];
}

class RemoveProductFromCartEvent extends MiniMarketEvent {
  final String productName;

  const RemoveProductFromCartEvent(this.productName);

  @override
  List<Object> get props => [productName];
}

class CheckoutCartEvent extends MiniMarketEvent {
  final List<Map<String, dynamic>> items;
  final double total;

  const CheckoutCartEvent(this.items, this.total);

  @override
  List<Object> get props => [items, total];
}

class ClearCartEvent extends MiniMarketEvent {
  const ClearCartEvent();

  @override
  List<Object> get props => [];
}
