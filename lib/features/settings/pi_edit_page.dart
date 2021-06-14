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
    // final pi = useProvider(activePiProvider);
    final settings = useProvider(settingsNotifierProvider);
    return Scaffold(
      // drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('My Pi-holes'),
      ),
      body: Column(
        children: [
          HookBuilder(builder: (context) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: settings.allPis.length,
              itemBuilder: (context, index) {
                final pi = settings.allPis.elementAt(index);
                return ListTile(
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
                  onLongPress: () {
                    context
                        .read(settingsNotifierProvider.notifier)
                        .activate(pi.id);
                  },
                  onTap: () async {
                    await pushAndSaveSinglePiRoute(context, pi);

                    // onLongPress: () {
                    // print('setting pi to ${pi.title}');
                    // context.read(singlePiProvider(pi).notifier);
                    // final update = await Navigator.of(context).push<Pi>(
                    //     MaterialPageRoute(
                    //         builder: (context) => SinglePiPage(pi)));
                    //
                    // if (update != null) {
                    //   print('update: ${update.title}');
                    //   context
                    //       .read(settingsNotifierProvider.notifier)
                    //       .save(update);
                    // }
                  },
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
                    // print("result ${str}");
                  },
                  child: Text('all')),
              TextButton(
                  onPressed: () {
                    final x = settings.active
                        .copyWith(title: settings.active.title + '~');
                    context.read(settingsNotifierProvider.notifier).savePi(x);
                  },
                  child: Text('increment')),
              TextButton(
                  onPressed: () {
                    final x = settings.active.copyWith(
                      title: settings.active.title + '!',
                      id: DateTime.now().millisecondsSinceEpoch,
                    );
                    context.read(settingsNotifierProvider.notifier).savePi(x);
                  },
                  child: Text('add')),
            ],
          ),
        ],
      ),
    );
  }
}