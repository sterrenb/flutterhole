import 'package:fluttertoast/fluttertoast.dart';

Future<void> showToast(String message) async {
  await Fluttertoast.cancel();
  Fluttertoast.showToast(msg: message ?? '');
}
