import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:flutterhole/features/settings/services/qr_scan_service.dart';

class ApiTokenFormTile extends StatefulWidget {
  const ApiTokenFormTile({
    Key key,
    @required this.initialValue,
    this.decoration = const InputDecoration(),
  }) : super(key: key);

  final PiholeSettings initialValue;
  final InputDecoration decoration;

  @override
  _ApiTokenFormTileState createState() => _ApiTokenFormTileState();
}

class _ApiTokenFormTileState extends State<ApiTokenFormTile> {
  TextEditingController _apiTokenController;
  bool _apiTokenVisible;

  @override
  void initState() {
    super.initState();
    _apiTokenController =
        TextEditingController(text: widget.initialValue.apiToken);
    _apiTokenVisible = false;
  }

  void _scanQrCode() async {
    final String apiToken = await getIt<QrScanService>().scanPiholeApiTokenQR();
    if (apiToken.isNotEmpty) {
      setState(() {
        _apiTokenController.text = apiToken;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: FormBuilderTextField(
        attribute: 'apiToken',
        controller: _apiTokenController,
        decoration: widget.decoration.copyWith(
          labelText: 'API token',
          helperText:
              'The API token can be found on the admin home at "Settings > API / Web interface". \nRequired for authenticated tasks, such as enabling & disabling.',
          helperMaxLines: 5,
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                tooltip: 'Toggle visibility',
                icon: Icon(
                  _apiTokenVisible
                      ? KIcons.visibility_on
                      : KIcons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _apiTokenVisible = !_apiTokenVisible;
                  });
                },
              ),
              IconButton(
                tooltip: 'Scan QR code',
                icon: Icon(KIcons.qrCode),
                onPressed: _scanQrCode,
              ),
            ],
          ),
        ),
        autocorrect: false,
        maxLines: 1,
        obscureText: !_apiTokenVisible,
        valueTransformer: (value) => (value ?? '').toString().trim(),
      ),
    );
  }
}
