import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

void logger(Object? txt, {String? sub}) {
  // if (kDebugMode) {
  if (kDebugMode != true) {
    return;
  }
  String printTxt = "Hiddify: $txt";
  if (printTxt.length >= 25000) {
    printTxt = printTxt.substring(0, 25000);
  }
  print(printTxt);
}

String getPrettyJSONString(jsonObject) {
  const encoder = JsonEncoder.withIndent("  ");
  return encoder.convert(jsonObject);
}

//-------------------------------------------------------------- Interceptor

void printRequest(RequestOptions options) {
  logger(
    """Request\nPath: "${options.uri}"
    ${options.queryParameters.isEmpty ? "" : "\n query Parametrs: ${options.queryParameters}"}
    ${options.headers.isNotEmpty ? ""
        "\nMethod: ${options.method}\nHeaders:"
        "\n${getPrettyJSONString(options.headers)}" : ""}${options.data != null ? ""
        "\nBody:\n${options.data is FormData ? options.data : getPrettyJSONString(options.data)} " : ""}""",
  );
}

void printOnResponse(Response<dynamic> response) {
  logger('Response for ${response.requestOptions.method} "${response.requestOptions.path}":\n${getPrettyJSONString(response.data)}');
}

void onErrorPrint(DioException err) {
  logger(
    '${err.message}\nStatusCode=${err.response?.statusCode}\nPath="${err.requestOptions.path}'
    "\nMethod=${err.requestOptions.method}\nResponse:\n${err.response?.data}",
  );
}
