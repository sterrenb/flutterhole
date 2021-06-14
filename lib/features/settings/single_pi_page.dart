import 'dart:convert';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/features/grid/grid_layout.dart';
import 'package:flutterhole_web/features/home/dashboard_grid.dart';
import 'package:flutterhole_web/features/layout/code_card.dart';
import 'package:flutterhole_web/features/routing/app_router.gr.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:flutterhole_web/features/settings/single_pi_grid.dart';
import 'package:flutterhole_web/features/settings/single_pi_tiles.dart';
import 'package:flutterhole_web/features/settings/themes.dart';
import 'package:flutterhole_web/models.dart';
import 'package:flutterhole_web/pihole_repository.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

// final singlePiProvider = StateProvider.autoDispose<Pi>((ref) => debugPis.first);

final whitespaceFormatter =
    FilteringTextInputFormatter.deny(RegExp(r"\s\b|\b\s"));

class SinglePiNotifier extends StateNotifier<Pi> {
  SinglePiNotifier(Pi initial) : super(initial);

  // void update(Pi pi) => state = pi;

  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  void updateBaseUrl(String url) {
    state = state.copyWith(baseUrl: url);
  }

  void updateUseSsl(bool value) {
    state = state.copyWith(useSsl: value);
  }

  void updateApiTokenRequired(bool value) {
    state = state.copyWith(apiTokenRequired: value);
  }

  void updateAllowSelfSignedCertificates(bool value) {
    state = state.copyWith(allowSelfSignedCertificates: value);
  }

  void updateApiPath(String apiPath) {
    state = state.copyWith(apiPath: apiPath);
  }

  void updateApiToken(String token) {
    state = state.copyWith(apiToken: token);
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
  return SinglePiNotifier(initial);
});

Future<void> pushAndSaveSinglePiRoute(BuildContext context, Pi initial) async {
  await context.router.push(SinglePiRoute(
    initial: initial,
    onSave: (update) {
      context.read(settingsNotifierProvider.notifier).savePi(update);

      context.read(piholeStatusNotifierProvider.notifier).ping();
    },
  ));
}

class SinglePiPage extends HookWidget {
  const SinglePiPage({
    required this.initial,
    required this.onSave,
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
  final ValueChanged<Pi> onSave;

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
    final hasChanges = pi != initial;

    useEffect(() {
      pageController.addListener(() {
        scrollPosition.value =
            (1 - pageController.position.pixels / kToolbarHeight).clamp(0, 1);
      });
    }, [pageController]);

    useEffect(() {
      titleController.addListener(() {
        n.updateTitle(titleController.text);
      });
    }, [titleController]);

    useEffect(() {
      baseUrlController.addListener(() {
        n.updateBaseUrl(baseUrlController.text);
      });
    }, [baseUrlController]);

    useEffect(() {
      apiPathController.addListener(() {
        n.updateApiPath(apiPathController.text);
      });
    }, [apiPathController]);

    useEffect(() {
      apiTokenController.addListener(() {
        print('update: ${apiTokenController.text}');
        n.updateApiToken(apiTokenController.text);
      });
    }, [apiTokenController]);

    useEffect(() {
      apiPortController.addListener(() {
        n.updateApiPort(int.tryParse(apiPortController.text) ?? 80);
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

      StaggeredTile.count(3, 1): ApiTokenCard(
        apiTokenController: apiTokenController,
        pi: pi,
      ),

      StaggeredTile.count(1, 1): QrScanCard(
        onScan: (scan) {
          apiTokenController.text = scan;
        },
        pi: pi,
      ),
      StaggeredTile.count(2, 2): UseApiKeyCard(
        value: pi.apiTokenRequired,
        onChanged: (value) {
          if (value != null) n.updateApiTokenRequired(value);
        },
      ),
      StaggeredTile.count(2, 2): AllowSelfSignedCertificatesCard(
        value: pi.allowSelfSignedCertificates,
        onChanged: (value) {
          if (value != null) n.updateAllowSelfSignedCertificates(value);
        },
      ),
      StaggeredTile.count(2, 1): VersionsTestTile(pi: pi),

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
      StaggeredTile.count(4, 1): SelectTilesTile(),
      StaggeredTile.count(4, 4): ExpandableCode(
        (input) {
          JsonEncoder encoder = new JsonEncoder.withIndent('  ');
          String pretty = encoder.convert(input);
          return pretty;
        }(PiModel.fromEntity(pi).toJson()),
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
              ElevatedSaveButton(
                onPressed: () {
                  if (hasChanges) {
                    onSave(pi);
                  }

                  context.router.pop();
                },
              ),
            ],
          ),
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: PageGrid(
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

class UseApiKeyCard extends StatelessWidget {
  const UseApiKeyCard({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return TriplePiGridCard(
      onTap: () => onChanged(!value),
      left: Center(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('Require API key'),
      )),
      right: Checkbox(
        value: value,
        onChanged: onChanged,
      ),
      bottom: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'If your Pi-hole does not have an API token, disable this option and leave the API key empty.',
            style: Theme.of(context).textTheme.caption,
          ),
        ),
      ),
    );
  }
}

class AllowSelfSignedCertificatesCard extends StatelessWidget {
  const AllowSelfSignedCertificatesCard({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return TriplePiGridCard(
      onTap: () => onChanged(!value),
      left: Center(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Allow self signed certificates',
        ),
      )),
      right: Checkbox(
        value: value,
        onChanged: onChanged,
      ),
      bottom: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Trust all certificates, even when the TLS handshake fails. Useful when using SSL with your own certificate.',
            style: Theme.of(context).textTheme.caption,
          ),
        ),
      ),
    );
  }
}

class TextSaveButton extends StatelessWidget {
  const TextSaveButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Tooltip(
          message: 'Save changes',
          child: TextButton(
            onPressed: onPressed,
            child: Text(
              'Save',
              style: TextStyle(
                color: Theme.of(context).buttonColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ElevatedSaveButton extends StatelessWidget {
  const ElevatedSaveButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Tooltip(
          message: 'Save changes',
          child: ElevatedButton(
            onPressed: onPressed,
            child: Text(
              'Save',
              style: TextStyle(
                color: Theme.of(context).buttonColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QrScanCard extends StatelessWidget {
  const QrScanCard({
    Key? key,
    required this.onScan,
    required this.pi,
  }) : super(key: key);

  final ValueChanged<String> onScan;
  final Pi pi;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? onTap = () async {
      final barcode = await showModal<String>(
        context: context,
        builder: (context) {
          return _QrScanDialog();
        },
      );

      if (barcode != null) onScan(barcode);
    };

    return Tooltip(
      message: 'Scan QR code',
      child: PiGridCard(
        onTap: onTap,
        child: IconButton(
          icon: Icon(
            KIcons.qrCode,
            // size: constraints.maxHeight / 2,
          ),
          onPressed: onTap,
        ),
      ),
    );
  }
}

class _QrScanDialog extends StatefulWidget {
  const _QrScanDialog({
    Key? key,
  }) : super(key: key);

  @override
  _QrScanDialogState createState() => _QrScanDialogState();
}

class _QrScanDialogState extends State<_QrScanDialog> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  void onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (mounted) {
        setState(() {
          Navigator.of(context).pop(scanData.code);
        });
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: onQRViewCreated,
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
    required this.pi,
  }) : super(key: key);

  final TextEditingController apiTokenController;
  final Pi pi;

  @override
  Widget build(BuildContext context) {
    final show = useState(true);
    return Card(
      child: Center(
        child: TileTextField(
          // enabled: pi.apiTokenRequired,
          controller: apiTokenController,
          textAlign: TextAlign.start,
          style: apiTokenController.text.isEmpty
              ? Theme.of(context).textTheme.headline5
              : Theme.of(context).textTheme.caption,
          keyboardType: TextInputType.visiblePassword,
          inputFormatters: [
            LengthLimitingTextInputFormatter(200),
            FilteringTextInputFormatter.singleLineFormatter,
            whitespaceFormatter,
          ],
          hintText: pi.apiTokenRequired ? 'API token' : kNoApiTokenNeeded,
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
