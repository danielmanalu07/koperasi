import 'package:equatable/equatable.dart';
import 'package:koperasi/features/sewa_menyewa/domain/entities/asset.dart';

abstract class AssetEvent extends Equatable {
  const AssetEvent();

  @override
  List<Object?> get props => [];
}

class LoadAssetEvent extends AssetEvent {}

class AddAssetEvent extends AssetEvent {
  final Asset asset;

  const AddAssetEvent({required this.asset});

  @override
  List<Object?> get props => [asset];
}
