import 'package:flutter/material.dart';
import 'package:flutterhole/service/convert.dart';
import 'package:flutterhole/widget/home/percentage_box.dart';
import 'package:flutterhole/widget/layout/scaffold.dart';

class FrequencyTile extends StatelessWidget {
  final String title;
  final int requests;
  final int totalRequests;
  final GestureTapCallback onTap;
  final Color color;

  final double _fraction;

  const FrequencyTile({
    Key key,
    @required this.title,
    @required this.requests,
    this.totalRequests,
    this.onTap,
    this.color = Colors.green,
  })  : _fraction = requests / totalRequests ?? 0,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      onLongPress: () {
        showSnackBar(context, Text(title));
      },
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
              child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    numWithCommas(requests),
                    style: Theme.of(context).textTheme.subtitle,
                  ),
                ],
              ),
              _fraction == double.infinity || _fraction == 0
                  ? Container()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: PercentageBox(
                            color: this.color,
                            width: 100,
                            fraction: _fraction,
                          ),
                        ),
                        Text(
                          '${(_fraction * 100).toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
