import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/pihole/bloc.dart';
import 'package:flutterhole/widget/layout/dialog.dart';
import 'package:flutterhole/widget/layout/icon_text_button.dart';
import 'package:flutterhole/widget/screen/pihole_screen.dart';

class PiholeButtonRow extends StatelessWidget {
//  final VoidCallback onStateChange;

//  const PiholeButtonRow({
//    Key key,
//    @required this.onStateChange,
//  }) : super(key: key);

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
              BlocProvider.of<PiholeBloc>(context).dispatch(ResetPiholes());
//              onStateChange();
              Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('Resetting to default configuration')));
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
