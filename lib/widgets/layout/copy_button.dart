import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/widgets/layout/snackbars.dart';

const String _tooltip = 'Copy to clipboard';

/// An [IconButton] with copy-to-clipboard support.
///
/// If [onCopy] is `null`, shows a [SnackBar].
class CopyIconButton extends StatelessWidget {
  const CopyIconButton(
    this.data, {
    Key key,
    this.onCopy,
  })  : assert(data != null),
        super(key: key);

  final String data;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        tooltip: _tooltip,
        icon: Icon(KIcons.copy),
        onPressed: () {
          Clipboard.setData(ClipboardData(text: data)).then((_) {
            if (onCopy != null)
              onCopy();
            else
              showInfoSnackBar(
                context,
                'Copied to clipboard: $data',
              );
          });
        });
  }
}

/// A [FlatButton] with copy-to-clipboard support.
///
/// If [onCopy] is `null`, shows a [SnackBar].
class CopyFlatButton extends StatelessWidget {
  const CopyFlatButton(
    this.data, {
    Key key,
    this.onCopy,
  })  : assert(data != null),
        super(key: key);

  final String data;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return FlatButton.icon(
        label: Text(_tooltip),
        icon: Icon(KIcons.copy),
        onPressed: () {
          Clipboard.setData(ClipboardData(text: data)).then((_) {
            if (onCopy != null)
              onCopy();
            else
              showInfoSnackBar(
                context,
                'Copied to clipboard: $data',
              );
          });
        });
  }
}

class AnimatedCopyTile extends StatefulWidget {
  const AnimatedCopyTile(
    this.data, {
    Key key,
  }) : super(key: key);

  final String data;

  @override
  _AnimatedCopyTileState createState() => _AnimatedCopyTileState();
}

class _AnimatedCopyTileState extends State<AnimatedCopyTile> {
  bool copied = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _tooltip,
      child: ListTile(
        title: Text(widget.data),
        onTap: () async {
          setState(() {
            copied = true;
          });

          Clipboard.setData(ClipboardData(text: widget.data));
          await Future.delayed(Duration(seconds: 2));
          setState(() {
            copied = false;
          });
        },
        trailing: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            AnimatedOpacity(
              opacity: copied ? 1 : 0,
              duration: kThemeChangeDuration,
              child: Icon(
                KIcons.success,
                color: KColors.success,
              ),
            ),
            AnimatedOpacity(
              opacity: copied ? 0 : 1,
              duration: kThemeChangeDuration,
              child: Icon(
                KIcons.copy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
