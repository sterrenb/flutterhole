import 'package:flutter/material.dart';
import 'package:flutterhole_again/service/local_storage.dart';
import 'package:flutterhole_again/widget/dialog.dart';
import 'package:flutterhole_again/widget/icon_text_button.dart';
import 'package:flutterhole_again/widget/screen/pihole/pihole_add_screen.dart';

class PiholeButtonRow extends StatelessWidget {
  final LocalStorage localStorage;
  final VoidCallback onStateChange;

  const PiholeButtonRow({
    Key key,
    @required this.localStorage,
    @required this.onStateChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        IconTextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PiholeAddScreen(),
              ),
            );
          },
          title: 'Add a new Pihole',
          icon: Icons.add,
          color: Colors.green,
        ),
        IconTextButton(
          onPressed: () async {
            showAlertDialog(
                context,
                Container(
                  child: Text("Do you want to remove all configurations?"),
                ),
                continueText: 'Remove all', onConfirm: () async {
              await localStorage.reset();
              onStateChange();
              Scaffold.of(context).showSnackBar(
                  SnackBar(content: Text('Reset to default configuration')));
            });
          },
          title: 'Reset to defaults',
          icon: Icons.delete_forever,
          color: Colors.red,
        )
      ],
    );
  }
}
