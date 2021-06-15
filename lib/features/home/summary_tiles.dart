import 'dart:ui';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/features/grid/grid_layout.dart';
import 'package:flutterhole_web/features/pihole/active_pi.dart';
import 'package:flutterhole_web/features/pihole/pihole_builders.dart';
import 'package:flutterhole_web/features/themes/theme_builders.dart';
import 'package:flutterhole_web/formatting.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:flutterhole_web/top_level_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const Color _foregroundColor = Colors.white;

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

class _SquareContainer extends StatelessWidget {
  const _SquareContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      // color: Colors.orange,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: child,
      ),
    );
  }
}

class NumberTile extends StatelessWidget {
  const NumberTile({
    Key? key,
    required this.iconData,
    required this.child,
    required this.isLoading,
    this.foregroundColor,
    this.backgroundColor,
    this.onTap,
  }) : super(key: key);

  final IconData iconData;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Widget child;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GridCard(
      color: backgroundColor,
      child: GridInkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SquareContainer(
                child: Icon(
              iconData,
              size: 32.0,
              color: foregroundColor?.withOpacity(.5),
            )),
            Expanded(child: child),
            _SquareContainer(
                child: Center(
                    child: Container(
              height: 24.0,
              width: 24.0,
              child: AnimatedOpacity(
                duration: kThemeAnimationDuration,
                opacity: isLoading ? 0.5 : 0.0,
                child: CircularProgressIndicator(
                  color: foregroundColor,
                  // strokeWidth: 10.0,
                ),
              ),
            ))),
          ],
        ),
      ),
    );
  }
}

extension OptionX on Option<PiSummary> {
  String get totalQueries => fold(
      () => '-', (summary) => numberFormat.format(summary.dnsQueriesToday));

  String get queriesBlocked => fold(
      () => '-', (summary) => numberFormat.format(summary.adsBlockedToday));

  String get percentBlocked => fold(() => '-',
      (summary) => summary.adsPercentageToday.toStringAsFixed(2) + '%');

  String get domainsOnBlocklist => fold(
      () => '-', (summary) => numberFormat.format(summary.domainsBeingBlocked));
}

extension ThemeDataX on ThemeData {
  TextStyle get summaryStyle => textTheme.headline4!.copyWith(
        fontWeight: FontWeight.bold,
        color: _foregroundColor,
      );
}

class TotalQueriesTile extends HookWidget {
  const TotalQueriesTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final summaryValue = useProvider(activeSummaryProvider);
    return PiColorsBuilder(
        builder: (context, piColors, __) => NumberTile(
              iconData: KIcons.totalQueries,
              foregroundColor: _foregroundColor,
              backgroundColor: piColors.totalQueries,
              isLoading: summaryValue.maybeWhen(
                loading: () => true,
                orElse: () => false,
              ),
              onTap: () => context
                  .refresh(piSummaryProvider(context.read(activePiProvider))),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TileTitle('Total queries', color: _foregroundColor),
                    ActiveSummaryCacheBuilder(
                        builder: (context, option, _) => Text(
                              option.totalQueries,
                              style: Theme.of(context).summaryStyle,
                            )),
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
        builder: (context, piColors, __) => NumberTile(
              iconData: KIcons.queriesBlocked,
              foregroundColor: _foregroundColor,
              backgroundColor: piColors.queriesBlocked,
              isLoading: summaryValue.maybeWhen(
                loading: () => true,
                orElse: () => false,
              ),
              onTap: () => context
                  .refresh(piSummaryProvider(context.read(activePiProvider))),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TileTitle('Queries blocked', color: _foregroundColor),
                    ActiveSummaryCacheBuilder(
                        builder: (context, option, _) => Text(
                              option.queriesBlocked,
                              style: Theme.of(context).summaryStyle,
                            )),
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
        builder: (context, piColors, __) => NumberTile(
              iconData: KIcons.percentBlocked,
              foregroundColor: _foregroundColor,
              backgroundColor: piColors.percentBlocked,
              isLoading: summaryValue.maybeWhen(
                loading: () => true,
                orElse: () => false,
              ),
              onTap: () => context
                  .refresh(piSummaryProvider(context.read(activePiProvider))),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TileTitle('Queries blocked', color: _foregroundColor),
                    ActiveSummaryCacheBuilder(
                        builder: (context, option, _) => Text(
                              option.percentBlocked,
                              style: Theme.of(context).summaryStyle,
                            )),
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
        builder: (context, piColors, __) => NumberTile(
              iconData: KIcons.domainsOnBlocklist,
              foregroundColor: _foregroundColor,
              backgroundColor: piColors.domainsOnBlocklist,
              isLoading: summaryValue.maybeWhen(
                loading: () => true,
                orElse: () => false,
              ),
              onTap: () => context
                  .refresh(piSummaryProvider(context.read(activePiProvider))),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TileTitle('Queries blocked', color: _foregroundColor),
                    ActiveSummaryCacheBuilder(
                        builder: (context, option, _) => Text(
                              option.domainsOnBlocklist,
                              style: Theme.of(context).summaryStyle,
                            )),
                  ],
                ),
              ),
            ));
  }
}
