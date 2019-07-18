import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutterhole/model/pihole.dart';
import 'package:flutterhole/service/browser.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/widget/layout/icon_text_button.dart';
import 'package:flutterhole/widget/layout/list_tab.dart';
import 'package:qrcode_reader/qrcode_reader.dart';

class PiholeEditForm extends StatefulWidget {
  final Pihole original;

  const PiholeEditForm({Key key, @required this.original}) : super(key: key);

  @override
  _PiholeEditFormState createState() => _PiholeEditFormState();
}

class _PiholeEditFormState extends State<PiholeEditForm> {
  Pihole pihole;

  final _formKey = GlobalKey<FormState>();
  final _localStorage = Globals.localStorage;

  TextEditingController titleController = TextEditingController();
  TextEditingController hostController = TextEditingController();
  TextEditingController apiPathController = TextEditingController();
  TextEditingController portController = TextEditingController();
  TextEditingController authController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      pihole = widget.original;
    });
    _resetControllers();
  }

  Future _resetControllers() async {
    titleController.text = widget.original.title;
    hostController.text = widget.original.host;
    apiPathController.text = widget.original.apiPath;
    portController.text = widget.original.port.toString();
    authController.text = widget.original.auth;
  }

  Future<void> _save(Pihole update) async {
    await _localStorage.update(pihole, update);
  }

  String _validateTitle(String val) {
    if (val != pihole.title &&
        _localStorage.cache.containsKey(Pihole.toKey(val))) {
      return 'This title is already in use';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_localStorage == null) {
      return Center(child: CircularProgressIndicator());
    } else {
      final String apiTokenUrl = '${pihole.baseUrl}/admin/settings.php?tab=api';
      return SafeArea(
        minimum: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: titleController,
                autofocus: pihole.title.isEmpty,
                decoration: InputDecoration(
                    labelText: 'Configuration name',
                    errorText: _validateTitle(titleController.text)),
              ),
              TextField(
                controller: hostController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(labelText: 'Host'),
                onChanged: (v) {
                  if (v.length > 0 && pihole.title.length > 0) {
                    final update = Pihole.copyWith(pihole, host: v);
                    setState(() {
                      pihole = update;
                    });
                  }
                },
              ),
              TextField(
                controller: apiPathController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: 'API path'),
                onChanged: (v) {
                  if (v.length > 0 && pihole.title.length > 0) {
                    final update = Pihole.copyWith(pihole, apiPath: v);
                    setState(() {
                      pihole = update;
                    });
                  }
                },
              ),
              TextField(
                controller: portController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  WhitelistingTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: InputDecoration(labelText: 'Port'),
                onChanged: (v) {
                  if (v.length > 0 && pihole.title.length > 0) {
                    final update = Pihole.copyWith(pihole, port: int.parse(v));
                    setState(() {
                      pihole = update;
                    });
                  }
                },
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: authController,
                      keyboardType: TextInputType.url,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'API token',
                      ),
                      onChanged: (v) {
                        if (v.length > 0 && pihole.title.length > 0) {
                          final update = Pihole.copyWith(pihole, auth: v);
                          setState(() {
                            pihole = update;
                          });
                        }
                      },
                    ),
                  ),
                  IconTextButton(
                    title: 'Scan QR code',
                    icon: Icons.camera_alt,
                    onPressed: () async {
                      try {
                        String qr = await QRCodeReader()
                            .setAutoFocusIntervalInMs(200)
                            .scan();
                        authController.text = qr;
                      } catch (e) {
                        Fimber.w('cannot scan QR code', ex: e);
                      }
                    },
                  ),
                ],
              ),
              Tooltip(
                message: 'Open in browser',
                child: InkWell(
                  onTap: () {
                    launchURL(apiTokenUrl);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: RichText(
                      text: TextSpan(
                          style: Theme
                              .of(context)
                              .textTheme
                              .caption,
                          text:
                          'The API token can be found on the admin dashboard at Settings > API / Web interface (example: ',
                          children: [
                            TextSpan(
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .caption
                                    .copyWith(color: Colors.blueAccent),
                                text: apiTokenUrl,
                                children: [
                                  TextSpan(
                                      style:
                                      Theme
                                          .of(context)
                                          .textTheme
                                          .caption,
                                      text: ').')
                                ]),
                          ]),
//                  'The API token can be found on the admin dashboard at Settings > API / Web interface (example: ${pihole.baseUrl}/admin/settings.php?tab=api).',
                    ),
                  ),
                ),
              ),
              ListTab('Advanced'),
              FormBuilderSwitch(
                initialValue: widget.original.allowSelfSigned,
                decoration: InputDecoration(prefixIcon: Icon(Icons.lock_open)),
                label: Text('Allow self-signed certificates'),
                attribute: 'attribute',
                onChanged: (v) {
                  final update = Pihole.copyWith(pihole, allowSelfSigned: v);
                  setState(() {
                    pihole = update;
                  });
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Trust certificates, even when the TLS handshake fails.',
                  style: Theme
                      .of(context)
                      .textTheme
                      .caption,
                ),
              ),
//              ExpansionTile(
//                title: Text('Advanced'),
//                children: <Widget>[
//                  Text('hi'),
//                  Text('hi'),
//                ],
//              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: <Widget>[
                    IconTextButton(
                      onPressed: () async {
                        final String v = titleController.text;
                        if (v.length > 0 &&
                            _formKey.currentState.validate() &&
                            _validateTitle(v) == null) {
                          _formKey.currentState.save();
                          final update = Pihole.copyWith(pihole,
                              title: titleController.text);
                          print('save: $update');
                          await _save(update);
                          setState(() {
                            pihole = update;
                          });
                          _pop(context);
                        }
                      },
                      title: 'Save',
                      icon: Icons.save,
                      color: Colors.green,
                    ),
                    IconTextButton(
                      onPressed: () async {
                        await _resetControllers();
                      },
                      title: 'Reset',
                      icon: Icons.delete_forever,
                      color: Colors.red,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _pop(BuildContext context) {
    if (widget.original != null) {
      Navigator.of(context).pop('Edited ${pihole.title}');
    } else {
      Navigator.of(context).pop('Added ${pihole.title}');
    }
  }
}
