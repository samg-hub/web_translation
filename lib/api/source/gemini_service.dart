import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:web_translation/api/models/gemini_response_model.dart';

part 'gemini_service.g.dart';

@RestApi(baseUrl: "https://generativelanguage.googleapis.com/v1beta")
abstract class GeminiService {
  factory GeminiService(Dio dio) = _GeminiService;

  @POST('/models/gemini-2.5-flash:generateContent')
  Future<HttpResponse<GeminiResponseModel>> geminiFetch(
    @Body() Map<String, dynamic> data,
  );
}
