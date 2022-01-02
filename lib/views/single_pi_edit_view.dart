import 'package:animations/animations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/services/api_service.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/services/web_service.dart';
import 'package:flutterhole/views/settings_view.dart';
import 'package:flutterhole/widgets/layout/animations.dart';
import 'package:flutterhole/widgets/layout/code_card.dart';
import 'package:flutterhole/widgets/layout/dialogs.dart';
import 'package:flutterhole/widgets/layout/responsiveness.dart';
import 'package:flutterhole/widgets/settings/qr_scan.dart';
import 'package:flutterhole/widgets/settings/single_pi_form.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pihole_api/pihole_api.dart';
import 'package:qr_flutter/qr_flutter.dart';

final _paramsProvider = Provider.family<PiholeRepositoryParams, Pi>((ref, pi) {
  return PiholeRepositoryParams(
    dio: Dio(BaseOptions(baseUrl: pi.baseUrl)),
    baseUrl: pi.baseUrl,
    apiPath: pi.apiPath,
    apiPort: pi.apiPort,
    apiTokenRequired: pi.apiTokenRequired,
    apiToken: pi.apiToken,
    allowSelfSignedCertificates: pi.allowSelfSignedCertificates,
    adminHome: pi.adminHome,
  );
});

class SinglePiEditView extends HookConsumerWidget {
  const SinglePiEditView({
    required this.initialValue,
    Key? key,
  }) : super(key: key);

  final Pi initialValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pi = useState(initialValue);
    final params = ref.watch(_paramsProvider(pi.value));

    final titleController = useTextEditingController(text: initialValue.title);
    final baseUrlController =
        useTextEditingController(text: initialValue.baseUrl);
    useEffect(() {
      baseUrlController.addListener(() {
        pi.value = pi.value.copyWith(baseUrl: baseUrlController.text);
      });
    }, [baseUrlController]);

    final apiPathController =
        useTextEditingController(text: initialValue.apiPath);
    useEffect(() {
      apiPathController.addListener(() {
        pi.value = pi.value.copyWith(apiPath: apiPathController.text);
      });
    }, [apiPathController]);

    final apiTokenController =
        useTextEditingController(text: initialValue.apiToken);
    useEffect(() {
      apiTokenController.addListener(() {
        pi.value = pi.value.copyWith(apiToken: apiTokenController.text);
      });
    }, [apiTokenController]);

    return Scaffold(
      appBar: AppBar(
        title: Text("Editing ${initialValue.title}"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsView()));
              },
              icon: const Icon(KIcons.settings)),
          IconButton(
              tooltip: "Save",
              onPressed: () {
                final pi = ref.read(activePiProvider);
                debugPrint(pi.toJson().toString());
              },
              icon: const Icon(KIcons.save)),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: MobileMaxWidth(
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              _PiTitleField(titleController),
              const SizedBox(height: 20.0),
              const Divider(),
              const GridSectionHeader("Host", KIcons.host),
              const SizedBox(height: 20.0),
              _BaseUrlField(baseUrlController),
              const SizedBox(height: 20.0),
              _ApiPathField(apiPathController),
              const SizedBox(height: 20.0),
              Wrap(
                // alignment: WrapAlignment.center,
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  _ApiStatusButton(params: params),
                  UrlOutlinedButton(
                    url: Formatting.piToAdminUrl(pi.value),
                    text: "Admin page",
                  ),
                  UrlOutlinedButton(
                    url: Formatting.piToApiUrl(pi.value),
                    text: "API base",
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              const Divider(),
              const GridSectionHeader('Authentication', KIcons.authentication),
              const SizedBox(height: 20.0),
              _ApiTokenField(apiTokenController),
              const SizedBox(height: 20.0),
              Wrap(
                // alignment: WrapAlignment.spaceEvenly,
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      final barcode = await showModal<String>(
                        context: context,
                        builder: (context) {
                          return const QrScanDialog();
                        },
                      );

                      if (barcode != null) {
                        pi.value = pi.value.copyWith(apiToken: barcode);
                        apiTokenController.text = barcode;
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(KIcons.qrCode),
                        SizedBox(width: 8.0),
                        Text("Scan QR code"),
                      ],
                    ),
                  ),
                  UrlOutlinedButton(
                    url: params.adminUrl + "/scripts/pi-hole/php/api_token.php",
                    text: "Token page",
                  ),
                  OutlinedButton(
                    onPressed: pi.value.apiToken.isEmpty
                        ? null
                        : () async {
                            showDialog(
                              context: context,
                              builder: (context) {
                                final size =
                                    ((MediaQuery.of(context).size.width / 5) *
                                            3)
                                        .clamp(200.0, 500.0);
                                return AlertDialog(
                                  // backgroundColor: Colors.white,
                                  // title: Center(child: Text("API token")),
                                  // titlePadding: EdgeInsets.all(16.0),
                                  titleTextStyle:
                                      Theme.of(context).textTheme.headline4,
                                  contentPadding: EdgeInsets.zero,
                                  content: Container(
                                    width: size,
                                    color: Colors.white,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        QrImage(
                                          // backgroundColor: Colors.white,
                                          data: pi.value.apiToken,
                                          version: QrVersions.auto,
                                          size: size,
                                        ),
                                        CodeCard(pi.value.apiToken),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(KIcons.qrShare),
                        SizedBox(width: 8.0),
                        Text("Share token"),
                      ],
                    ),
                  ),
                  CheckboxListTile(
                    title: const Text("Allow self-signed certificates"),
                    subtitle: const Text(
                        "Trust all certificates, even when the TLS handshake fails."),
                    value: pi.value.allowSelfSignedCertificates,
                    onChanged: (value) {
                      pi.value = pi.value.copyWith(
                          allowSelfSignedCertificates: value ?? false);
                    },
                  ),
                  CheckboxListTile(
                    title: const Text("Skip authentication"),
                    subtitle: const Text(
                        "Use the default token. Only useful if your Pi-hole does not have an API token."),
                    value: !pi.value.apiTokenRequired,
                    onChanged: (value) {
                      if (value != null) {
                        value = !value;
                      }
                      pi.value =
                          pi.value.copyWith(apiTokenRequired: value ?? true);
                    },
                  ),
                  CodeCard(pi.value.toJson().toString()),
                ],
              ),
              // Row(
              //   children: [
              //     Expanded(child: _ApiTokenField(apiTokenController)),
              //     const SizedBox(width: 8.0),
              //     OutlinedButton(
              //       onPressed: () {},
              //       child: Row(
              //         children: const [
              //           Icon(KIcons.qrCode),
              //           SizedBox(width: 8.0),
              //           Text("Scan QR code"),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApiStatusButton extends HookConsumerWidget {
  const _ApiStatusButton({
    Key? key,
    required this.params,
  }) : super(key: key);

  final PiholeRepositoryParams params;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(pingProvider(params));
    final count = useState(0);
    final leadingSize = Theme.of(context).textTheme.bodyText2!.fontSize!;

    return OutlinedButton(
      onPressed: status.maybeWhen(
          error: (e, s) => () {
                showModal(
                    context: context,
                    builder: (context) => ErrorDialog(
                          title: "Pi-hole status",
                          error: e,
                          stackTrace: s,
                        ));
              },
          orElse: () => () {
                ref.refresh(pingProvider(params));
              }),
      onLongPress: () {
        ref.refresh(pingProvider(params));
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedFader(
            child: status.when(
                data: (st) => Icon(
                      KIcons.success,
                      size: leadingSize,
                      color: Colors.green,
                    ),
                error: (e, s) => Icon(
                      KIcons.error,
                      size: leadingSize,
                      color: Colors.red,
                    ),
                loading: () => SizedBox(
                      width: leadingSize,
                      height: leadingSize,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                      ),
                    )),
          ),
          const SizedBox(width: 8.0),
          const Text("API status"),
        ],
      ),
    );
  }
}

class UrlOutlinedButton extends StatelessWidget {
  const UrlOutlinedButton({Key? key, required this.url, this.text})
      : super(key: key);

  final String url;
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: url,
      child: OutlinedButton(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              KIcons.openUrl,
              size: Theme.of(context).textTheme.bodyText2!.fontSize!,
            ),
            const SizedBox(width: 8.0),
            Text(text ?? url),
          ],
        ),
        onPressed: () {
          WebService.launchUrlInBrowser(url);
        },
      ),
    );
  }
}

class PiTextField extends StatelessWidget {
  const PiTextField({
    Key? key,
    required this.controller,
    required this.iconData,
    required this.style,
    required this.textCapitalization,
    required this.labelText,
    this.labelStyle,
    required this.hintText,
    this.keyboardType,
    this.prefixText,
    this.inputFormatters,
    this.obscureText = false,
    this.expands = false,
    this.maxLines,
    this.suffixIcon,
  }) : super(key: key);

  final TextEditingController controller;
  final IconData iconData;
  final TextStyle style;
  final String labelText;
  final TextStyle? labelStyle;
  final String hintText;
  final TextCapitalization textCapitalization;
  final TextInputType? keyboardType;
  final String? prefixText;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool expands;
  final int? maxLines;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: style,
      textCapitalization: textCapitalization,
      textAlignVertical: TextAlignVertical.center,
      expands: expands,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(
            top: style.fontSize ?? 8.0,
            left: style.fontSize ?? 8.0 + 8.0,
            right: style.fontSize ?? 8.0,
            bottom: style.fontSize ?? 8.0,
          ),
          child: Icon(iconData),
        ),
        labelText: labelText,
        labelStyle: labelStyle,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: hintText,
        prefixText: prefixText,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class _PiTitleField extends StatelessWidget {
  const _PiTitleField(
    this.controller, {
    Key? key,
  }) : super(key: key);

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return PiTextField(
      controller: controller,
      iconData: KIcons.piholeTitle,
      style: Theme.of(context).textTheme.headline6!,
      labelStyle: Theme.of(context).textTheme.headline6,
      textCapitalization: TextCapitalization.sentences,
      labelText: "Title",
      hintText: const Pi().title,
    );
  }
}

class _BaseUrlField extends StatelessWidget {
  const _BaseUrlField(
    this.controller, {
    Key? key,
  }) : super(key: key);

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return PiTextField(
      controller: controller,
      iconData: KIcons.totalQueries,
      style:
          // Theme.of(context).textTheme.headline6!.merge(GoogleFonts.firaMono()),
          GoogleFonts.firaMono(),
      labelStyle: Theme.of(context).textTheme.headline6,
      keyboardType: TextInputType.url,
      textCapitalization: TextCapitalization.none,
      labelText: "Base URL",
      hintText: const Pi().baseUrl,
      inputFormatters: [Formatting.whitespaceFormatter],
    );
  }
}

class _ApiPathField extends StatelessWidget {
  const _ApiPathField(
    this.controller, {
    Key? key,
  }) : super(key: key);

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return PiTextField(
      controller: controller,
      style:
          // Theme.of(context).textTheme.headline6!.merge(GoogleFonts.firaMono()),
          GoogleFonts.firaMono(),
      labelStyle: Theme.of(context).textTheme.headline6,
      keyboardType: TextInputType.url,
      textCapitalization: TextCapitalization.none,
      hintText: const Pi().apiPath,
      labelText: 'API path',
      iconData: KIcons.apiPath,
      prefixText: '/',
      inputFormatters: [Formatting.whitespaceFormatter],
    );
  }
}

class _ApiTokenField extends HookConsumerWidget {
  const _ApiTokenField(
    this.controller, {
    Key? key,
  }) : super(key: key);

  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final show = useState(false);
    return PiTextField(
        controller: controller,
        style:
            // Theme.of(context).textTheme.headline6!.merge(GoogleFonts.firaMono()),
            GoogleFonts.firaMono(),
        labelStyle: Theme.of(context).textTheme.headline6,
        keyboardType: TextInputType.visiblePassword,
        textCapitalization: TextCapitalization.none,
        hintText: "8f336d...",
        labelText: 'API token',
        iconData: KIcons.apiToken,
        obscureText: !show.value,
        maxLines: 1,
        // expands: show.value,
        // obscureText: false,
        // expands: true,
        // maxLines: 2,
        inputFormatters: [Formatting.whitespaceFormatter],
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            tooltip: (!show.value ? 'Enable' : 'Disable') + ' visibility',
            onPressed: () {
              show.value = !show.value;
            },
            icon: Icon(
                show.value ? KIcons.toggleVisible : KIcons.toggleInvisible),
          ),
        ));
  }
}
