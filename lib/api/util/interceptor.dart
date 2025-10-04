import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:web_translation/api/domain/resouse/data_state.dart';
import 'package:web_translation/api/util/api_exception_handler.dart';
import 'package:web_translation/api/util/logger.dart';

bool isMaintaining = false;

List<FailedRequest> _failedRequestStack = [];

class FailedRequest {
  final DioException err;
  final ErrorInterceptorHandler handler;

  FailedRequest({required this.err, required this.handler});
}

class MyInterceptor extends Interceptor {
  final Dio dio;

  MyInterceptor({required this.dio});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (isMaintaining) {
      return;
    }

    final newOptions = options.copyWith(
      sendTimeout: const Duration(minutes: 3),
      connectTimeout: const Duration(minutes: 3),
      receiveTimeout: const Duration(minutes: 3),
    );
    newOptions.receiveDataWhenStatusError = true;

    newOptions.headers.removeWhere(
      (key, value) => key == HttpHeaders.contentTypeHeader,
    );
    if (options.baseUrl == "https://generativelanguage.googleapis.com/v1beta") {
      newOptions.headers.addAll({
        'x-goog-api-key': "AIzaSyCinCthzNMu8_DmdiONNpSbUKUWza2nXDo",
        HttpHeaders.contentTypeHeader: "application/json",
      });
    } else {
      newOptions.headers.addAll({
        HttpHeaders.contentTypeHeader: "application/json",
      });
    }

    //check if user log in then get accessToken & add authorizationHeader to Apis
    //

    printRequest(newOptions);

    handler.next(newOptions);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    printOnResponse(response);
    logger("Response:  ${response.statusCode}");
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    onErrorPrint(err);

    handler.next(err);
  }

  void addToFailedStack({
    required DioException err,
    required ErrorInterceptorHandler handler,
  }) {
    if (_failedRequestStack.indexWhere(
          (element) =>
              element.err.requestOptions.path == err.requestOptions.path,
        ) ==
        -1) {
      _failedRequestStack.add(FailedRequest(err: err, handler: handler));
    }
  }

  void resetRefreshing() {
    _failedRequestStack.clear();
  }

  Future<void> retryFailedRequests() async {
    for (final failedRequest in _failedRequestStack) {
      try {
        logger(
          "401: retry Failed Request : ${failedRequest.err.requestOptions.path}",
        );
        final response = await RetryRequest().retryRequest(
          failedRequest.err.requestOptions,
        );
        logger(
          "401: retry Failed Request Response (${failedRequest.err.requestOptions.path}) : $response",
        );
        if (response.stateChecker == StateCheckerEnum.done) {
          failedRequest.handler.resolve(
            Response(
              requestOptions: failedRequest.err.requestOptions,
              data: response.data,
            ),
          );
        } else if (response.stateChecker == StateCheckerEnum.failed) {
          failedRequest.handler.next(
            failedRequest.err.copyWith(message: "Cant Refresh Token!!"),
          );
        }
      } catch (e) {
        logger(e);
      }
    }
    _failedRequestStack.clear();
  }
}

class RetryRequest {
  late Dio _dio;

  RetryRequest() {
    _dio = Dio();
  }

  Future<DataState<dynamic>> retryRequest(RequestOptions requestOptions) async {
    try {
      final request = await _dio.request(
        requestOptions.baseUrl + requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: Options(
          method: requestOptions.method,
          extra: requestOptions.extra,
          headers: requestOptions.headers,
          receiveDataWhenStatusError: true,
          responseDecoder: requestOptions.responseDecoder,
          requestEncoder: requestOptions.requestEncoder,
          responseType: requestOptions.responseType,
          contentType: requestOptions.contentType,
          receiveTimeout: requestOptions.receiveTimeout,
          sendTimeout: requestOptions.sendTimeout,
        ),
      );
      return DataSuccess(request);
    } on DioException catch (e) {
      return DataFailed(ApiExceptionHandler(dioException: e));
    }
  }
}
