import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koperasi/core/errors/map_failure_toMessage.dart';
import 'package:koperasi/core/usecases/usecase.dart';
import 'package:koperasi/features/sewa_menyewa/domain/usecase/add_asset_data.dart';
import 'package:koperasi/features/sewa_menyewa/domain/usecase/get_all_asset.dart';
import 'package:koperasi/features/sewa_menyewa/presentation/bloc/Asset/asset_event.dart';
import 'package:koperasi/features/sewa_menyewa/presentation/bloc/Asset/asset_state.dart';

class AssetBloc extends Bloc<AssetEvent, AssetState> {
  final GetAllAsset getAllAsset;
  final AddAssetData addAsset;

  AssetBloc({required this.getAllAsset, required this.addAsset})
    : super(AssetInitial()) {
    on<LoadAssetEvent>(_onGetAllAsset);
    on<AddAssetEvent>(_onAddAsset);
  }

  Future<void> _onGetAllAsset(
    LoadAssetEvent event,
    Emitter<AssetState> emit,
  ) async {
    emit(AssetLoading());
    final assets = await getAllAsset(NoParams());
    assets.fold(
      (failures) => emit(AssetError(MapFailureToMessage.map(failures))),
      (asset) => emit(AssetLoaded(asset)),
    );
  }

  Future<void> _onAddAsset(
    AddAssetEvent event,
    Emitter<AssetState> emit,
  ) async {
    emit(AssetCreating());
    final asset = await addAsset(event.asset);
    asset.fold(
      (failures) => emit(AssetCreateError(MapFailureToMessage.map(failures))),
      (asset) => emit(AssetCreated(asset)),
    );
  }
}
