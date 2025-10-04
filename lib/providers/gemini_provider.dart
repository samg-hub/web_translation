import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:web_translation/api/domain/resouse/data_state.dart';
import 'package:web_translation/api/models/gemini_body_model.dart';
import 'package:web_translation/api/models/gemini_response_model.dart';
import 'package:web_translation/api/usecase/app_info_usecase.dart';
import 'package:web_translation/api/util/injection_container.dart';

part 'gemini_provider.g.dart';

@riverpod
class Gemini extends _$Gemini {
  @override
  DataState<GeminiResponseModel> build(String? key) {
    return DataInitial();
  }

  Future<void> ask(List<Parts>? parts) async {
    state = DataLoading();
    final result = await getIt<GeminiUsecase>().call(
      params: GeminiBodyModel(contents: [Contents(parts: parts)]),
    );
    state = result.fold((l) => DataFailed(l), (r) => DataSuccess(r));
  }
}

final languageProvider = StateProvider<String?>((ref) => null);
