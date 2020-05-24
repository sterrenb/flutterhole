import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/settings/blocs/pihole_settings_bloc.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:flutterhole/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:flutterhole/features/settings/presentation/widgets/form/allow_self_signed_certificates_form_tile.dart';
import 'package:flutterhole/features/settings/presentation/widgets/form/api_path_form_tile.dart';
import 'package:flutterhole/features/settings/presentation/widgets/form/api_token_form_tile.dart';
import 'package:flutterhole/features/settings/presentation/widgets/form/authentication_status_icon.dart';
import 'package:flutterhole/features/settings/presentation/widgets/form/base_url_form_tile.dart';
import 'package:flutterhole/features/settings/presentation/widgets/form/basic_authentication_password_form_tile.dart';
import 'package:flutterhole/features/settings/presentation/widgets/form/basic_authentication_username_form_tile.dart';
import 'package:flutterhole/features/settings/presentation/widgets/form/color_form_tile.dart';
import 'package:flutterhole/features/settings/presentation/widgets/form/description_form_tile.dart';
import 'package:flutterhole/features/settings/presentation/widgets/form/detected_versions_tile.dart';
import 'package:flutterhole/features/settings/presentation/widgets/form/host_details_status_icon.dart';
import 'package:flutterhole/features/settings/presentation/widgets/form/title_form_tile.dart';
import 'package:flutterhole/widgets/layout/notifications/snackbars.dart';

const InputDecoration _decoration = InputDecoration(
  border: const OutlineInputBorder(),
  contentPadding: EdgeInsets.all(12.0),
);

class _StepperForm extends StatelessWidget {
  const _StepperForm({
    Key key,
    @required this.children,
  }) : super(key: key);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children,
    );
  }
}

class AddPiholePage extends StatefulWidget {
  const AddPiholePage({
    Key key,
  }) : super(key: key);

  @override
  _AddPiholePageState createState() => _AddPiholePageState();
}

class _AddPiholePageState extends State<AddPiholePage> {
  static const PiholeSettings initialValue = PiholeSettings();

  static const int stepCount = 2;

  int currentStep = 0;

  String hostDetailsError = '';

  void _validate(BuildContext context) {
    if (BlocProvider.of<PiholeSettingsBloc>(context)
        .formKey
        .currentState
        .saveAndValidate()) {
      final toValidate = PiholeSettings.fromJson(
          BlocProvider.of<PiholeSettingsBloc>(context)
              .formKey
              .currentState
              .value);
      BlocProvider.of<PiholeSettingsBloc>(context)
          .add(PiholeSettingsEvent.validate(toValidate));
    }
  }

  void _save(BuildContext context) {
    if (BlocProvider.of<PiholeSettingsBloc>(context)
        .formKey
        .currentState
        .saveAndValidate()) {
      final toSave = PiholeSettings.fromJson(
          BlocProvider.of<PiholeSettingsBloc>(context)
              .formKey
              .currentState
              .value);
      getIt<SettingsBloc>().add(SettingsEvent.add(toSave));
      Navigator.of(context).pop();
    } else {
      showErrorSnackBar(context, 'Validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PiholeSettingsBloc>(
      create: (_) => PiholeSettingsBloc(),
      child: Builder(
        builder: (context) => FormBuilder(
          key: BlocProvider.of<PiholeSettingsBloc>(context).formKey,
          initialValue: initialValue.toJson(),
          autovalidate: true,
          child: Scaffold(
            appBar: AppBar(
              title: Text('Add a new Pihole'),
              actions: <Widget>[
                IconButton(
                    tooltip: 'Create Pihole',
                    icon: Icon(KIcons.save),
                    onPressed: () => _save(context)),
              ],
            ),
            body: BlocBuilder<PiholeSettingsBloc, PiholeSettingsState>(
              condition: (previous, next) {
                if (previous is PiholeSettingsStateValidated) {
                  return false;
                }

                return true;
              },
              builder: (BuildContext context, PiholeSettingsState state) {
                return Stepper(
                  currentStep: currentStep,
                  onStepTapped: (int index) {
                    _validate(context);
                    setState(() {
                      currentStep = index;
                    });
                  },
                  onStepCancel: () {
                    if (currentStep == 0) {
                      Navigator.of(context).pop();
                    } else {
                      setState(() {
                        currentStep = currentStep - 1;
                      });
                    }
                  },
                  onStepContinue: () {
                    _validate(context);
                    if (currentStep < stepCount) {
                      setState(() {
                        currentStep = currentStep + 1;
                      });
                    }
                  },
                  steps: <Step>[
                    Step(
                        title: Text('Annotation'),
                        content: _StepperForm(children: <Widget>[
                          TitleFormTile(decoration: _decoration),
                          DescriptionFormTile(decoration: _decoration),
                          PrimaryColorFormTile(
                            initialValue: initialValue,
                            decoration: _decoration,
                          ),
//                          AccentColorFormTile(
//                            initialValue: initialValue,
//                            decoration: _decoration,
//                          ),
                        ]),
                        isActive: currentStep == 0),
                    Step(
                      title: Row(
                        children: <Widget>[
                          Text('Host details'),
                          HostDetailsStatusIcon(),
                        ],
                      ),
                      content: _StepperForm(children: <Widget>[
                        BaseUrlFormTile(
                          initialValue: _AddPiholePageState.initialValue,
                          decoration: _decoration,
                        ),
                        ApiPathFormTile(decoration: _decoration),
                        hostDetailsError.isEmpty
                            ? Container()
                            : Text(
                                '$hostDetailsError',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 5,
                              ),
                        const DetectedVersionsTile(),
                      ]),
                      isActive: currentStep == 1,
                    ),
                    Step(
                        title: Row(
                          children: <Widget>[
                            Text('Authentication'),
                            AuthenticationStatusIcon(),
                          ],
                        ),
                        content: _StepperForm(children: <Widget>[
                          ApiTokenFormTile(
                            initialValue: _AddPiholePageState.initialValue,
                            decoration: _decoration,
                          ),
                          AllowSelfSignedCertificatesFormTile(
                              decoration: _decoration),
                          BasicAuthenticationUsernameFormTile(
                              decoration: _decoration),
                          BasicAuthenticationPasswordFormTile(
                            initialValue: _AddPiholePageState.initialValue,
                            decoration: _decoration,
                          ),
                        ]),
                        isActive: currentStep == 2),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
