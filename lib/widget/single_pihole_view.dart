import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterhole_again/model/pihole.dart';
import 'package:flutterhole_again/service/local_storage.dart';

class SinglePiholeView extends StatefulWidget {
  final Pihole provided;

  const SinglePiholeView({Key key, @required this.provided}) : super(key: key);

  @override
  _SinglePiholeViewState createState() => _SinglePiholeViewState();
}

class _SinglePiholeViewState extends State<SinglePiholeView> {
  LocalStorage _localStorage;
  Pihole pihole;

  final _formKey = GlobalKey<FormState>();

  TextEditingController titleController = TextEditingController();
  TextEditingController hostController = TextEditingController();
  TextEditingController portController = TextEditingController();
  TextEditingController authController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      pihole = widget.provided;
    });
    _init();
  }

  Future _init() async {
    final localStorage = await LocalStorage.getInstance();

    setState(() {
      _localStorage = localStorage;
    });

    titleController.text = pihole.title;
    hostController.text = pihole.host;
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
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: titleController,
                      autofocus: pihole.title.isEmpty,
                      decoration: InputDecoration(
                          labelText: 'Configuration name',
                          helperText:
                              'Update the internal cache after changing this.',
                          errorText: _validateTitle(titleController.text)),
                    ),
                  ),
                  MaterialButton(
                    onPressed: () {
                      final String v = titleController.text;
                      if (v.length > 0 && _validateTitle(v) == null) {
                        final update = Pihole.copyWith(pihole, title: v);
                        _save(update).then((_) {
                          setState(() {
                            pihole = update;
                          });
                          Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text(' Updated internal cache')));
                        });
                      }
                    },
                    child: Text('Update cache'),
                  )
                ],
              ),
              TextField(
                controller: hostController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(labelText: 'Host'),
                enabled: pihole.title.isNotEmpty,
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
                controller: portController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  WhitelistingTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: InputDecoration(labelText: 'Port'),
                enabled: pihole.title.isNotEmpty,
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
              TextField(
                controller: authController,
                keyboardType: TextInputType.url,
                obscureText: true,
                decoration: InputDecoration(labelText: 'API token'),
                enabled: pihole.title.isNotEmpty,
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
              ListTile(
                title: Text('Example URL'),
                subtitle: Text(pihole.toJson().toString()),
              ),
            ],
          ),
        ),
      );
    }
  }
}
