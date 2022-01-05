import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/services/web_service.dart';

class IconOutlinedButton extends StatelessWidget {
  const IconOutlinedButton({
    Key? key,
    required this.iconData,
    required this.text,
    this.onPressed,
    this.color,
  }) : super(key: key);

  final IconData iconData;
  final String text;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        primary: color,
        side: color != null ? BorderSide(color: color!) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text),
          const SizedBox(width: 8.0),
          Icon(
            iconData,
            size: Theme.of(context).textTheme.bodyText2!.fontSize!,
          ),
        ],
      ),
      onPressed: onPressed,
    );
  }
}

class UrlOutlinedButton extends StatelessWidget {
  const UrlOutlinedButton({Key? key, required this.url, this.text})
      : super(key: key);

  final String url;
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: url,
      child: IconOutlinedButton(
        iconData: KIcons.openUrl,
        text: text ?? url,
        onPressed: () {
          WebService.launchUrlInBrowser(url);
        },
      ),
    );
  }
}

class PushViewIconButton extends StatelessWidget {
  const PushViewIconButton({
    Key? key,
    required this.iconData,
    required this.view,
  }) : super(key: key);

  final IconData iconData;
  final Widget view;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => view));
        },
        icon: Icon(iconData));
  }
}
