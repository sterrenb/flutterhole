import 'package:flutter/material.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/browser_helpers.dart';

const Color _jpegBackgroundColor = Colors.white;
final Color _iconColor = Colors.green.shade900;

const int _subTileCount = 2;

class _Spacer extends StatelessWidget {
  const _Spacer({
    required this.width,
    required this.color,
    Key? key,
  }) : super(key: key);

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: color,
      ),
    );
  }
}

class LogoInspector extends StatefulWidget {
  const LogoInspector({
    Key? key,
    required this.screenWidth,
  }) : super(key: key);

  final double screenWidth;

  @override
  _LogoInspectorState createState() => _LogoInspectorState();
}

class _LogoInspectorState extends State<LogoInspector> {
  Color _color = _iconColor;
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    _color = _iconColor;

    _scrollController = ScrollController(
      initialScrollOffset: widget.screenWidth * 3,
    );

    _scrollController!.addListener(() {
      final offset = _scrollController!.offset;

      final pageOffset = (offset / widget.screenWidth) - 3;

      if (pageOffset <= -1.5) {
        setState(() {
          _color = ThemeData.dark().cardColor;
        });
      } else if (pageOffset >= -0.2 && pageOffset <= 0.2) {
        setState(() {
          _color = _iconColor;
        });
      } else if (pageOffset >= 3) {
        setState(() {
          _color = Colors.purple;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  List<Widget> _buildSpacers(double screenWidth) {
    return <Widget>[
      _Spacer(
        width: screenWidth / _subTileCount,
        color: _jpegBackgroundColor.withOpacity(.2),
      ),
      _Spacer(
        width: screenWidth / _subTileCount,
        color: _jpegBackgroundColor.withOpacity(.4),
      ),
      _Spacer(
        width: screenWidth / _subTileCount,
        color: _jpegBackgroundColor.withOpacity(.6),
      ),
      _Spacer(
        width: screenWidth / _subTileCount,
        color: _jpegBackgroundColor.withOpacity(.8),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      decoration: BoxDecoration(
        color: _color,
      ),
      curve: Curves.easeInOut,
      width: widget.screenWidth * 4,
      child: ListView(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        children: <Widget>[
          SizedBox(
            width: widget.screenWidth,
            child: Stack(
              children: <Widget>[
                Center(
                  child: Image(
                    image: const AssetImage('assets/icons/old_icon.png'),
                    width: widget.screenWidth / 2,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Original logo design'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          ..._buildSpacers(widget.screenWidth / 2),
          ..._buildSpacers(widget.screenWidth / 2).reversed.toList(),
          SizedBox(
            width: widget.screenWidth,
            child: Stack(
              children: <Widget>[
                Center(
                  child: Image(
                    image: const AssetImage('assets/icons/logo.png'),
                    width: widget.screenWidth / 2,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ListTile(
                    // url: KStrings.logoDesignerUrl,
                    onTap: () {
                      launchUrl(KUrls.logoDesignerUrl);
                    },
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Logo design by Mathijs Sterrenburg',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          ..._buildSpacers(widget.screenWidth),
          Container(
            decoration: const BoxDecoration(color: Colors.white),
            child: const Image(
              image: AssetImage('assets/images/logos.jpg'),
            ),
          ),
          ..._buildSpacers(widget.screenWidth / 2).reversed.toList(),
        ],
      ),
    );
  }
}
