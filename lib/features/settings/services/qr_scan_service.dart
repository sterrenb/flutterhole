import 'package:barcode_scan/barcode_scan.dart';
import 'package:injectable/injectable.dart';

@prod
@singleton
class QrScanService {
  Future<String> scanPiholeApiTokenQR() async {
    var result = await BarcodeScanner.scan();
    return result.rawContent?.trim() ?? '';
  }
}
