import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutterhole/features/settings/blocs/pihole_settings_bloc.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:flutterhole/features/settings/presentation/widgets/form/allow_self_signed_certificates_form_tile.dart';
import 'package:flutterhole/features/settings/presentation/widgets/form/api_path_form_tile.dart';
import 'package:flutterhole/features/settings/presentation/widgets/form/api_token_form_tile.dart';
import 'package:flutterhole/features/settings/presentation/widgets/form/base_url_form_tile.dart';

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
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
  int currentStep = 0;

  static const PiholeSettings initialValue = PiholeSettings();

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
            ),
            body: CustomScrollView(
              slivers: <Widget>[
                SliverFillRemaining(
                  child: Stepper(
//                type: StepperType.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    onStepTapped: (int index) {
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
                    steps: <Step>[
                      Step(
                          title: Text('Host details'),
                          content: _StepperForm(children: <Widget>[
                            BaseUrlFormTile(
                              initialValue: initialValue,
                              decoration: _decoration,
                            ),
                            ApiPathFormTile(decoration: _decoration),
                          ]),
                          isActive: currentStep == 0),
                      Step(
                          title: Text('Authentication'),
                          content: _StepperForm(children: <Widget>[
                            ApiTokenFormTile(
                              initialValue: initialValue,
                              decoration: _decoration,
                            ),
                            AllowSelfSignedCertificatesFormTile(
                                decoration: _decoration),
                          ]),
                          isActive: currentStep == 1),
                      Step(
                          title: Text('Annotation'),
                          content: Text('Annotation'),
                          isActive: currentStep == 2),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
