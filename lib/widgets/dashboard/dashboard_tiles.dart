import 'package:flutter/material.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:google_fonts/google_fonts.dart';

class EntryTileBuilder extends StatelessWidget {
  const EntryTileBuilder({
    Key? key,
    required this.entry,
  }) : super(key: key);

  final DashboardEntry entry;

  @override
  Widget build(BuildContext context) {
    switch (entry.id) {
      // case DashboardID.percentBlocked:
      //   return Text('hi');
      default:
        return DashboardCard(
          title: entry.id.toReadable(),
          showTitle: entry.constraints.when(
            count: (cross, main) => cross > 1 || main > 1,
            extent: (cross, extent) => cross > 1,
            fit: (cross) => cross > 1,
          ),
        );
    }
  }
}

class DashboardCard extends StatelessWidget {
  const DashboardCard({
    Key? key,
    required this.title,
    this.showTitle = true,
  }) : super(key: key);

  final String title;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    return Card(
        // color: Theme.of(context).colorScheme.primary,
        elevation: 5.0,
        child: InkWell(
          onTap: () {},
          child: SafeArea(
            minimum: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showTitle) ...[
                  const SizedBox(height: 8.0),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.subtitle1,
                  )
                ],
                const FittedText(text: '921,85'),
              ],
            ),
          ),
        ));
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
    return Expanded(
      child: FittedBox(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
