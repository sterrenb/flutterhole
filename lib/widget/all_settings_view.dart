import 'package:flutter/material.dart';
import 'package:flutterhole_again/model/pihole.dart';
import 'package:flutterhole_again/screen/single_pihole_add_screen.dart';
import 'package:flutterhole_again/screen/single_pihole_edit_screen.dart';
import 'package:flutterhole_again/service/local_storage.dart';

import 'dismissible_background.dart';
import 'icon_text_button.dart';
import 'list_tab.dart';

class AllSettingsView extends StatefulWidget {
  @override
  _AllSettingsViewState createState() => _AllSettingsViewState();
}

class _AllSettingsViewState extends State<AllSettingsView> {
  LocalStorage localStorage;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future _init() async {
    final instance = await LocalStorage.getInstance();
    print('active: ${instance.active()}');
    setState(() {
      localStorage = instance;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (localStorage == null) {
      return Center(child: CircularProgressIndicator());
    }

    if (localStorage.cache.length == 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('No Piholes found.'),
          PiholeButtonRow(localStorage: localStorage),
        ],
      );
    }

    return SafeArea(
      minimum: EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          ListTab('Pihole settings'),
          Flexible(
            fit: FlexFit.loose,
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: localStorage.cache.length,
                itemBuilder: (BuildContext context, int index) {
                  final pihole = localStorage
                      .cache[localStorage.cache.keys.elementAt(index)];
                  return Dismissible(
                    key: Key(pihole.title),
                    onDismissed: (direction) async {
                      final didRemove = await localStorage.remove(pihole);

                      if (didRemove) {
                        Scaffold.of(context).showSnackBar(
                            SnackBar(content: Text('Removed ${pihole.title}')));
                      } else {
                        Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text('Could not remove ${pihole.title}')));
                      }
                    },
                    background: DismissibleBackground(),
                    secondaryBackground:
                        DismissibleBackground(alignment: Alignment.centerRight),
                    child: PiholeTile(
                      localStorage: localStorage,
                      pihole: pihole,
                      onStateChange: () {
                        setState(() {});
                      },
                    ),
                  );
                }),
          ),
          PiholeButtonRow(
            localStorage: localStorage,
            onStateChange: () {
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}

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
                builder: (context) => SinglePiholeAddScreen(),
              ),
            );
          },
          title: 'Add a new Pihole',
          icon: Icons.add,
          color: Colors.green,
        ),
        IconTextButton(
          onPressed: () async {
            await localStorage.reset();
            onStateChange();
            Scaffold.of(context).showSnackBar(
                SnackBar(content: Text('Reset to default settings')));
          },
          title: 'Reset to defaults',
          icon: Icons.delete_forever,
          color: Colors.red,
        )
      ],
    );
  }
}

class PiholeTile extends StatelessWidget {
  final LocalStorage localStorage;
  final Pihole pihole;
  final VoidCallback onStateChange;

  const PiholeTile(
      {Key key,
      @required this.localStorage,
      @required this.pihole,
      @required this.onStateChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(pihole.title),
      subtitle: Text(pihole.localKey),
      trailing: Icon(Icons.keyboard_arrow_right),
      leading: Icon(Icons.check,
          color: localStorage.active() == pihole
              ? Theme.of(context).primaryColor
              : Colors.black.withOpacity(0.0)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SinglePiholeEditScreen(
                  pihole: pihole,
                ),
          ),
        );
      },
      onLongPress: () async {
        await localStorage.activate(pihole);
        onStateChange();
      },
    );
  }
}
