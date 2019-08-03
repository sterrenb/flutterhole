import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutterhole/bloc/api/versions.dart';
import 'package:flutterhole/bloc/pihole/bloc.dart';
import 'package:flutterhole/model/pihole.dart';
import 'package:flutterhole/service/browser.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/widget/layout/icon_text_button.dart';
import 'package:flutterhole/widget/layout/list_tab.dart';
import 'package:flutterhole/widget/pihole/health_checker.dart';
import 'package:flutterhole/widget/status/status_icon.dart';
import 'package:qrcode_reader/qrcode_reader.dart';
import 'package:sticky_headers/sticky_headers.dart';

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

  TextEditingController proxyHostController = TextEditingController();
  TextEditingController proxyPortController = TextEditingController();
  TextEditingController proxyUsernameController = TextEditingController();
  TextEditingController proxyPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _resetControllers();
  }

  void save(BuildContext context) {
    final piholeBloc = BlocProvider.of<PiholeBloc>(context);
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      Globals.tree.log('Form', '${pihole.toObscuredJson()}', tag: 'save');
      piholeBloc
          .dispatch(UpdatePihole(original: widget.original, update: pihole));
    }
  }

  Future<void> _resetControllers() async {
    setState(() {
      pihole = widget.original;
    });

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
    BlocProvider.of<VersionsBloc>(context)
        .dispatch(FetchForPihole(update, cancelOldRequests: true));
    setState(() {
      pihole = update;
    });
  }

  @override
  Widget build(BuildContext context) {
    final piholeBloc = BlocProvider.of<PiholeBloc>(context);
    final String apiTokenUrl = '${pihole.baseUrl}/admin/settings.php?tab=api';
    final String apiTokenString =
        '${pihole.baseUrlObscured}/admin/settings.php?tab=api';
    return BlocListener(
      bloc: piholeBloc,
      listener: (context, state) {
        if (state is PiholeStateSuccess) {
          _popSuccess(context);
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
                    .secondaryHeaderColor,
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
                    HealthChecker(),
                  ],
                ),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTab('Pihole Configuration'),
                  TextField(
                    key: Key('titleController'),
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
                    key: Key('hostController'),
                    controller: hostController,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                        labelText: 'Host', prefixIcon: Icon(Icons.home)),
                    onChanged: (v) {
                      _onChange(context, Pihole.copyWith(pihole, host: v));
                    },
                  ),
                  TextField(
                    key: Key('apiPathController'),
                    controller: apiPathController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        labelText: 'API path', prefixIcon: Icon(Icons.code)),
                    onChanged: (v) {
                      _onChange(context, Pihole.copyWith(pihole, apiPath: v));
                    },
                  ),
                  TextField(
                    key: Key('portController'),
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
                          key: Key('authController'),
                          controller: authController,
                          keyboardType: TextInputType.url,
                          enableInteractiveSelection: true,
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
                            _onChange(
                                context, Pihole.copyWith(pihole, auth: qr));
                          } catch (e) {
                            Globals.tree.log(
                                'AuthController', 'cannot scan QR code',
                                ex: e);
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
                                    text: apiTokenString,
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
                  ListTab('SSL Settings'),
                  Container(
                    key: Key('useSSLController'),
                    child: FormBuilderSwitch(
                      initialValue: widget.original.useSSL,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.filter_tilt_shift)),
                      label: Text('use SSL'),
                      attribute: 'useSSL',
                      onChanged: (v) {
                        _onChange(context, Pihole.copyWith(pihole, useSSL: v));
                      },
                    ),
                  ),
                  Container(
                    key: Key('allowSelfSignedController'),
                    child: FormBuilderSwitch(
                      initialValue: widget.original.allowSelfSigned,
                      decoration:
                      InputDecoration(prefixIcon: Icon(Icons.lock_open)),
                      label: Text('Allow self-signed certificates'),
                      attribute: 'allowSelfSigned',
                      onChanged: (v) {
                        _onChange(context,
                            Pihole.copyWith(pihole, allowSelfSigned: v));
                      },
                    ),
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
                  ListTab('Basic Authentication'),
                  TextField(
                    key: Key('proxyUsernameController'),
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
                    key: Key('proxyPasswordController'),
                    controller: proxyPasswordController,
                    keyboardType: TextInputType.text,
                    enableInteractiveSelection: true,
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
                  ListTab('Proxy Settings'),
                  TextField(
                    key: Key('proxyHostController'),
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
                    key: Key('proxyPortController'),
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
                            _onChange(context, widget.original);
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

  void _popSuccess(BuildContext context) {
    if (widget.original != null) {
      Navigator.of(context).pop('Edited ${pihole.title}');
    } else {
      Navigator.of(context).pop('Added ${pihole.title}');
    }
  }
}
