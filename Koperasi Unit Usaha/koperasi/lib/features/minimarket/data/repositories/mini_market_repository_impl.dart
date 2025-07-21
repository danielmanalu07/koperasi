import 'package:koperasi/core/networks/network_info.dart';
import 'package:koperasi/features/minimarket/data/dataSources/mini_market_remote_datasource.dart';
import 'package:koperasi/features/minimarket/domain/repositories/mini_market_repository.dart';

class MiniMarketRepositoryImpl implements MiniMarketRepository {
  final MiniMarketRemoteDatasource miniMarketRemoteDatasource;
  final NetworkInfo networkInfo;

  const MiniMarketRepositoryImpl({
    required this.miniMarketRemoteDatasource,
    required this.networkInfo,
  });

  @override
  Future<Map<String, dynamic>> getMiniMarketData() async {
    final response = await miniMarketRemoteDatasource.getMiniMarketData();

    return response['data'] as Map<String, dynamic>;
  }
}
