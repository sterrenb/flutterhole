import 'package:flutter/material.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/views/single_pi_edit_view.dart';
import 'package:flutterhole/widgets/ui/buttons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PiSelectList extends HookConsumerWidget {
  const PiSelectList({
    Key? key,
    this.shrinkWrap = false,
  }) : super(key: key);

  final bool shrinkWrap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const pis = [
      Pi(baseUrl: "http://pi.hole"),
      Pi(
        title: "Home",
        baseUrl: "http://10.0.1.5",
        apiToken: String.fromEnvironment("PIHOLE_API_TOKEN", defaultValue: ""),
      ),
      Pi(title: "Secure", baseUrl: "https://10.0.1.5"),
      Pi(title: "Pub", baseUrl: "http://pub.dev", adminHome: ""),
      Pi(
          title: "Package",
          baseUrl: "https://pub.dev",
          adminHome: "/packages/pihole_api"),
    ];
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final pi = pis.elementAt(index);
        return ListTile(
          title: Text(pi.title),
          minVerticalPadding: 16.0,
          trailing: UrlOutlinedButton(
            url: pi.baseUrl + pi.adminHome,
            text: pi.baseUrl
                .replaceFirst("https://", "")
                .replaceFirst("http://", ""),
          ),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SinglePiEditView(initialValue: pi),
              fullscreenDialog: true,
            ));
          },
        );
      },
      separatorBuilder: (context, index) => const Divider(
        height: 0.0,
        indent: 16.0,
        endIndent: 16.0,
      ),
      itemCount: pis.length,
    );
  }
}
