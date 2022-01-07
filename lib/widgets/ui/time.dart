import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/widgets/ui/periodic_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

class DifferenceText extends HookConsumerWidget {
  const DifferenceText(this.dateTime, {Key? key, this.textStyle})
      : super(key: key);

  final DateTime dateTime;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = useState(DateTime.now());
    final duration = now.value.difference(dateTime);
    final dif = now.value.subtract(duration);

    return PeriodicWidget(
      onTimer: (timer) {
        now.value = now.value.add(kPeriodicInterval);
      },
      child: Text(
        timeago.format(dif).capitalizeFirstLetter,
        style: textStyle ?? Theme.of(context).textTheme.caption,
      ),
    );
  }
}
