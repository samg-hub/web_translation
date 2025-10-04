import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web_translation/api/models/toast_message_model.dart';

final toastMessageProvider = StateProvider<ToastMessageModel?>((ref) => null);
