import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutterhole/bloc/api/versions.dart';
import 'package:flutterhole/bloc/base/state.dart';
import 'package:flutterhole/bloc/pihole/bloc.dart';
import 'package:flutterhole/model/api/versions.dart';
import 'package:flutterhole/model/pihole.dart';
import 'package:flutterhole/service/browser.dart';
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

  void _onChange(BuildContext context, Pihole update) {
    if (_formKey.currentState.validate()) {
      setState(() {
        pihole = update;
        BlocProvider.of<VersionsBloc>(context).dispatch(FetchForPihole(update));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final piholeBloc = BlocProvider.of<PiholeBloc>(context);
    final String apiTokenUrl = '${pihole.baseUrl}/admin/settings.php?tab=api';
    return BlocListener(
      bloc: piholeBloc,
      listener: (context, state) {
        if (state is PiholeStateSuccess) {
          _pop(context);
        }
        if (state is PiholeStateError) {
          Scaffold.of(context)
              .showSnackBar(SnackBar(content: Text(state.e.toString())));
        }
      },
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: titleController,
                autofocus: pihole.title.isEmpty,
                decoration: InputDecoration(
                  labelText: 'Configuration name',
                  prefixIcon: Icon(Icons.info_outline),
                ),
              ),
              TextField(
                controller: hostController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                    labelText: 'Host', prefixIcon: Icon(Icons.home)),
                onChanged: (v) {
                  _onChange(context, Pihole.copyWith(pihole, host: v));
//                  if (v.length > 0 && pihole.title.length > 0) {
//                    final update = Pihole.copyWith(pihole, host: v);
//                    setState(() {
//                      pihole = update;
//                    });
//                  }
                },
              ),
              TextField(
                controller: apiPathController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    labelText: 'API path', prefixIcon: Icon(Icons.code)),
                onChanged: (v) {
                  _onChange(context, Pihole.copyWith(pihole, apiPath: v));
                },
              ),
              TextField(
                controller: portController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  WhitelistingTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: InputDecoration(
                    labelText: 'Port', prefixIcon: Icon(Icons.adjust)),
                onChanged: (v) {
                  _onChange(
                      context, Pihole.copyWith(pihole, port: int.parse(v)));
//                  if (v.length > 0 && pihole.title.length > 0) {
//                    final update = Pihole.copyWith(pihole, port: int.parse(v));
//                    setState(() {
//                      pihole = update;
//                    });
//                  }
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
                          prefixIcon: Icon(Icons.vpn_key)),
                      onChanged: (v) {
                        _onChange(context, Pihole.copyWith(pihole, auth: v));
//                        if (v.length > 0 && pihole.title.length > 0) {
//                          final update = Pihole.copyWith(pihole, auth: v);
//                          setState(() {
//                            pihole = update;
//                          });
//                        }
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
                    padding: EdgeInsets.all(8.0),
                    child: RichText(
                      text: TextSpan(
                          style: Theme
                              .of(context)
                              .textTheme
                              .caption,
                          text:
                          'The API token can be found on the admin home at Settings > API / Web interface (example: ',
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
                  _onChange(
                      context, Pihole.copyWith(pihole, allowSelfSigned: v));
//                  final update = Pihole.copyWith(pihole, allowSelfSigned: v);
//                  setState(() {
//                    pihole = update;
//                  });
                },
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Trust certificates, even when the TLS handshake fails.',
                  style: Theme
                      .of(context)
                      .textTheme
                      .caption,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: <Widget>[
                    IconTextButton(
                      onPressed: () async {
                        final String v = titleController.text;
                        if (v.length > 0 && _formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          final update = Pihole.copyWith(
                            pihole,
                            title: titleController.text,
                            host: hostController.text,
                            port: int.parse(portController.text),
                            auth: authController.text,
                          );
                          piholeBloc
                              .dispatch(UpdatePihole(widget.original, update));
                          setState(() {
                            pihole = update;
                          });
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
              _HealthCheck(),
            ],
          ),
        ),
      ),
    );
  }

  void _pop(BuildContext context) {
    if (widget.original != null) {
      Navigator.of(context).pop('Edited ${pihole.title}');
    } else {
      Navigator.of(context).pop('Added ${pihole.title}');
    }
  }
}

class _HealthCheck extends StatelessWidget {
  const _HealthCheck({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: BlocProvider.of<VersionsBloc>(context),
        builder: (context, state) {
          List<Widget> items = [];

          if (state is BlocStateSuccess<Versions>) {
            final versions = state.data;
            items.addAll([
              _ListTile(
                title: versions.coreCurrent,
                subtitle: 'Pi-hole Version',
                latest: versions?.coreLatest,
              ),
              _ListTile(
                title: versions.webCurrent,
                subtitle: 'Web Interface Version',
                latest: versions?.webLatest,
              ),
              _ListTile(
                  title: versions.ftlCurrent,
                  subtitle: 'FTL Version',
                  latest: versions?.coreLatest),
            ]);
          }

          if (state is BlocStateError<Versions>) {
            items.add(ListTile(
              leading: Icon(Icons.error),
              title: Text(state.e.message),
            ));
          }

          if (state is BlocStateLoading<Versions>) {
            items.add(Center(
              child: CircularProgressIndicator(),
            ));
          }

          return Column(
            children: <Widget>[
              ListTile(
                title: Text(
                  'Health check',
                ),
              ),
              ...items
            ],
          );
        });
  }
}

class _ListTile extends StatelessWidget {
  const _ListTile({
    Key key,
    this.title,
    @required this.subtitle,
    this.latest = '',
  })
      : _subtitle =
  '$subtitle${(latest != null && latest.length > 0)
      ? ' (update available: $latest)'
      : ''}',
        super(key: key);

  final String title;
  final String subtitle;
  final String latest;

  final String _subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.check),
      title: Text(title),
      subtitle: Text(_subtitle),
    );
  }
}
