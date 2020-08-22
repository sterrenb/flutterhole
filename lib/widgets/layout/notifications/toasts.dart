import 'package:fluttertoast/fluttertoast.dart';

enum ToastPosition {
  Top,
  Bottom,
}

ToastGravity _ToastPositionToToastGravity(ToastPosition position) {
  switch (position) {
    case ToastPosition.Top:
      return ToastGravity.TOP;
    case ToastPosition.Bottom:
    default:
      return ToastGravity.BOTTOM;
  }
}

Future<void> cancelToast() => Fluttertoast?.cancel();

Future<void> ssshowToast(
  String message, {
  ToastPosition position = ToastPosition.Bottom,
}) async {
  Fluttertoast?.cancel();
  Fluttertoast.showToast(
    msg: message ?? '',
    gravity: _ToastPositionToToastGravity(position),
  );
}
