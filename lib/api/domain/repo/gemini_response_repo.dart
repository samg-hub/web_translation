import 'package:dartz/dartz.dart';
import 'package:web_translation/api/models/gemini_body_model.dart';
import 'package:web_translation/api/models/gemini_response_model.dart';
import 'package:web_translation/api/util/api_exception_handler.dart';

abstract class GeminiResponseRepository {
  Future<Either<ApiExceptionHandler, GeminiResponseModel>> geminiInfo(
    GeminiBodyModel? body,
  );
}
