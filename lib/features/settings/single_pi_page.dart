import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/features/grid/grid_layout.dart';
import 'package:flutterhole_web/features/layout/code_card.dart';
import 'package:flutterhole_web/features/settings/single_pi_grid.dart';
import 'package:flutterhole_web/features/settings/single_pi_tiles.dart';
import 'package:flutterhole_web/features/settings/themes.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// final singlePiProvider = StateProvider.autoDispose<Pi>((ref) => debugPis.first);

final whitespaceFormatter =
    FilteringTextInputFormatter.deny(RegExp(r"\s\b|\b\s"));

class SinglePiNotifier extends StateNotifier<Pi> {
  SinglePiNotifier(Pi initial) : super(initial);

  void update(Pi pi) => state = pi;

  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  void updateBaseUrl(String url) {
    state = state.copyWith(baseUrl: url);
  }

  void updateUseSsl(bool value) {
    state = state.copyWith(useSsl: value);
  }

  void updateApiPath(String apiPath) {
    state = state.copyWith(apiPath: apiPath);
  }

  void updateApiPort(int port) {
    state = state.copyWith(apiPort: port);
  }

  void updatePrimaryColor(Color color) {
    state = state.copyWith(primaryColor: color);
  }

  void updateAccentColor(Color color) {
    state = state.copyWith(accentColor: color);
  }
}

final singlePiProvider = StateNotifierProvider.autoDispose
    .family<SinglePiNotifier, Pi, Pi>((ref, initial) {
  print('returning notifier for ${initial.title}');
  return SinglePiNotifier(initial);
});

class SinglePiPage extends HookWidget {
  const SinglePiPage(
    this.initial, {
    Key? key,
  }) : super(key: key);

  static final colors = [
    Color(0xFF341037),
    Color(0xFF8A0A3D),
    Color(0xFFB5171D),
    ...Colors.primaries,
    ...Colors.accents
  ];
  final Pi initial;

  @override
  Widget build(BuildContext context) {
    final pi = useProvider(singlePiProvider(initial));
    final n = context.read(singlePiProvider(initial).notifier);
    final pageController = useScrollController();
    final titleController = useTextEditingController(text: pi.title);
    final baseUrlController = useTextEditingController(text: pi.baseUrl);
    final apiPathController = useTextEditingController(text: pi.apiPath);
    final apiTokenController = useTextEditingController(text: pi.apiToken);
    final apiPortController =
        useTextEditingController(text: initial.apiPort.toString());

    final scrollPosition = useState(1.0);

    useEffect(() {
      pageController.addListener(() {
        scrollPosition.value =
            (1 - pageController.position.pixels / kToolbarHeight).clamp(0, 1);
      });
    }, [pageController]);

    useEffect(() {
      titleController.addListener(() {
        n.update(pi.copyWith(title: titleController.text));
      });
    }, [titleController]);

    useEffect(() {
      baseUrlController.addListener(() {
        n.update(pi.copyWith(baseUrl: baseUrlController.text));
      });
    }, [baseUrlController]);

    useEffect(() {
      apiPathController.addListener(() {
        n.update(pi.copyWith(apiPath: apiPathController.text));
      });
    }, [apiPathController]);

    useEffect(() {
      apiTokenController.addListener(() {
        n.update(pi.copyWith(apiToken: apiTokenController.text));
      });
    }, [apiTokenController]);

    useEffect(() {
      apiPortController.addListener(() {
        n.update(
            pi.copyWith(apiPort: int.tryParse(apiPortController.text) ?? 80));
      });
    }, [apiPortController]);

    final Map<StaggeredTile, Widget> items = {
      StaggeredTile.extent(4, kToolbarHeight * 2): Container(),
      StaggeredTile.count(4, 1): TitleCard(titleController),
      StaggeredTile.count(4, 1):
          const GridSectionHeader('Host details', KIcons.host),
      StaggeredTile.count(2, 1):
          BaseUrlCard(baseUrlController: baseUrlController, useSsl: pi.useSsl),
      StaggeredTile.count(2, 2):
          ApiPortCard(apiPortController: apiPortController),
      StaggeredTile.count(2, 1):
          ApiPathCard(apiPathController: apiPathController),
      StaggeredTile.count(2, 1): UseSslCard(
        pi: pi,
        onChanged: (value) {
          if (value != null) n.updateUseSsl(value);
        },
        onTap: () {
          n.updateUseSsl(!pi.useSsl);
        },
      ),
      // StaggeredTile.count(2, 1): Container(),
      StaggeredTile.count(2, 1): SummaryTestTile(pi: pi),

      StaggeredTile.count(4, 1):
          const GridSectionHeader('Authentication', KIcons.authentication),
      StaggeredTile.count(3, 1):
          ApiTokenCard(apiTokenController: apiTokenController),
      StaggeredTile.count(1, 1): Tooltip(
        message: 'Scan QR code',
        child: PiGridCard(
          onTap: () {},
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Icon(
                KIcons.qrCode,
                // size: constraints.maxHeight / 2,
              );
            },
          ),
        ),
      ),

      StaggeredTile.count(4, 1):
          const GridSectionHeader('Customization', KIcons.customization),
      StaggeredTile.count(2, 2): ColorCard(
          title: 'Primary color',
          currentColor: pi.primaryColor,
          colors: colors,
          onSelected: (selected) {
            n.updatePrimaryColor(selected);
          }),
      StaggeredTile.count(2, 2): ColorCard(
          title: 'Accent color',
          currentColor: pi.accentColor,
          colors: colors.reversed.toList(),
          onSelected: (selected) {
            n.updateAccentColor(selected);
          }),
      StaggeredTile.count(3, 2): CodeCard(
        pi.toString(),
        tappable: false,
        expanded: false,
        onTap: () {},
      ),
      StaggeredTile.count(4, 1): Container(),
    };

    return PiTheme(
      pi: pi,
      child: Builder(
        builder: (context) => Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            title: AnimatedOpacity(
                duration: kThemeAnimationDuration,
                opacity: scrollPosition.value > 0.4 ? 1 : 0,
                child: Text('Editing ${pi.title}')),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Tooltip(
                    message: 'Save changes',
                    child: ElevatedButton(
                      onPressed: pi != initial
                          ? () {
                              Navigator.of(context).pop(pi);
                            }
                          : null,
                      child: Text(
                        'Save',
                        style: TextStyle(
                          color: pi.primaryColor.computeForegroundColor(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SinglePiGrid(
              pageController: pageController,
              tiles: items.keys.toList(),
              children: items.values.toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class UseSslCard extends StatelessWidget {
  const UseSslCard({
    Key? key,
    required this.pi,
    required this.onChanged,
    required this.onTap,
  }) : super(key: key);

  final Pi pi;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DoublePiGridCard(
      left: Center(child: TileTitle('Use SSL')),
      right: Center(
        child: Checkbox(
          activeColor: pi.primaryColor,
          checkColor: pi.primaryColor.computeForegroundColor(),
          value: pi.useSsl,
          onChanged: onChanged,
        ),
      ),
      onTap: onTap,
    );
  }
}

class ApiPathCard extends StatelessWidget {
  const ApiPathCard({
    Key? key,
    required this.apiPathController,
  }) : super(key: key);

  final TextEditingController apiPathController;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: TileTextField(
        controller: apiPathController,
        textAlign: TextAlign.start,
        style: Theme.of(context).textTheme.headline6,
        keyboardType: TextInputType.url,
        inputFormatters: [
          LengthLimitingTextInputFormatter(30),
          FilteringTextInputFormatter.singleLineFormatter,
          whitespaceFormatter,
        ],
        hintText: 'API path',

        // keyboardType: TextInputType.text,
        // minLines: 1,
        // maxLines: 1,
      ),
    );
  }
}

class ApiPortCard extends StatelessWidget {
  const ApiPortCard({
    Key? key,
    required this.apiPortController,
  }) : super(key: key);

  final TextEditingController apiPortController;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: TileTextField(
        controller: apiPortController,
        style: Theme.of(context).textTheme.headline6,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(5),
          FilteringTextInputFormatter.singleLineFormatter,
        ],
        hintText: 'API port',
      ),
    );
  }
}

class ApiTokenCard extends HookWidget {
  const ApiTokenCard({
    Key? key,
    required this.apiTokenController,
  }) : super(key: key);

  final TextEditingController apiTokenController;

  @override
  Widget build(BuildContext context) {
    final show = useState(true);
    return Card(
      child: Center(
        child: TileTextField(
          controller: apiTokenController,
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.headline6,
          keyboardType: TextInputType.visiblePassword,
          inputFormatters: [
            LengthLimitingTextInputFormatter(200),
            FilteringTextInputFormatter.singleLineFormatter,
            whitespaceFormatter,
          ],
          hintText: 'API token',
          obscureText: !show.value,
          // expands: !show.value,
          maxLines: show.value ? null : 1,
          expands: show.value,
          decoration: InputDecoration(
            suffixIcon: IconButton(
              onPressed: () {
                show.value = !show.value;
              },
              icon: Icon(
                  show.value ? KIcons.toggleInvisible : KIcons.toggleVisible),
            ),
          ),
          // minLines: 1,
          // maxLines: 1,
        ),
      ),
    );
  }
}

class BaseUrlCard extends StatelessWidget {
  const BaseUrlCard({
    Key? key,
    required this.baseUrlController,
    required this.useSsl,
  }) : super(key: key);

  final TextEditingController baseUrlController;
  final bool useSsl;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: TileTextField(
        controller: baseUrlController,
        style: Theme.of(context).textTheme.headline6,
        keyboardType: TextInputType.url,
        textAlign: TextAlign.start,
        inputFormatters: [
          LengthLimitingTextInputFormatter(30),
          FilteringTextInputFormatter.singleLineFormatter,
          whitespaceFormatter,
        ],
        hintText: 'Base URL',
        decoration: InputDecoration(
          prefixText: useSsl ? 'https://' : 'http://',
        ),
      ),
    );
  }
}

class TitleCard extends StatelessWidget {
  const TitleCard(
    this.titleController, {
    Key? key,
  }) : super(key: key);

  final TextEditingController titleController;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: TileTextField(
        controller: titleController,
        style: Theme.of(context).textTheme.headline5,
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.sentences,
        inputFormatters: [
          LengthLimitingTextInputFormatter(30),
          FilteringTextInputFormatter.singleLineFormatter,
        ],
        hintText: 'Title',
      ),
    );
  }
}
