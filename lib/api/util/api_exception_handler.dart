// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: constant_identifier_names
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web_translation/api/models/toast_message_model.dart';
import 'package:web_translation/api/util/toast_message_provider.dart';

class ApiExceptionHandler {
  ApiExceptionHandler({this.dioException, this.messageException, this.ref}) {
    if (ref != null && statusCode != 500) {
      try {
        if (errorsMassage != null) {
          ref?.read(toastMessageProvider.notifier).state = ToastMessageModel(
            message: errorsMassage,
          );
        } else if (responseData['message'] != null) {
          ref?.read(toastMessageProvider.notifier).state = ToastMessageModel(
            message: responseData['message'] as String?,
          );
        } else {
          ref?.read(toastMessageProvider.notifier).state = ToastMessageModel(
            message: 'Connection Failed, Try again later!',
          );
        }
      } catch (e) {
        ref?.read(toastMessageProvider.notifier).state = ToastMessageModel(
          title: 'Connection Error',
          message: 'Connection Failed, Try again later!',
        );
      }
    }

    if (ref != null && statusCode == 500) {
      ref?.read(toastMessageProvider.notifier).state = ToastMessageModel(
        title: 'Failed',
        message: 'Server is busy now,try again later!',
        type: ToastTypeEnum.error,
      );
    }
    print;
  }
  final DioException? dioException;
  final String? messageException;
  final Ref? ref;

  String? get errorsMassage {
    try {
      String data = '';
      final errors = responseData['errors'];
      if (errors is Object) {
        final value = errors as Map<String, dynamic>;
        for (final element in value.values.first as List<dynamic>) {
          data += "${element ?? ''}\n";
        }
      } else {
        (errors as Map<String, dynamic>).values.map((e) {
          for (final element in e as List<dynamic>) {
            data += "${element ?? ''}\n";
          }
          return e.map((e) => '$e\n');
        });
      }

      return data;
    } catch (e) {
      print(e);
      return null;
    }
  }

  DioException? get exception => dioException;

  Map<String, dynamic> get responseData =>
      exception?.response?.data as Map<String, dynamic>;

  int? get statusCode => exception?.response?.statusCode;

  String? get message =>
      messageException ??
      (exception?.message?.contains('The request connection took longer') ==
              true
          ? 'Connection Failed, Try Again later'
          : exception?.message);

  @override
  String toString() {
    if (dioException != null) {
      return 'ExceptionHandler: \n---[Dio Failed]\n---URL: ${dioException!.requestOptions.uri}'
          ' \n---headers: ${dioException?.requestOptions.headers} \n---Message: $message\n---StatusCode: $statusCode';
    }
    if (messageException != null) {
      return 'ExceptionHandler: \n---[Exception Message]\n---Message: $messageException';
    }
    return 'ExceptionHandler: unknown Error!';
  }

  ApiExceptionHandler copyWith({
    DioException? dioException,
    String? messageException,
    Ref? ref,
  }) {
    return ApiExceptionHandler(
      dioException: dioException ?? this.dioException,
      messageException: messageException ?? this.messageException,
      ref: ref ?? this.ref,
    );
  }
}
