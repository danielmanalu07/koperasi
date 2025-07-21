import 'package:equatable/equatable.dart';
import 'package:koperasi/features/sewa_menyewa/domain/entities/asset.dart';

abstract class AssetState extends Equatable {
  const AssetState();

  @override
  List<Object?> get props => [];
}

class AssetInitial extends AssetState {}

class AssetLoading extends AssetState {}

class AssetLoaded extends AssetState {
  final List<Asset> asset;

  const AssetLoaded(this.asset);

  @override
  List<Object?> get props => [asset];
}

class AssetError extends AssetState {
  final String message;

  const AssetError(this.message);

  @override
  List<Object?> get props => [message];
}

class AssetCreating extends AssetState {}

class AssetCreated extends AssetState {
  final Asset asset;

  const AssetCreated(this.asset);

  @override
  List<Object?> get props => [asset];
}

class AssetCreateError extends AssetState {
  final String message;

  const AssetCreateError(this.message);

  @override
  List<Object?> get props => [message];
}
