import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:flutterhole_web/features/settings/single_pi_page.dart';
import 'package:flutterhole_web/top_level_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MyPiHolesPage extends HookWidget {
  const MyPiHolesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = useProvider(settingsNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('My Pi-holes'),
      ),
      body: Column(
        children: [
          HookBuilder(builder: (context) {
            return PiHoleListBuilder();
          }),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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

class PiHoleListBuilder extends HookWidget {
  const PiHoleListBuilder({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final active = useProvider(activePiProvider);
    final _pis = useProvider(allPisProvider);
    final pis = _pis;
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: pis.length,
      itemBuilder: (context, index) {
        final pi = pis.elementAt(index);
        return ListTile(
          leading: SizedBox(
            width: 50.0,
            height: 50.0,
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                Icon(
                  KIcons.dot,
                  color: pi.primaryColor,
                ),
                Positioned(
                  left: 25 - 8 + 8,
                  bottom: 25 - 8 - 8,
                  child: Icon(
                    KIcons.dot,
                    color: pi.accentColor,
                    size: 16.0,
                  ),
                ),
              ],
            ),
          ),
          title: Text('${pi.title} ${pi.id}'),
          subtitle: Text(pi.baseApiUrl),
          trailing: AnimatedOpacity(
              opacity: pi.id == active.id ? 1 : 0,
              duration: kThemeChangeDuration,
              child: Icon(KIcons.selected)),
          // onLongPress: () {
          //   context.read(settingsNotifierProvider.notifier).activate(pi.id);
          // },
          onTap: () async {
            context.router.pushAndSaveSinglePiRoute(context, pi);
          },
        );
      },
    );
  }
}
