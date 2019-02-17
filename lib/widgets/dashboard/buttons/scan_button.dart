import 'package:flutter/material.dart';
import 'package:qrcode_reader/qrcode_reader.dart';

/// A button that enabled the QR scanner on tap.
class ScanButton extends StatelessWidget {
  /// The controller to send the QR code output to.
  final TextEditingController controller;

  const ScanButton({Key key, @required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(Icons.photo_camera),
          ),
          Text('Scan QR code')
        ],
      ),
      onPressed: () {
        Future<String> futureString = new QRCodeReader().scan();
        futureString.then((String result) {
          if (result != null) {
            controller.text = result;
          }
        });
      },
    );
  }
}
