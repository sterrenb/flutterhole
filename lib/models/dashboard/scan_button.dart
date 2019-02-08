import 'package:flutter/material.dart';
import 'package:qrcode_reader/qrcode_reader.dart';

class ScanButton extends StatelessWidget {
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
