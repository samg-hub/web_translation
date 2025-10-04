import 'package:dartz/dartz.dart';
import 'package:web_translation/api/domain/repo/gemini_response_repo.dart';
import 'package:web_translation/api/domain/resouse/usecase.dart';
import 'package:web_translation/api/models/gemini_body_model.dart';
import 'package:web_translation/api/models/gemini_response_model.dart';
import 'package:web_translation/api/util/api_exception_handler.dart';

class GeminiUsecase
    implements
        UseCase<
          Either<ApiExceptionHandler, GeminiResponseModel>,
          GeminiBodyModel
        > {
  final GeminiResponseRepository _repo;

  GeminiUsecase(this._repo);
  @override
  Future<Either<ApiExceptionHandler, GeminiResponseModel>> call({
    GeminiBodyModel? params,
  }) {
    return _repo.geminiInfo(params);
  }
}
