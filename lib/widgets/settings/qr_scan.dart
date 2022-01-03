import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterhole/widgets/layout/dialogs.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScanDialog extends StatefulWidget {
  const QrScanDialog({
    Key? key,
  }) : super(key: key);

  @override
  _QrScanDialogState createState() => _QrScanDialogState();
}

class _QrScanDialogState extends State<QrScanDialog> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  void onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    int i = 0;
    controller.scannedDataStream.listen((scanData) {
      if (mounted && i == 0) {
        debugPrint("Popping x$i!");
        Navigator.of(context).pop(scanData.code);
        i++;
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanArea = (MediaQuery.of(context).size.width < 600 ||
            MediaQuery.of(context).size.height < 600)
        ? 300.0
        : 500.0;

    return QRView(
      key: qrKey,
      onQRViewCreated: onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Theme.of(context).colorScheme.primary,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
    );
  }
}
