import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:koperasi/core/networks/network_info.dart';
import 'package:koperasi/core/utils/local_dataSource.dart';
import 'package:koperasi/features/minimarket/data/dataSources/mini_market_remote_datasource.dart';
import 'package:koperasi/features/minimarket/data/repositories/mini_market_repository_impl.dart';
import 'package:koperasi/features/minimarket/domain/repositories/mini_market_repository.dart';
import 'package:koperasi/features/minimarket/domain/usecases/get_mini_market_data.dart';
import 'package:koperasi/features/minimarket/presentation/bloc/mini_market_bloc.dart';
import 'package:koperasi/features/notifications/data/dataSources/notification_remote_dataSource.dart';
import 'package:koperasi/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:koperasi/features/notifications/domain/repositories/notification_repository.dart';
import 'package:koperasi/features/notifications/domain/usecases/get_notification_usecase.dart';
import 'package:koperasi/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:koperasi/features/riwayat_pembayaran/data/datasources/bayar_remote_dataSource.dart';
import 'package:koperasi/features/riwayat_pembayaran/data/datasources/pinjaman_remaining_remote_dataSource.dart';
import 'package:koperasi/features/riwayat_pembayaran/data/datasources/riwayat_pemabayaran_remote_dataSource.dart';
import 'package:koperasi/features/riwayat_pembayaran/data/repositories/bayar_repository_impl.dart';
import 'package:koperasi/features/riwayat_pembayaran/data/repositories/pinjaman_remaining_repository_impl.dart';
import 'package:koperasi/features/riwayat_pembayaran/data/repositories/riwayat_pembayaran_repository_impl.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/repositories/bayar_repository.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/repositories/pinjaman_remaining_repository.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/repositories/riwayat_pembayaran_repository.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/usecases/create_bayar_tagihan_usecase.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/usecases/get_pinjaman_remaining_usecase.dart';
import 'package:koperasi/features/riwayat_pembayaran/domain/usecases/get_riwayat_pembayaran_usecase.dart';
import 'package:koperasi/features/riwayat_pembayaran/presentation/bloc/bayar_tagihan/bayar_tagihan_bloc.dart';
import 'package:koperasi/features/riwayat_pembayaran/presentation/bloc/pinjaman_remaining/pinjaman_remaining_bloc.dart';
import 'package:koperasi/features/riwayat_pembayaran/presentation/bloc/riwayat_pembayaran_bloc.dart';
import 'package:koperasi/features/sewa_menyewa/data/dataSources/asset_remote_data_source.dart';
import 'package:koperasi/features/sewa_menyewa/data/dataSources/dashboard_remote_data_source.dart';
import 'package:koperasi/features/sewa_menyewa/data/dataSources/expense_remote_data_source.dart';
import 'package:koperasi/features/sewa_menyewa/data/dataSources/transaction_remote_dataSource.dart';
import 'package:koperasi/features/sewa_menyewa/data/repositories/expense/expense_repository_impl.dart';
import 'package:koperasi/features/sewa_menyewa/data/repositories/Transaction/transaction_repository_impl.dart';
import 'package:koperasi/features/sewa_menyewa/data/repositories/asset_repository_impl.dart';
import 'package:koperasi/features/sewa_menyewa/data/repositories/dashboard_repository_impl.dart';
import 'package:koperasi/features/sewa_menyewa/domain/repositories/asset_repository.dart';
import 'package:koperasi/features/sewa_menyewa/domain/repositories/dashboard_repository.dart';
import 'package:koperasi/features/sewa_menyewa/domain/repositories/expense_repository.dart';
import 'package:koperasi/features/sewa_menyewa/domain/repositories/transaction_repository.dart';
import 'package:koperasi/features/sewa_menyewa/domain/usecase/expense/add_expense_usecase.dart';
import 'package:koperasi/features/sewa_menyewa/domain/usecase/expense/delete_expense_usecase.dart';
import 'package:koperasi/features/sewa_menyewa/domain/usecase/expense/get_expenses_usecase.dart';
import 'package:koperasi/features/sewa_menyewa/domain/usecase/expense/update_expense_usecase.dart';
import 'package:koperasi/features/sewa_menyewa/domain/usecase/Transaction/add_transaction_usecase.dart';
import 'package:koperasi/features/sewa_menyewa/domain/usecase/Transaction/get_transaction_usecase.dart';
import 'package:koperasi/features/sewa_menyewa/domain/usecase/add_asset_data.dart';
import 'package:koperasi/features/sewa_menyewa/domain/usecase/get_all_asset.dart';
import 'package:koperasi/features/sewa_menyewa/domain/usecase/get_dashboard_data.dart';
import 'package:koperasi/features/sewa_menyewa/presentation/bloc/Asset/asset_bloc.dart';
import 'package:koperasi/features/sewa_menyewa/presentation/bloc/expense/expense_bloc.dart';
import 'package:koperasi/features/sewa_menyewa/presentation/bloc/Transaction/transaction_bloc.dart';
import 'package:koperasi/features/sewa_menyewa/presentation/bloc/dashboard_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(() => Connectivity());
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Register http.Client specifically for injection into named parameters
  sl.registerLazySingleton<http.Client>(
    () => http.Client(),
  ); // <-- MODIFIED THIS LINE

  //core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  //Local Data Source
  sl.registerLazySingleton<LocalDatasource>(() => LocalDatasourceImpl(sl()));

  //Remote Data Source
  sl.registerLazySingleton<RiwayatPemabayaranRemoteDatasource>(
    () => RiwayatPemabayaranRemoteDatasourceImpl(sl()),
  );
  sl.registerLazySingleton<BayarRemoteDatasource>(
    () => BayarRemoteDatasourceImpl(sl()),
  );
  sl.registerLazySingleton<PinjamanRemainingRemoteDatasource>(
    () => PinjamanRemainingRemoteDatasourceImpl(sl()),
  );
  sl.registerLazySingleton<NotificationRemoteDatasource>(
    () => NotificationRemoteDatasourceImpl(sl()),
  );
  sl.registerLazySingleton<MiniMarketRemoteDatasource>(
    () => MiniMarketRemoteDatasourceimpl(),
  );
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<AssetRemoteDataSource>(
    () => AssetRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<TransactionRemoteDatasource>(
    () => TransactionRemoteDatasourceImpl(client: sl()),
  );
  sl.registerLazySingleton<ExpenseRemoteDataSource>(
    () => ExpenseRemoteDataSourceImpl(client: sl()),
  );

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
  sl.registerLazySingleton<PinjamanRemainingRepository>(
    () => PinjamanRemainingRepositoryImpl(
      pinjamanRemainingRemoteDatasource: sl(),
      localDatasource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      notificationRemoteDatasource: sl(),
      localDatasource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<MiniMarketRepository>(
    () => MiniMarketRepositoryImpl(
      networkInfo: sl(),
      miniMarketRemoteDatasource: sl(),
    ),
  );
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      remoteDataSource: sl(),
      localDatasource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<AssetRepository>(
    () => AssetRepositoryImpl(assetRemoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(
      transactionRemoteDatasource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  //Usecase
  sl.registerLazySingleton(() => GetRiwayatPembayaranUsecase(sl()));
  sl.registerLazySingleton(() => CreateBayarTagihanUsecase(sl()));
  sl.registerLazySingleton(() => GetPinjamanRemainingUsecase(sl()));
  sl.registerLazySingleton(() => GetNotificationUsecase(sl()));
  sl.registerLazySingleton(() => GetMiniMarketData(sl()));
  sl.registerLazySingleton(() => GetDashboardData(sl()));
  sl.registerLazySingleton(() => GetAllAsset(sl()));
  sl.registerLazySingleton(() => AddAssetData(sl()));
  sl.registerLazySingleton(() => GetTransactionUsecase(sl()));
  sl.registerLazySingleton(() => AddTransactionUsecase(sl()));
  sl.registerLazySingleton(() => AddExpenseUsecase(sl()));
  sl.registerLazySingleton(() => GetExpensesUsecase(sl()));
  sl.registerLazySingleton(() => UpdateExpenseUsecase(sl()));
  sl.registerLazySingleton(() => DeleteExpenseUsecase(sl()));

  //Bloc
  sl.registerFactory(
    () => RiwayatPembayaranBloc(getRiwayatPembayaranUsecase: sl()),
  );
  sl.registerFactory(() => BayarTagihanBloc(createBayarTagihanUsecase: sl()));
  sl.registerFactory(
    () => PinjamanRemainingBloc(getPinjamanRemainingUsecase: sl()),
  );
  sl.registerFactory(() => NotificationBloc(getNotificationUsecase: sl()));
  sl.registerFactory(
    () => MiniMarketBloc(getMiniMarketData: sl(), remoteDatasource: sl()),
  );
  sl.registerFactory(() => DashboardBloc(getDashboardData: sl()));
  sl.registerFactory(() => AssetBloc(getAllAsset: sl(), addAsset: sl()));
  sl.registerFactory(
    () => TransactionBloc(
      getTransactionUsecase: sl(),
      addTransactionUsecase: sl(),
    ),
  );
  sl.registerFactory(
    () => ExpenseBloc(
      getExpensesUsecase: sl(),
      addExpenseUsecase: sl(),
      updateExpenseUsecase: sl(),
      deleteExpenseUsecase: sl(),
    ),
  );
}
