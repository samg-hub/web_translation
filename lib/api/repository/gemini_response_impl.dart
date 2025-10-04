import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:web_translation/api/domain/repo/gemini_response_repo.dart';
import 'package:web_translation/api/models/gemini_body_model.dart';
import 'package:web_translation/api/models/gemini_response_model.dart';
import 'package:web_translation/api/source/gemini_service.dart';
import 'package:web_translation/api/util/api_exception_handler.dart';

class GeminiResponseRepositoryImpl implements GeminiResponseRepository {
  final GeminiService _apiService;
  GeminiResponseRepositoryImpl(this._apiService);

  @override
  Future<Either<ApiExceptionHandler, GeminiResponseModel>> geminiInfo(
    GeminiBodyModel? body,
  ) async {
    try {
      final result = await _apiService.geminiFetch(body?.toJson() ?? {});
      return Right(result.data);
    } on TimeoutException {
      return Left(
        createExceptionHandler(
          error: 'Connection timeout',
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(),
        ),
      );
    } on DioException catch (e) {
      return Left(
        createExceptionHandler(
          error: e.message ?? 'Unexpected error occurred',
          type: DioExceptionType.badResponse,
          requestOptions: e.requestOptions,
        ),
      );
    } catch (e) {
      return Left(
        createExceptionHandler(
          error: 'Unexpected error occurred: $e',
          type: DioExceptionType.unknown,
          requestOptions: RequestOptions(),
        ),
      );
    }
  }

  ApiExceptionHandler createExceptionHandler({
    String? error,
    required DioExceptionType type,
    required RequestOptions requestOptions,
  }) {
    return ApiExceptionHandler(
      dioException: DioException(
        requestOptions: requestOptions,
        error: error,
        type: type,
      ),
    );
  }
}
