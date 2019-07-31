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
import 'package:flutterhole/widget/status/status_icon.dart';
import 'package:qrcode_reader/qrcode_reader.dart';
import 'package:sticky_headers/sticky_headers.dart';

class PiholeEditForm extends StatefulWidget {
  final Pihole original;

  const PiholeEditForm({Key key, @required this.original}) : super(key: key);

  static _PiholeEditFormState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<_PiholeEditFormState>());

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

  TextEditingController proxyHostController = TextEditingController();
  TextEditingController proxyPortController = TextEditingController();
  TextEditingController proxyUsernameController = TextEditingController();
  TextEditingController proxyPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      pihole = widget.original;
    });
    _resetControllers();
  }

  void save(BuildContext context) {
    final piholeBloc = BlocProvider.of<PiholeBloc>(context);
    print('wee save');
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      Fimber.i('saving: ${pihole.toJson()}');
      piholeBloc.dispatch(UpdatePihole(
          widget.original, Pihole.copyWith(pihole, auth: authController.text)));
    }
  }

  Future _resetControllers() async {
    titleController.text = widget.original.title;
    hostController.text = widget.original.host;
    apiPathController.text = widget.original.apiPath;
    portController.text = widget.original.port.toString();
    authController.text = widget.original.auth;

    proxyHostController.text = widget.original.proxy.host;
    proxyPortController.text = widget.original.proxy.port == null
        ? ''
        : widget.original.proxy.port.toString();
    proxyUsernameController.text = widget.original.proxy.username;
    proxyPasswordController.text = widget.original.proxy.password;
  }

  void _onChange(BuildContext context, Pihole update) {
    BlocProvider.of<VersionsBloc>(context).dispatch(
        FetchForPihole(update, cancelOldRequests: true));
    setState(() {
      pihole = update;
    });
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
        child: Scrollbar(
          child: SingleChildScrollView(
            child: StickyHeader(
              header: Container(
                color: Theme
                    .of(context)
                    .primaryColor,
                alignment: Alignment.centerLeft,
                child: ExpansionTile(
                  title: Row(
                    children: <Widget>[
                      Text('Health Check'),
                      VersionsStatusIcon(),
                    ],
                  ),
//                  backgroundColor: Theme.of(context).secondaryHeaderColor,
//                  initiallyExpanded: true,
                  children: <Widget>[
                    _HealthCheck(),
                  ],
                ),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTab('Pihole'),
                  TextField(
                    controller: titleController,
                    autofocus: pihole.title.isEmpty,
                    decoration: InputDecoration(
                      labelText: 'Configuration name',
                      prefixIcon: Icon(Icons.info_outline),
                    ),
                    onChanged: (v) {
                      _onChange(context, Pihole.copyWith(pihole, title: v));
                    },
                  ),
                  TextField(
                    controller: hostController,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                        labelText: 'Host', prefixIcon: Icon(Icons.home)),
                    onChanged: (v) {
                      _onChange(context, Pihole.copyWith(pihole, host: v));
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
                            _onChange(
                                context, Pihole.copyWith(pihole, auth: v));
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
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .caption,
                                          text: ').')
                                    ]),
                              ]),
                        ),
                      ),
                    ),
                  ),
                  ListTab('Advanced'),
                  FormBuilderSwitch(
                    initialValue: widget.original.useSSL,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.filter_tilt_shift)),
                    label: Text('Always use SSL'),
                    attribute: 'useSSL',
                    onChanged: (v) {
                      _onChange(context, Pihole.copyWith(pihole, useSSL: v));
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Always use SSL, regardless of port.',
                      style: Theme
                          .of(context)
                          .textTheme
                          .caption,
                    ),
                  ),
                  FormBuilderSwitch(
                    initialValue: widget.original.allowSelfSigned,
                    decoration:
                    InputDecoration(prefixIcon: Icon(Icons.lock_open)),
                    label: Text('Allow self-signed certificates'),
                    attribute: 'allowSelfSigned',
                    onChanged: (v) {
                      _onChange(
                          context, Pihole.copyWith(pihole, allowSelfSigned: v));
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
                  ListTab('Proxy (experimental)'),
                  TextField(
                    controller: proxyHostController,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                        labelText: 'Host', prefixIcon: Icon(Icons.home)),
                    onChanged: (v) {
                      _onChange(
                          context,
                          Pihole.copyWith(pihole,
                              proxy: Proxy.copyWith(pihole.proxy, host: v)));
                    },
                  ),
                  TextField(
                    controller: proxyPortController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: InputDecoration(
                        labelText: 'Port', prefixIcon: Icon(Icons.adjust)),
                    onChanged: (v) {
                      _onChange(
                          context,
                          Pihole.copyWith(pihole,
                              proxy: Proxy.copyWith(pihole.proxy,
                                  port: int.parse(v))));
                    },
                  ),
                  TextField(
                    controller: proxyUsernameController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.account_box)),
                    onChanged: (v) {
                      _onChange(
                          context,
                          Pihole.copyWith(pihole,
                              proxy:
                              Proxy.copyWith(pihole.proxy, username: v)));
                    },
                  ),
                  TextField(
                    controller: proxyPasswordController,
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                    onChanged: (v) {
                      _onChange(
                          context,
                          Pihole.copyWith(pihole,
                              proxy:
                              Proxy.copyWith(pihole.proxy, password: v)));
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: <Widget>[
                        IconTextButton(
                          onPressed: () async {
                            save(context);
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
          Versions versions;
          if (state is BlocStateSuccess<Versions>) {
            versions = state.data;
          }

          if (state is BlocStateError<Versions>) {
            items = [
              ListTile(
                leading: Icon(Icons.error),
                title: Text(
                  state.e.message,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Container(),
              ),
              ListTile(title: Container(), subtitle: Container()),
              ListTile(
                leading: Icon(Icons.web),
                trailing: Icon(Icons.keyboard_arrow_right),
                title: Text('Pi-hole community support'),
                subtitle: Text('discourse.pi-hole.net'),
                onTap: () =>
                    launchURL('https://discourse.pi-hole.net/'),
              ),
            ];
          } else {
            items.addAll([
              _ListTile(
                title: versions?.coreCurrent ?? 'Loading...',
                subtitle: 'Pi-hole Version',
                latest: versions?.coreLatest,
              ),
              _ListTile(
                title: versions?.webCurrent ?? 'Loading...',
                subtitle: 'Web Interface Version',
                latest: versions?.webLatest,
              ),
              _ListTile(
                  title: versions?.ftlCurrent ?? 'Loading...',
                  subtitle: 'FTL Version',
                  latest: versions?.coreLatest ?? 'Loading...'),
            ]);
          }

          return Column(
            children: items,
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
  '$subtitle${(title != 'Loading...' && latest != null && latest.length > 0)
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
