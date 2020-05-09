import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/api/data/models/pi_status.dart';
import 'package:flutterhole/features/settings/blocs/pihole_settings_bloc.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:flutterhole/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:flutterhole/features/settings/services/qr_scan_service.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

const InputDecoration _decoration = InputDecoration(
  border: const OutlineInputBorder(),
  contentPadding: EdgeInsets.all(12.0),
);

class PiholeSettingsPage extends StatefulWidget {
  const PiholeSettingsPage({
    Key key,
    @required this.initialValue,
  }) : super(key: key);

  final PiholeSettings initialValue;

  @override
  _PiholeSettingsPageState createState() => _PiholeSettingsPageState();
}

class _PiholeSettingsPageState extends State<PiholeSettingsPage> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  TextEditingController _apiTokenController;
  bool _apiTokenVisible;

  @override
  void initState() {
    super.initState();
    _apiTokenController =
        TextEditingController(text: widget.initialValue.apiToken);
    _apiTokenVisible = false;
  }

  void _showJsonViewer(BuildContext context, PiholeSettings settings) {
    final Map<String, dynamic> json = settings.toJson();

    showMaterialModalBottomSheet(
      context: context,
      builder: (BuildContext context, ScrollController scrollController) {
        return Material(
          child: SafeArea(
              child: ListView.builder(
            controller: scrollController,
            shrinkWrap: true,
            itemCount: json.length,
            itemBuilder: (context, index) {
              return ListTile(
                dense: true,
                title: Text('${json.values.elementAt(index)}'),
                subtitle: Text('${json.keys.elementAt(index)}'),
              );
            },
          )),
        );
      },
    );
  }

  void _validate(BuildContext context) {
    if (_fbKey.currentState.saveAndValidate()) {
      final update = PiholeSettings.fromJson(_fbKey.currentState.value);
      BlocProvider.of<PiholeSettingsBloc>(context)
          .add(PiholeSettingsEvent.validate(update));
    }
  }

  Future<bool> _showConfirmCancelDialog(BuildContext context) async {
    final result = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Discard changes?'),
            actions: <Widget>[
              FlatButton(
                child: Text('Confirm'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        });

    return result ?? false;
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
    return BlocListener<SettingsBloc, SettingsState>(
      bloc: getIt<SettingsBloc>(),
      listener: (BuildContext context, SettingsState state) {
        if (state is SettingsStateSuccess) {
          Navigator.of(context).pop();
        }
      },
      child: BlocProvider<PiholeSettingsBloc>(
        create: (_) => PiholeSettingsBloc()
          ..add(PiholeSettingsEvent.validate(widget.initialValue)),
        child: FormBuilder(
          key: _fbKey,
          initialValue: widget.initialValue.toJson(),
          autovalidate: true,
          child: Builder(builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async {
                if (_fbKey.currentState.saveAndValidate()) {
                  final update =
                      PiholeSettings.fromJson(_fbKey.currentState.value);

                  if (update != widget.initialValue) {
                    return _showConfirmCancelDialog(context);
                  }

                  return true;
                }
                return false;
              },
              child: Scaffold(
                appBar: AppBar(
                  title: Text('${widget.initialValue.title}'),
                  actions: <Widget>[
                    MaterialButton(
                      child: Text('Validate'),
                      onPressed: () => _validate(context),
                    ),
                    MaterialButton(
                      child: Text('Save'),
                      onPressed: () {
                        if (_fbKey.currentState.saveAndValidate()) {
                          final update = PiholeSettings.fromJson(
                              _fbKey.currentState.value);
                          getIt<SettingsBloc>().add(SettingsEvent.update(
                              widget.initialValue, update));
                        }
                      },
                    ),
                  ],
                ),
                body: ListView(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        ListTile(
                          title: Text('Annotation'),
                        ),
                        ListTile(
                          title: FormBuilderTextField(
                            attribute: 'title',
                            decoration:
                                _decoration.copyWith(labelText: 'Title'),
                            autocorrect: false,
                            textCapitalization: TextCapitalization.words,
                            maxLines: 1,
                            validators: [
                              FormBuilderValidators.required(),
                            ],
                          ),
                        ),
                        ListTile(
                          title: FormBuilderTextField(
                            attribute: 'description',
                            decoration:
                                _decoration.copyWith(labelText: 'Description'),
                            textCapitalization: TextCapitalization.sentences,
                            minLines: 1,
                            maxLines: 5,
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    Column(
                      children: <Widget>[
                        ListTile(
                          title: Row(
                            children: <Widget>[
                              Text('Host details'),
                              SizedBox(width: 8.0),
                              BlocBuilder<PiholeSettingsBloc,
                                  PiholeSettingsState>(
                                builder: (BuildContext context,
                                    PiholeSettingsState state) {
                                  return state.maybeWhen<Widget>(
                                      validated: (
                                        PiholeSettings settings,
                                        dartz.Either<Failure, int>
                                            hostStatusCode,
                                        dartz.Either<Failure, PiStatusEnum>
                                            piholeStatus,
                                        _,
                                      ) {
                                        return hostStatusCode.fold<Widget>(
                                          (Failure failure) => Icon(
                                            KIcons.error,
                                            color: KColors.error,
                                          ),
                                          (int statusCode) {
                                            return piholeStatus.fold<Widget>(
                                              (Failure failure) => Icon(
                                                KIcons.error,
                                                color: KColors.error,
                                              ),
                                              (PiStatusEnum piStatus) {
                                                switch (piStatus) {
                                                  case PiStatusEnum.enabled:
                                                  case PiStatusEnum.disabled:
                                                    return Icon(
                                                      KIcons.success,
                                                      color: KColors.success,
                                                    );
                                                  case PiStatusEnum.unknown:
                                                  default:
                                                    return Icon(
                                                      KIcons.error,
                                                      color: KColors.error,
                                                    );
                                                }
                                              },
                                            );
                                          },
                                        );
                                      },
                                      loading: () => SpinKitRipple(
                                            size: 24.0,
                                            color: Colors.orange,
                                          ),
                                      orElse: () => Icon(KIcons.debug));
                                },
                              ),
                            ],
                          ),
                        ),
                        ListTile(
                          title: Row(
                            children: <Widget>[
                              Flexible(
                                flex: 3,
                                child: FormBuilderTextField(
                                  attribute: 'baseUrl',
                                  decoration: _decoration.copyWith(
                                    labelText: 'Base URL',
                                  ),
                                  autocorrect: false,
                                  maxLines: 1,
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Flexible(
                                flex: 1,
                                child: FormBuilderTextField(
                                  attribute: 'apiPort',
                                  initialValue:
                                      widget.initialValue.apiPort.toString(),
                                  decoration: _decoration.copyWith(
                                    labelText: 'Port',
//                              suffixIcon: Padding(
//                                padding:
//                                    const EdgeInsetsDirectional.only(end: 12.0),
//                                child:
//                                    ValidationIcon(), // myIcon is a 48px-wide widget.
//                              ),
                                  ),
                                  maxLines: 1,
                                  keyboardType: TextInputType.number,
                                  validators: [
                                    FormBuilderValidators.numeric(),
                                    FormBuilderValidators.min(0),
                                    FormBuilderValidators.max(65535),
                                  ],
                                  inputFormatters: [
                                    WhitelistingTextInputFormatter.digitsOnly,
                                  ],
                                  valueTransformer: (value) =>
                                      int.tryParse(value ?? 80),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListTile(
                          title: FormBuilderTextField(
                            attribute: 'apiPath',
                            decoration:
                                _decoration.copyWith(labelText: 'API path', helperText: 'For normal use cases, the API path is "${PiholeSettings().apiPath}".'),
                            autocorrect: false,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    ListTile(
                      title: Row(
                        children: <Widget>[
                          Text('Authentication'),
                          SizedBox(width: 8.0),
                          BlocBuilder<PiholeSettingsBloc, PiholeSettingsState>(
                            builder: (BuildContext context,
                                PiholeSettingsState state) {
                              return state.maybeWhen<Widget>(
                                  validated: (
                                    PiholeSettings settings,
                                    _,
                                    __,
                                    dartz.Either<Failure, bool>
                                        authenticatedStatus,
                                  ) {
                                    return authenticatedStatus.fold<Widget>(
                                      (Failure failure) => Icon(
                                        KIcons.error,
                                        color: KColors.error,
                                      ),
                                      (bool isAuthenticated) {
                                        return Icon(
                                          isAuthenticated
                                              ? KIcons.success
                                              : KIcons.error,
                                          color: isAuthenticated
                                              ? KColors.success
                                              : KColors.error,
                                        );
                                      },
                                    );
                                  },
                                  loading: () => SpinKitRipple(
                                        size: 24.0,
                                        color: Colors.orange,
                                      ),
                                  orElse: () => Icon(KIcons.debug));
                            },
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      title: FormBuilderTextField(
                        attribute: 'apiToken',
                        controller: _apiTokenController,
                        decoration: _decoration.copyWith(
                          labelText: 'API token',
                          helperText: 'The API token can be found on the admin home at "Settings > API / Web interface". \nRequired for authenticated tasks, such as enabling & disabling.',
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
                        valueTransformer: (value) =>
                            (value ?? '').toString().trim(),
                      ),
                    ),
                    ListTile(
                      title: FormBuilderCheckbox(
                        attribute: 'allowSelfSignedCertificates',
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          helperText:
                              'Trust all certificates, even when the TLS handshake fails. \nUseful for using HTTPs over your own certificate.',
                        ),
                        label: Text('Allow self-signed certificates'),
                      ),
                    ),
//                FlatButton.icon(
//                  onPressed: () {
//                    _showJsonViewer(context, widget.initialValue);
//                  },
//                  label: Text('JSON view'),
//                  icon: Icon(KIcons.pihole),
//                ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
