import 'package:equatable/equatable.dart';
import 'package:koperasi/features/minimarket/domain/usecases/get_mini_market_data.dart';

abstract class MiniMarketState extends Equatable {
  const MiniMarketState();

  @override
  List<Object> get props => [];
}

class MiniMarketInitial extends MiniMarketState {}

class MiniMarketLoading extends MiniMarketState {}

class MiniMarketLoaded extends MiniMarketState {
  final MiniMarketAllData miniMarketData;

  const MiniMarketLoaded({required this.miniMarketData});

  @override
  List<Object> get props => [miniMarketData];
}

class MiniMarketError extends MiniMarketState {
  final String message;

  const MiniMarketError({required this.message});

  @override
  List<Object> get props => [message];
}
