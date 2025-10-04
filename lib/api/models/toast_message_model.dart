// ignore_for_file: public_member_api_docs, sort_constructors_first

enum ToastTypeEnum { success, alert, error }

class ToastMessageModel {
  final int uniqueNumber;
  final ToastTypeEnum? type;
  final String? message;
  final String? title;
  final int? duration;

  static int _counter = 0;

  ToastMessageModel._internal({this.message, this.type, this.title, this.duration}) : uniqueNumber = ++_counter;

  factory ToastMessageModel({String? message, ToastTypeEnum? type, String? title, int? duration}) {
    return ToastMessageModel._internal(
      message: message,
      type: type,
      duration: duration,
      title: title,
    );
  }

  @override
  bool operator ==(covariant ToastMessageModel other) {
    if (identical(this, other)) return true;

    return other.type == type && other.message == message && other.duration == duration && other.title == title;
  }

  @override
  int get hashCode => type.hashCode ^ message.hashCode ^ title.hashCode;
}
