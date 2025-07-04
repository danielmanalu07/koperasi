import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:koperasi/core/networks/network_info.dart';
import 'package:koperasi/core/utils/local_dataSource.dart';
import 'package:koperasi/features/riwayat_pembayaran/data/datasources/bayar_remote_dataSource.dart';
import 'package:koperasi/features/riwayat_pembayaran/data/datasources/riwayat_pemabayaran_remote_dataSource.dart';
import 'package:koperasi/features/riwayat_pembayaran/data/repositories/bayar_repository_impl.dart';
import 'package:koperasi/features/riwayat_pembayaran/data/repositories/riwayat_pembayaran_repository_impl.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/repositories/bayar_repository.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/repositories/riwayat_pembayaran_repository.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/usecases/create_bayar_tagihan_usecase.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/usecases/get_riwayat_pembayaran_usecase.dart';
import 'package:koperasi/features/riwayat_pembayaran/presentation/bloc/bayar_tagihan/bayar_tagihan_bloc.dart';
import 'package:koperasi/features/riwayat_pembayaran/presentation/bloc/riwayat_pembayaran_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

final sl = GetIt.instance;

void init() async {
  //Bloc
  sl.registerFactory(
    () => RiwayatPembayaranBloc(getRiwayatPembayaranUsecase: sl()),
  );
  sl.registerFactory(() => BayarTagihanBloc(createBayarTagihanUsecase: sl()));

  //Usecase
  sl.registerLazySingleton(() => GetRiwayatPembayaranUsecase(sl()));
  sl.registerLazySingleton(() => CreateBayarTagihanUsecase(sl()));

  //Repository
  sl.registerLazySingleton<RiwayatPembayaranRepository>(
    () => RiwayatPembayaranRepositoryImpl(
      riwayatPemabayaranRemoteDatasource: sl(),
      localDatasource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<BayarRepository>(
    () => BayarRepositoryImpl(
      bayarRemoteDatasource: sl(),
      localDatasource: sl(),
      networkInfo: sl(),
    ),
  );

  //Remote Data Source
  sl.registerLazySingleton<RiwayatPemabayaranRemoteDatasource>(
    () => RiwayatPemabayaranRemoteDatasourceImpl(sl()),
  );
  sl.registerLazySingleton<BayarRemoteDatasource>(
    () => BayarRemoteDatasourceImpl(sl()),
  );

  //Local Data Source
  sl.registerLazySingleton<LocalDatasource>(() => LocalDatasourceImpl(sl()));

  //core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  // sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton<http.Client>(() => http.Client()); // <-- CORRECTED
  sl.registerLazySingleton(() => Connectivity());
}
