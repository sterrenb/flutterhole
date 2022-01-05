import 'package:flutter/material.dart';
import 'package:flutterhole/widgets/layout/animations.dart';
import 'package:flutterhole/widgets/layout/loading_indicator.dart';

class DashboardCard extends StatelessWidget {
  const DashboardCard({
    Key? key,
    required this.title,
    required this.content,
    this.showTitle = true,
    this.showLoadingIndicator = false,
    this.onTap,
    this.textColor,
    this.cardColor,
  }) : super(key: key);

  final String title;
  final Widget content;
  final bool showTitle;
  final bool showLoadingIndicator;
  final VoidCallback? onTap;
  final Color? textColor;
  final Color? cardColor;

  @override
  Widget build(BuildContext context) {
    return Card(
        color: cardColor,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (showTitle) ...[
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              ?.copyWith(
                                  color: textColor ??
                                      Theme.of(context).colorScheme.primary),
                          maxLines: 3,
                        ),
                      ),
                    ] else ...[
                      Container(),
                    ],
                    AnimatedFader(
                      child: showLoadingIndicator
                          ? LoadingIndicator(
                              size: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  ?.fontSize,
                            )
                          : Container(),
                    ),
                  ],
                ),
              ),
              content,
            ],
          ),
        ));
  }
}

class DashboardFittedTile extends StatelessWidget {
  const DashboardFittedTile({
    Key? key,
    required this.title,
    this.text,
    this.showLoadingIndicator = false,
    this.onTap,
    this.textColor,
    this.cardColor,
  }) : super(key: key);

  final String title;
  final String? text;
  final bool showLoadingIndicator;
  final VoidCallback? onTap;
  final Color? textColor;
  final Color? cardColor;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: title,
      onTap: onTap,
      textColor: textColor,
      cardColor: cardColor,
      showLoadingIndicator: showLoadingIndicator,
      content: Expanded(
          child: Padding(
        padding:
            const EdgeInsets.all(8.0).subtract(const EdgeInsets.only(top: 8.0)),
        child: FittedText(text: text ?? '-'),
      )),
      // content: const Expanded(child: Center(child: Text('TODO'))),
    );
  }
}

class FittedText extends StatelessWidget {
  const FittedText({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
