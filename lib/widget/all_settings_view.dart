import 'package:flutter/material.dart';
import 'package:flutterhole_again/screen/single_pihole_add_screen.dart';
import 'package:flutterhole_again/screen/single_pihole_edit_screen.dart';
import 'package:flutterhole_again/service/local_storage.dart';

import 'icon_text_button.dart';
import 'list_tab.dart';

class AllSettingsView extends StatefulWidget {
  @override
  _AllSettingsViewState createState() => _AllSettingsViewState();
}

class _AllSettingsViewState extends State<AllSettingsView> {
  LocalStorage _localStorage;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future _init() async {
    final localStorage = await LocalStorage.getInstance();
    print('active: ${localStorage.active()}');
    setState(() {
      _localStorage = localStorage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_localStorage == null || _localStorage.cache.length == 0) {
      return Center(child: CircularProgressIndicator());
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
                itemCount: _localStorage.cache.length,
                itemBuilder: (BuildContext context, int index) {
                  final pihole = _localStorage
                      .cache[_localStorage.cache.keys.elementAt(index)];
                  return ListTile(
                    title: Text(pihole.title),
                    subtitle: Text(pihole.localKey),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    leading: Icon(Icons.check,
                        color: _localStorage.active() == pihole
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
                      await _localStorage.activate(pihole);
                      setState(() {});
                    },
                  );
                }),
          ),
          Row(
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
                  await _localStorage.reset();
                  setState(() {});
                  Scaffold.of(context).showSnackBar(
                      SnackBar(content: Text('Reset to default settings')));
                },
                title: 'Reset to defaults',
                icon: Icons.delete_forever,
                color: Colors.red,
              )
            ],
          ),
        ],
      ),
    );
  }
}
