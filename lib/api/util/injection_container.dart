import 'package:curl_logger_dio_interceptor/curl_logger_dio_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:web_translation/api/domain/repo/gemini_response_repo.dart';
import 'package:web_translation/api/repository/gemini_response_impl.dart';
import 'package:web_translation/api/source/gemini_service.dart';
import 'package:web_translation/api/usecase/app_info_usecase.dart';
import 'package:web_translation/api/util/interceptor.dart';

final getIt = GetIt.instance;

//Factory -> NewInstance every Time
//Singleton ->  return intstance of class
Future<void> initializeDependencies({BuildContext? context}) async {
  getIt.registerLazySingleton(() => MyInterceptor(dio: Dio()));
  //Dio
  getIt.registerLazySingleton<Dio>(
    () => Dio()
      ..interceptors.add(getIt<MyInterceptor>())
      ..interceptors.add(CurlLoggerDioInterceptor(printOnSuccess: true)),
  );

  //Dependencies
  getIt.registerLazySingleton<GeminiService>(() => GeminiService(getIt()));

  //Repositories
  getIt.registerLazySingleton<GeminiResponseRepository>(
    () => GeminiResponseRepositoryImpl(getIt()),
  );

  //UseCases
  getIt.registerLazySingleton<GeminiUsecase>(() => GeminiUsecase(getIt()));
}
