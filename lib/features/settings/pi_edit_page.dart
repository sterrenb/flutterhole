import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:flutterhole_web/features/settings/settings_repository.dart';
import 'package:flutterhole_web/features/settings/single_pi_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PiEditPage extends HookWidget {
  const PiEditPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final pi = useProvider(activePiProvider).state;
    final settings = useProvider(settingsNotifierProvider);
    return Scaffold(
      // drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('Pipis ${settings.active.baseApiUrl}'),
      ),
      body: Column(
        children: [
          HookBuilder(builder: (context) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: settings.allPis.length,
              itemBuilder: (context, index) {
                final pi = settings.allPis.elementAt(index);
                return Container(
                  // decoration: pi.id == settings.active.id
                  //     ? BoxDecoration(
                  //         color: Theme.of(context).accentColor.withOpacity(.2))
                  //     : null,
                  child: ListTile(
                    leading: Icon(
                      KIcons.dot,
                      color: pi.primaryColor,
                    ),
                    title: Text('${pi.title} ${pi.id}'),
                    subtitle: Text(pi.baseApiUrl),
                    trailing: AnimatedOpacity(
                        opacity: pi.id == settings.active.id ? 1 : 0,
                        duration: kThemeChangeDuration,
                        child: Icon(KIcons.selected)),
                    // onTap: () {
                    onLongPress: () {
                      context
                          .read(settingsNotifierProvider.notifier)
                          .activate(pi.id);
                    },
                    onTap: () {
                      // onLongPress: () {
                      print('setting pi to ${pi.title}');
                      context.read(singlePiProvider(pi).notifier);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SinglePiPage(pi)));
                    },
                  ),
                );
              },
            );
          }),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  context.read(settingsNotifierProvider.notifier).reset();
                },
                icon: Icon(KIcons.delete),
                label: Text('Delete all Pi-holes'),
              ),
              TextButton(
                  onPressed: () {
                    final all =
                        context.read(settingsRepositoryProvider).allPis();
                    print(all);
                    // print("result ${str}");
                  },
                  child: Text('all')),
              TextButton(
                  onPressed: () {
                    final x = settings.active
                        .copyWith(title: settings.active.title + '~');
                    context.read(settingsNotifierProvider.notifier).save(x);
                  },
                  child: Text('increment')),
              TextButton(
                  onPressed: () {
                    final x = settings.active.copyWith(
                      title: settings.active.title + '!',
                      id: DateTime.now().millisecondsSinceEpoch,
                    );
                    context.read(settingsNotifierProvider.notifier).save(x);
                  },
                  child: Text('add')),
            ],
          ),
        ],
      ),
    );
  }
}
