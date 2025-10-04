import 'package:web_translation/api/util/api_exception_handler.dart';

//DataState
enum StateCheckerEnum { loading, done, failed, initial }

abstract class DataState<T> {
  final T? data;
  final ApiExceptionHandler? error;
  final StateCheckerEnum? stateChecker;
  const DataState({this.data, this.error, this.stateChecker});
}

class DataInitial<T> extends DataState<T> {
  const DataInitial() : super(stateChecker: StateCheckerEnum.initial);
}

class DataLoading<T> extends DataState<T> {
  const DataLoading() : super(stateChecker: StateCheckerEnum.loading);
}

class DataSuccess<T> extends DataState<T> {
  const DataSuccess(T data)
    : super(data: data, stateChecker: StateCheckerEnum.done);
}

class DataFailed<T> extends DataState<T> {
  DataFailed(ApiExceptionHandler error)
    : super(error: error, stateChecker: StateCheckerEnum.failed);
}
