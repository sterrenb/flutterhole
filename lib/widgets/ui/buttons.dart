import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/services/web_service.dart';
import 'package:flutterhole/widgets/layout/responsiveness.dart';

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
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 300.0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.fade,
                // maxLines: 1,
              ),
            ),
            const SizedBox(width: 8.0),
            Icon(
              iconData,
              size: Theme.of(context).textTheme.bodyText2!.fontSize!,
            ),
          ],
        ),
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
    final href = url.contains('://') ? url : 'https://$url';
    return Tooltip(
      message: href,
      child: IconOutlinedButton(
        iconData: KIcons.openUrl,
        text: text ?? url,
        onPressed: () {
          WebService.launchUrlInBrowser(href);
        },
      ),
    );
  }
}

class SquareTextButton extends StatelessWidget {
  const SquareTextButton({
    Key? key,
    required this.label,
    this.onPressed,
  }) : super(key: key);

  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, side: BorderSide.none))),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
            color: context.isLight
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onBackground),
      ),
    );
  }
}

class PushViewButton extends StatelessWidget {
  const PushViewButton({
    Key? key,
    required this.label,
    required this.iconData,
    required this.view,
  }) : super(key: key);

  final String label;
  final IconData iconData;
  final Widget view;

  @override
  Widget build(BuildContext context) {
    void onPressed() {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => view));
    }

    return IconButton(
      onPressed: onPressed,
      tooltip: label,
      icon: Icon(iconData),
    );
  }
}

class MenuIconButton extends StatelessWidget {
  const MenuIconButton({
    Key? key,
    required this.label,
    required this.iconData,
  }) : super(key: key);

  final String label;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Icon(
          iconData,
          color: Theme.of(context).dividerColor,
        ),
      ],
    );
  }
}

class SaveButton extends StatelessWidget {
  const SaveButton({Key? key, required this.onPressed}) : super(key: key);

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SquareTextButton(
      label: 'Save',
      onPressed: onPressed,
    );
  }
}
