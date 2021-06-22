import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/pihole_endpoint_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pihole_api/pihole_api.dart';

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

class ActivePiDetailsCacheBuilder extends HookWidget {
  const ActivePiDetailsCacheBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  final ValueWidgetBuilder<Option<PiDetails>> builder;

  @override
  Widget build(BuildContext context) {
    final active = useProvider(activePiDetailsProvider);
    final option = useState(none<PiDetails>());

    useEffect(() {
      active.whenData((value) => option.value = some(value));
    }, [active]);

    return builder(context, option.value, null);
  }
}
