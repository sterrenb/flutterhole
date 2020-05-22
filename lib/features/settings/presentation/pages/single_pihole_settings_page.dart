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
import 'package:flutterhole/features/settings/presentation/widgets/pihole_theme_builder.dart';
import 'package:flutterhole/widgets/layout/notifications/dialogs.dart';

const InputDecoration _decoration = InputDecoration(
  border: const OutlineInputBorder(),
  contentPadding: EdgeInsets.all(12.0),
);

class SinglePiholeSettingsPage extends StatefulWidget {
  const SinglePiholeSettingsPage({
    Key key,
    @required this.initialValue,
  }) : super(key: key);

  final PiholeSettings initialValue;

  @override
  _SinglePiholeSettingsPageState createState() =>
      _SinglePiholeSettingsPageState();
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
                  return showConfirmationDialog(
                    context,
                    title: Text('Discard changes?'),
                  );
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
                  _AnnotationForm(initialValue: widget.initialValue),
                  Divider(),
                  _HostDetailsForm(initialValue: widget.initialValue),
                  Divider(),
                  AuthenticationForm(initialValue: widget.initialValue),
                  Divider(),
                  const DetectedVersionsTile(),
                  _DeletePiholeButton(initialValue: widget.initialValue),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DeletePiholeButton extends StatelessWidget {
  const _DeletePiholeButton({
    Key key,
    @required this.initialValue,
  }) : super(key: key);

  final PiholeSettings initialValue;

  @override
  Widget build(BuildContext context) {
    return RaisedButton.icon(
      onPressed: () async {
        final bool didConfirm = await showConfirmationDialog(
          context,
          title: Text('Delete this Pihole? This cannot be undone.'),
        );

        if (didConfirm ?? false) {
          getIt<SettingsBloc>().add(SettingsEvent.delete(initialValue));
          Navigator.of(context).pop();
        }
      },
      color: KColors.error,
      icon: Icon(KIcons.delete),
      label: Text('Delete this Pihole'),
    );
  }
}

class _SinglePiholeSettingsPageState extends State<SinglePiholeSettingsPage> {
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

class _AnnotationForm extends StatelessWidget {
  const _AnnotationForm({
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
        TitleFormTile(decoration: _decoration),
        DescriptionFormTile(decoration: _decoration),
        PrimaryColorFormTile(
          initialValue: initialValue,
          decoration: _decoration,
        ),
//        AccentColorFormTile(
//          initialValue: initialValue,
//          decoration: _decoration,
//        ),
      ],
    );
  }
}

class _HostDetailsForm extends StatelessWidget {
  const _HostDetailsForm({
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
              HostDetailsStatusIcon(),
            ],
          ),
        ),
        BaseUrlFormTile(
          initialValue: initialValue,
          decoration: _decoration,
        ),
        ApiPathFormTile(decoration: _decoration),
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
              AuthenticationStatusIcon(),
            ],
          ),
        ),
        ApiTokenFormTile(
          initialValue: widget.initialValue,
          decoration: _decoration,
        ),
        AllowSelfSignedCertificatesFormTile(decoration: _decoration),
        BasicAuthenticationUsernameFormTile(decoration: _decoration),
        BasicAuthenticationPasswordFormTile(
          initialValue: widget.initialValue,
          decoration: _decoration,
        ),
      ],
    );
  }
}
