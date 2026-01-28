import 'package:chat_app/features/chat/data/datasources/local/chat_local_data_source.dart';
import 'package:chat_app/features/chat/data/datasources/remote/chat_remote_data_source.dart';
import 'package:chat_app/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:chat_app/features/chat/domain/usecases/create_conversion_by_email.dart';
import 'package:chat_app/features/chat/domain/usecases/get_conversation.dart';
import 'package:chat_app/features/chat/domain/usecases/listen_messge.dart';
import 'package:chat_app/features/chat/domain/usecases/retry_pending_message.dart';
import 'package:chat_app/features/chat/domain/usecases/send_message.dart';
import 'package:chat_app/features/chat/domain/usecases/mark_delivered.dart';
import 'package:chat_app/features/chat/presentation/bloc/chat/chat_bloc.dart';
import 'package:chat_app/features/chat/presentation/bloc/conversation/conversation_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_user.dart';
import '../../features/auth/domain/usecases/register_user.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/logout_user.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  /// External
  sl.registerLazySingleton(() => Supabase.instance.client);

  /// Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  /// Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  /// Usecases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));

  /// BLoC
  sl.registerFactory(
    () => AuthBloc(
      loginUser: sl(),
      registerUser: sl(),
      getCurrentUser: sl(),
      logoutUser: sl(),
    ),
  );

  //chat
  /// -----------------------------
  /// EXTERNAL
  /// -----------------------------
  sl.registerLazySingleton(() => Connectivity());

  await Hive.initFlutter();
  final box = await Hive.openBox('pending_messages');
  sl.registerLazySingleton(() => box);

  /// -----------------------------
  /// DATA SOURCES
  /// -----------------------------
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<ChatLocalDataSource>(
    () => ChatLocalDataSourceImpl(sl()),
  );

  /// -----------------------------
  /// REPOSITORY
  /// -----------------------------
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remote: sl(), local: sl(), client: sl()),
  );

  /// -----------------------------
  /// USE CASES
  /// -----------------------------
  sl.registerLazySingleton(() => ListenMessages(sl()));
  sl.registerLazySingleton(() => SendMessage(sl()));
  sl.registerLazySingleton(() => RetryPendingMessages(sl()));
  sl.registerLazySingleton(() => MarkDelivered(sl()));
  sl.registerLazySingleton(() => GetConversations(sl()));
  sl.registerLazySingleton(() => CreateConversationByEmail(sl()));

  /// -----------------------------
  /// BLOC
  /// -----------------------------
  sl.registerFactory(() => ChatBloc(sl(), sl(), sl(), sl(), sl()));
  sl.registerFactory(() => ConversationBloc(sl(), sl()));
}
