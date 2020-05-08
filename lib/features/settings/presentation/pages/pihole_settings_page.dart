import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/settings/blocs/pihole_settings_bloc.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:flutterhole/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:flutterhole/widgets/layout/list_title.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PiholeSettingsBloc>(
      create: (_) => PiholeSettingsBloc()
        ..add(PiholeSettingsEvent.validate(widget.initialValue)),
      child: FormBuilder(
        key: _fbKey,
        initialValue: widget.initialValue.toJson(),
        autovalidate: true,
        child: Builder(builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text('${widget.initialValue.title}'),
              actions: <Widget>[
                MaterialButton(
                  child: Text('Validate'),
                  onPressed: () {
                    print(BlocProvider.of<PiholeSettingsBloc>(context));
                  },
                ),
                MaterialButton(
                  child: Text('Reset'),
                  onPressed: () {
                    _fbKey.currentState.reset();
                  },
                ),
                MaterialButton(
                  child: Text('Save'),
                  onPressed: () {
                    if (_fbKey.currentState.saveAndValidate()) {
                      final update =
                          PiholeSettings.fromJson(_fbKey.currentState.value);
                      print(update);

                      getIt<SettingsBloc>().add(
                          SettingsEvent.update(widget.initialValue, update));
                    }
                  },
                ),
              ],
            ),
            body: ListView(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              children: <Widget>[
                ListTitle('Annotation'),
                FormBuilderTextField(
                  attribute: 'title',
                  decoration: InputDecoration(labelText: "Title"),
                  autocorrect: false,
                  textCapitalization: TextCapitalization.words,
                  maxLines: 1,
                  validators: [
                    FormBuilderValidators.required(),
                  ],
                ),
                FormBuilderTextField(
                  attribute: 'description',
                  decoration: InputDecoration(labelText: "Description"),
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 5,
                ),
                ListTitle('Host details'),
                FormBuilderTextField(
                  attribute: 'baseUrl',
                  decoration: InputDecoration(labelText: "Base URL"),
                  autocorrect: false,
                  maxLines: 1,
                ),
                FormBuilderTextField(
                  attribute: 'apiPath',
                  decoration: InputDecoration(labelText: "API path"),
                  autocorrect: false,
                  maxLines: 1,
                ),
                FormBuilderTextField(
                  attribute: 'apiPort',
                  initialValue: widget.initialValue.apiPort.toString(),
                  decoration: InputDecoration(labelText: "API port"),
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
                ListTitle('Authentication'),
                FormBuilderTextField(
                  attribute: 'apiToken',
                  decoration: InputDecoration(labelText: "API token"),
                  autocorrect: false,
                  maxLines: 1,
                  obscureText: true,
                  valueTransformer: (value) => (value ?? '').toString().trim(),
                ),
                FormBuilderCheckbox(
                    attribute: 'allowSelfSignedCertificates',
                    decoration: InputDecoration(border: InputBorder.none),
                    label: Text('Allow self-signed certificates')),
                FlatButton.icon(
                  onPressed: () {
                    _showJsonViewer(context, widget.initialValue);
                  },
                  label: Text('JSON view'),
                  icon: Icon(KIcons.pihole),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
