import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/dialogs.dart';
import 'package:flutterhole_web/features/formatting/entity_formatting.dart';
import 'package:flutterhole_web/features/grid/grid_layout.dart';
import 'package:flutterhole_web/features/home/dash_tiles.dart';
import 'package:flutterhole_web/features/pihole/pihole_builders.dart';
import 'package:flutterhole_web/features/pihole/pihole_providers.dart';
import 'package:flutterhole_web/features/settings/active_providers.dart';
import 'package:flutterhole_web/features/themes/theme_builders.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pihole_api/pihole_api.dart';

@Deprecated('fps_hog')
class TextProgressIndicator extends StatelessWidget {
  const TextProgressIndicator({
    Key? key,
    this.text = '---------',
    required this.textStyle,
  }) : super(key: key);

  final String text;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return AnimatedTextKit(
      animatedTexts: [
        TypewriterAnimatedText(
          text,
          cursor: '-',
          speed: kThemeAnimationDuration * 2,
          textStyle: textStyle,
        ),
      ],
      repeatForever: true,
    );
  }
}

extension OptionX on Option<PiSummary> {
  String get totalQueries => fold(
      () => '---', (summary) => numberFormat.format(summary.dnsQueriesToday));

  String get queriesBlocked => fold(
      () => '---', (summary) => numberFormat.format(summary.adsBlockedToday));

  String get percentBlocked => fold(() => '---',
      (summary) => summary.adsPercentageToday.toStringAsFixed(2) + '%');

  String get domainsOnBlocklist => fold(() => '---',
      (summary) => numberFormat.format(summary.domainsBeingBlocked));
}

class TotalQueriesTile extends HookWidget {
  const TotalQueriesTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final summaryValue = useProvider(activeSummaryProvider);
    return PiColorsBuilder(
        builder: (context, piColors, __) => WideNumberTile(
              iconData: KIcons.totalQueries,
              foregroundColor: kDashTileColor,
              backgroundColor: piColors.totalQueries,
              isLoading: summaryValue.maybeWhen(
                loading: () => true,
                orElse: () => false,
              ),
              onTap: () => summaryValue.when(
                data: (summary) => context.refresh(
                    piSummaryProvider(context.read(activePiParamsProvider))),
                loading: () => null,
                error: (e, s) => showErrorDialog(context, e),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const TileTitle('Total queries', color: kDashTileColor),
                    summaryValue.maybeWhen(
                      error: (e, s) => Text(
                        '---',
                        style: Theme.of(context).summaryStyle,
                      ),
                      orElse: () => ActiveSummaryCacheBuilder(
                          builder: (context, option, _) => Text(
                                option.totalQueries,
                                style: Theme.of(context).summaryStyle,
                              )),
                    ),
                  ],
                ),
              ),
            ));
  }
}

class QueriesBlockedTile extends HookWidget {
  const QueriesBlockedTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final summaryValue = useProvider(activeSummaryProvider);
    return PiColorsBuilder(
        builder: (context, piColors, __) => WideNumberTile(
              iconData: KIcons.queriesBlocked,
              foregroundColor: kDashTileColor,
              backgroundColor: piColors.queriesBlocked,
              isLoading: summaryValue.maybeWhen(
                loading: () => true,
                orElse: () => false,
              ),
              onTap: () => summaryValue.when(
                data: (summary) => context.refresh(
                    piSummaryProvider(context.read(activePiParamsProvider))),
                loading: () => null,
                error: (e, s) => showErrorDialog(context, e),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const TileTitle('Queries blocked', color: kDashTileColor),
                    summaryValue.maybeWhen(
                      error: (e, s) => Text(
                        '---',
                        style: Theme.of(context).summaryStyle,
                      ),
                      orElse: () => ActiveSummaryCacheBuilder(
                          builder: (context, option, _) => Text(
                                option.queriesBlocked,
                                style: Theme.of(context).summaryStyle,
                              )),
                    ),
                  ],
                ),
              ),
            ));
  }
}

class PercentBlockedTile extends HookWidget {
  const PercentBlockedTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final summaryValue = useProvider(activeSummaryProvider);
    return PiColorsBuilder(
        builder: (context, piColors, __) => WideNumberTile(
              iconData: KIcons.percentBlocked,
              foregroundColor: kDashTileColor,
              backgroundColor: piColors.percentBlocked,
              isLoading: summaryValue.maybeWhen(
                loading: () => true,
                orElse: () => false,
              ),
              onTap: () => summaryValue.when(
                data: (summary) => context.refresh(
                    piSummaryProvider(context.read(activePiParamsProvider))),
                loading: () => null,
                error: (e, s) => showErrorDialog(context, e),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const TileTitle('Queries blocked', color: kDashTileColor),
                    summaryValue.maybeWhen(
                      error: (e, s) => Text(
                        '---',
                        style: Theme.of(context).summaryStyle,
                      ),
                      orElse: () => ActiveSummaryCacheBuilder(
                          builder: (context, option, _) => Text(
                                option.percentBlocked,
                                style: Theme.of(context).summaryStyle,
                              )),
                    ),
                  ],
                ),
              ),
            ));
  }
}

class DomainsOnBlocklistTile extends HookWidget {
  const DomainsOnBlocklistTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final summaryValue = useProvider(activeSummaryProvider);
    return PiColorsBuilder(
        builder: (context, piColors, __) => WideNumberTile(
              iconData: KIcons.domainsOnBlocklist,
              foregroundColor: kDashTileColor,
              backgroundColor: piColors.domainsOnBlocklist,
              isLoading: summaryValue.maybeWhen(
                loading: () => true,
                orElse: () => false,
              ),
              onTap: () => summaryValue.when(
                data: (summary) => context.refresh(
                    piSummaryProvider(context.read(activePiParamsProvider))),
                loading: () => null,
                error: (e, s) => showErrorDialog(context, e),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const TileTitle('Domains on blocklist',
                        color: kDashTileColor),
                    summaryValue.maybeWhen(
                      error: (e, s) => Text(
                        '---',
                        style: Theme.of(context).summaryStyle,
                      ),
                      orElse: () => ActiveSummaryCacheBuilder(
                          builder: (context, option, _) => Text(
                                option.domainsOnBlocklist,
                                style: Theme.of(context).summaryStyle,
                              )),
                    ),
                  ],
                ),
              ),
            ));
  }
}
