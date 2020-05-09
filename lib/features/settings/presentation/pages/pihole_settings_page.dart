import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/api/data/models/pi_status.dart';
import 'package:flutterhole/features/settings/blocs/pihole_settings_bloc.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:flutterhole/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:flutterhole/features/settings/presentation/widgets/pihole_theme_builder.dart';
import 'package:flutterhole/features/settings/services/qr_scan_service.dart';
import 'package:flutterhole/widgets/layout/loading_indicators.dart';

extension HexColor on Color {
  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0').toUpperCase()}'
      '${red.toRadixString(16).padLeft(2, '0').toUpperCase()}'
      '${green.toRadixString(16).padLeft(2, '0').toUpperCase()}'
      '${blue.toRadixString(16).padLeft(2, '0').toUpperCase()}';
}

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

class _Form extends StatefulWidget {
  const _Form({
    Key key,
    @required this.initialValue,
  }) : super(key: key);

  final PiholeSettings initialValue;

  @override
  __FormState createState() => __FormState();
}

class __FormState extends State<_Form> {
  void _validate(BuildContext context) {
    if (BlocProvider.of<PiholeSettingsBloc>(context)
        .formKey
        .currentState
        .saveAndValidate()) {
      final update = PiholeSettings.fromJson(
          BlocProvider.of<PiholeSettingsBloc>(context)
              .formKey
              .currentState
              .value);
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
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              OutlineButton(
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PiholeSettingsBloc, PiholeSettingsState>(
      condition: (previous, next) {
        return previous.maybeMap<bool>(
          validated: (_) => false,
          orElse: () => true,
        );
      },
      builder: (BuildContext context, PiholeSettingsState state) {
        return PiholeThemeBuilder(
          settings: state.maybeMap<PiholeSettings>(
            validated: (state) => state.settings,
            orElse: () => widget.initialValue,
          ),
          child: WillPopScope(
            onWillPop: () async {
              if (BlocProvider.of<PiholeSettingsBloc>(context)
                  .formKey
                  .currentState
                  .saveAndValidate()) {
                final update = PiholeSettings.fromJson(
                    BlocProvider.of<PiholeSettingsBloc>(context)
                        .formKey
                        .currentState
                        .value);

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
                      if (BlocProvider.of<PiholeSettingsBloc>(context)
                          .formKey
                          .currentState
                          .saveAndValidate()) {
                        final update = PiholeSettings.fromJson(
                            BlocProvider.of<PiholeSettingsBloc>(context)
                                .formKey
                                .currentState
                                .value);
                        getIt<SettingsBloc>().add(
                            SettingsEvent.update(widget.initialValue, update));
                      }
                    },
                  ),
                ],
              ),
              body: ListView(
                children: <Widget>[
                  AnnotationForm(initialValue: widget.initialValue),
                  Divider(),
                  HostDetailsForm(initialValue: widget.initialValue),
                  Divider(),
                  AuthenticationForm(initialValue: widget.initialValue),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PiholeSettingsPageState extends State<PiholeSettingsPage> {
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
        child: Builder(
          builder: (context) {
            return FormBuilder(
              key: BlocProvider.of<PiholeSettingsBloc>(context).formKey,
              initialValue: widget.initialValue.toJson(),
              autovalidate: true,
              child: Builder(builder: (BuildContext context) {
                return _Form(initialValue: widget.initialValue);
              }),
            );
          },
        ),
      ),
    );
  }
}

class AnnotationForm extends StatelessWidget {
  const AnnotationForm({
    Key key,
    @required this.initialValue,
  }) : super(key: key);

  final PiholeSettings initialValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text('Annotation'),
          leading: Icon(
            KIcons.annotation,
            color: Theme.of(context).accentColor,
          ),
        ),
        ListTile(
          title: FormBuilderTextField(
            attribute: 'title',
            decoration: _decoration.copyWith(labelText: 'Title'),
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
            decoration: _decoration.copyWith(labelText: 'Description'),
            textCapitalization: TextCapitalization.sentences,
            minLines: 1,
            maxLines: 5,
          ),
        ),
        ListTile(
          title: FormBuilderColorPicker(
            attribute: 'primaryColor',
            initialValue: initialValue.primaryColor,
            decoration: _decoration.copyWith(labelText: 'Color'),
            valueTransformer: (value) => (value as Color).toHex(),
            colorPickerType: ColorPickerType.MaterialPicker,
          ),
        ),
      ],
    );
  }
}

class HostDetailsForm extends StatelessWidget {
  const HostDetailsForm({
    Key key,
    @required this.initialValue,
  }) : super(key: key);

  final PiholeSettings initialValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: Icon(
            KIcons.hostDetails,
            color: Theme.of(context).accentColor,
          ),
          title: Row(
            children: <Widget>[
              Text('Host details'),
              SizedBox(width: 8.0),
              BlocBuilder<PiholeSettingsBloc, PiholeSettingsState>(
                builder: (BuildContext context, PiholeSettingsState state) {
                  return state.maybeWhen<Widget>(
                      validated: (
                        PiholeSettings settings,
                        dartz.Either<Failure, int> hostStatusCode,
                        dartz.Either<Failure, PiStatusEnum> piholeStatus,
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
                      loading: () => LoadingIcon(),
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
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  maxLines: 1,
                ),
              ),
              SizedBox(width: 8.0),
              Flexible(
                flex: 1,
                child: FormBuilderTextField(
                  attribute: 'apiPort',
                  initialValue: initialValue.apiPort.toString(),
                  decoration: _decoration.copyWith(
                    labelText: 'Port',
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
                  valueTransformer: (value) => int.tryParse(value ?? 80),
                ),
              ),
            ],
          ),
        ),
        ListTile(
          title: FormBuilderTextField(
            attribute: 'apiPath',
            decoration: _decoration.copyWith(
                labelText: 'API path',
                helperText:
                    'For normal use cases, the API path is "${PiholeSettings().apiPath}".'),
            autocorrect: false,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

class AuthenticationForm extends StatefulWidget {
  const AuthenticationForm({Key key, @required this.initialValue})
      : super(key: key);

  final PiholeSettings initialValue;

  @override
  _AuthenticationFormState createState() => _AuthenticationFormState();
}

class _AuthenticationFormState extends State<AuthenticationForm> {
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
    return Column(
      children: <Widget>[
        ListTile(
          leading: Icon(
            KIcons.authentication,
            color: Theme.of(context).accentColor,
          ),
          title: Row(
            children: <Widget>[
              Text('Authentication'),
              SizedBox(width: 8.0),
              BlocBuilder<PiholeSettingsBloc, PiholeSettingsState>(
                builder: (BuildContext context, PiholeSettingsState state) {
                  return state.maybeWhen<Widget>(
                      validated: (
                        PiholeSettings settings,
                        _,
                        __,
                        dartz.Either<Failure, bool> authenticatedStatus,
                      ) {
                        return authenticatedStatus.fold<Widget>(
                          (Failure failure) => Icon(
                            KIcons.error,
                            color: KColors.error,
                          ),
                          (bool isAuthenticated) {
                            return Icon(
                              isAuthenticated ? KIcons.success : KIcons.error,
                              color: isAuthenticated
                                  ? KColors.success
                                  : KColors.error,
                            );
                          },
                        );
                      },
                      loading: () => LoadingIcon(),
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
        ),
        ListTile(
          title: FormBuilderCheckbox(
            attribute: 'allowSelfSignedCertificates',
            decoration: _decoration.copyWith(
              helperText:
                  'Trust all certificates, even when the TLS handshake fails. \nUseful for using HTTPs over your own certificate.',
            ),
            label: Text('Allow self-signed certificates'),
          ),
        ),
      ],
    );
  }
}
