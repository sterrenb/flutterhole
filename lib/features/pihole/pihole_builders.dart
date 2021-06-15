import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/features/pihole/active_pi.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ActiveSummaryCacheBuilder extends HookWidget {
  const ActiveSummaryCacheBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  final ValueWidgetBuilder<Option<PiSummary>> builder;

  @override
  Widget build(BuildContext context) {
    final active = useProvider(activeSummaryProvider);
    final option = useState(none<PiSummary>());

    useEffect(() {
      active.whenData((value) => option.value = some(value));
    }, [active]);

    return builder(context, option.value, null);
  }
}
