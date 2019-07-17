import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterhole_again/model/pihole.dart';
import 'package:flutterhole_again/service/globals.dart';
import 'package:flutterhole_again/widget/layout/icon_text_button.dart';
import 'package:qrcode_reader/qrcode_reader.dart';

class SinglePiholeView extends StatefulWidget {
  final Pihole original;

  const SinglePiholeView({Key key, @required this.original}) : super(key: key);

  @override
  _SinglePiholeViewState createState() => _SinglePiholeViewState();
}

class _SinglePiholeViewState extends State<SinglePiholeView> {
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
    _init();
  }

  Future _init() async {
    titleController.text = pihole.title;
    hostController.text = pihole.host;
    apiPathController.text = pihole.apiPath;
    portController.text = pihole.port.toString();
    authController.text = pihole.auth;
  }

  Future<void> _save(Pihole update) async {
    await _localStorage.update(pihole, update);
  }

  String _validateTitle(String val) {
    print('check $val : ${Pihole.toKey(val)}');
    print(_localStorage.cache.keys);
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
                    _save(update).then((_) {
                      setState(() {
                        pihole = update;
                      });
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
                    _save(update).then((_) {
                      setState(() {
                        pihole = update;
                      });
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
                    _save(update).then((_) {
                      setState(() {
                        pihole = update;
                      });
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
                          _save(update).then((_) {
                            setState(() {
                              pihole = update;
                            });
                          });
                        }
                      },
                    ),
                  ),
                  IconTextButton(
                    title: 'Scan QR code',
                    icon: Icons.camera_alt,
                    onPressed: () async {
                      String qr = await QRCodeReader()
                          .setAutoFocusIntervalInMs(200)
                          .scan();
                      authController.text = qr;
                    },
                  ),
                ],
              ),
//              ListTile(
//                title: Text('Example URL'),
//                subtitle: Text(pihole.baseUrl),
//              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: <Widget>[
                    IconTextButton(
                      onPressed: () {
                        final String v = titleController.text;
                        if (v.length > 0 &&
                            _formKey.currentState.validate() &&
                            _validateTitle(v) == null) {
                          _formKey.currentState.save();
                          final update = Pihole(
                              title: titleController.text,
                              host: hostController.text,
                              apiPath: apiPathController.text,
                              port: int.parse(portController.text),
                              auth: authController.text);
                          _save(update).then((_) {
                            setState(() {
                              pihole = update;
                            });

                            _pop(context);
                          });
                        }
                      },
                      title: 'Save',
                      icon: Icons.save,
                      color: Colors.green,
                    ),
                    IconTextButton(
                      onPressed: () async {
                        await _init();
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
