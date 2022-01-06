import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/services/api_service.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/views/base_view.dart';
import 'package:flutterhole/views/settings_view.dart';
import 'package:flutterhole/widgets/developer/dev_widget.dart';
import 'package:flutterhole/widgets/layout/animations.dart';
import 'package:flutterhole/widgets/layout/code_card.dart';
import 'package:flutterhole/widgets/layout/grids.dart';
import 'package:flutterhole/widgets/layout/responsiveness.dart';
import 'package:flutterhole/widgets/settings/delete_pihole_button.dart';
import 'package:flutterhole/widgets/settings/extensions.dart';
import 'package:flutterhole/widgets/settings/qr_scan.dart';
import 'package:flutterhole/widgets/settings/single_pi_form.dart';
import 'package:flutterhole/widgets/ui/buttons.dart';
import 'package:flutterhole/widgets/ui/dialogs.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pihole_api/pihole_api.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'dashboard_edit_view.dart';

class SinglePiEditView extends HookConsumerWidget {
  const SinglePiEditView({
    Key? key,
    required this.isNew,
  }) : super(key: key);

  final bool isNew;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final oldPi = ref.watch(piProvider);
    final newPi = useState(oldPi);
    final params = ref.watch(paramsProvider(newPi.value));

    final titleController = useTextEditingController(text: oldPi.title);
    useEffect(() {
      titleController.addListener(() {
        newPi.value = newPi.value.copyWith(title: titleController.text);
      });
    }, [titleController]);

    final baseUrlController = useTextEditingController(text: oldPi.baseUrl);
    useEffect(() {
      baseUrlController.addListener(() {
        newPi.value = newPi.value.copyWith(baseUrl: baseUrlController.text);
      });
    }, [baseUrlController]);

    final apiPathController = useTextEditingController(text: oldPi.apiPath);
    useEffect(() {
      apiPathController.addListener(() {
        newPi.value = newPi.value.copyWith(apiPath: apiPathController.text);
      });
    }, [apiPathController]);

    final apiTokenController = useTextEditingController(text: oldPi.apiToken);
    useEffect(() {
      apiTokenController.addListener(() {
        newPi.value = newPi.value.copyWith(apiToken: apiTokenController.text);
      });
    }, [apiTokenController]);

    return WillPopScope(
      onWillPop: () async {
        if (oldPi == newPi.value || isNew) return true;

        final save = await showSaveChangesDialog(context);

        if (save == true) {
          ref.updatePihole(context, oldPi, newPi.value);
          return true;
        }

        return save == false;
      },
      child: BaseView(
        child: Scaffold(
          appBar: AppBar(
            title: Text(isNew ? 'New Pi-hole' : 'Editing ${oldPi.title}'),
            actions: [
              DevWidget(
                child: IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const SettingsView()));
                    },
                    icon: const Icon(KIcons.settings)),
              ),
              SaveIconButton(
                onPressed: () {
                  if (isNew) {
                    ref
                        .read(UserPreferencesNotifier.provider.notifier)
                        .savePihole(oldValue: oldPi, newValue: newPi.value);
                  } else {
                    ref.updatePihole(context, oldPi, newPi.value);
                  }
                  Navigator.of(context).pop();
                },
              ),
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
                  AppWrap(children: [
                    IconOutlinedButton(
                      iconData: KIcons.dashboard,
                      text: 'Manage dashboard',
                      onPressed: isNew
                          ? null
                          : () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ProviderScope(overrides: [
                                  piProvider.overrideWithValue(oldPi),
                                  activePiholeParamsProvider
                                      .overrideWithProvider(
                                          paramsProvider(oldPi)),
                                ], child: const DashboardEditView()),
                                fullscreenDialog: true,
                              ));
                            },
                    ),
                    UrlOutlinedButton(
                      url: Formatting.piToAdminUrl(newPi.value),
                      text: 'Open in browser',
                    ),
                    DeletePiholeButton(pi: oldPi),
                  ]),
                  const SizedBox(height: 20.0),
                  const Divider(),
                  const GridSectionHeader('Host', KIcons.host),
                  const SizedBox(height: 20.0),
                  _BaseUrlField(baseUrlController),
                  const SizedBox(height: 20.0),
                  _ApiPathField(apiPathController),
                  const SizedBox(height: 20.0),
                  AppWrap(
                    children: [
                      _ApiStatusButton(params: params),
                      UrlOutlinedButton(
                        url: params.apiUrl,
                        text: 'API base',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  const Divider(),
                  const GridSectionHeader(
                      'Authentication', KIcons.authentication),
                  const SizedBox(height: 20.0),
                  _ApiTokenField(apiTokenController),
                  const SizedBox(height: 20.0),
                  AppWrap(
                    children: [
                      _AuthenticationStatusButton(params: params),
                      IconOutlinedButton(
                        iconData: KIcons.qrCode,
                        text: 'Scan QR code',
                        onPressed: () async {
                          final barcode = await showModal<String>(
                            context: context,
                            builder: (context) {
                              return const QrScanDialog();
                            },
                          );

                          if (barcode != null) {
                            newPi.value =
                                newPi.value.copyWith(apiToken: barcode);
                            apiTokenController.text = barcode;
                          }
                        },
                      ),
                      UrlOutlinedButton(
                        url: params.adminUrl +
                            '/scripts/pi-hole/php/api_token.php',
                        text: 'Token page',
                      ),
                      IconOutlinedButton(
                        text: 'Share token',
                        iconData: KIcons.qrShare,
                        onPressed: newPi.value.apiToken.isEmpty
                            ? null
                            : () async {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    final size =
                                        ((MediaQuery.of(context).size.width /
                                                    5) *
                                                3)
                                            .clamp(200.0, 500.0);
                                    return AlertDialog(
                                      // backgroundColor: Colors.white,
                                      // title: Center(child: Text('API token')),
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
                                              data: newPi.value.apiToken,
                                              version: QrVersions.auto,
                                              size: size,
                                            ),
                                            CodeCard(newPi.value.apiToken),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                      ),
                      CheckboxListTile(
                        title: const Text('Allow self-signed certificates'),
                        subtitle: const Text(
                            'Trust all certificates, even when the TLS handshake fails.'),
                        value: newPi.value.allowSelfSignedCertificates,
                        onChanged: (value) {
                          newPi.value = newPi.value.copyWith(
                              allowSelfSignedCertificates: value ?? false);
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('Skip authentication'),
                        subtitle: const Text(
                            'Use the default token. Only useful if your Pi-hole does not have an API token.'),
                        value: !newPi.value.apiTokenRequired,
                        onChanged: (value) {
                          if (value != null) {
                            value = !value;
                          }
                          newPi.value = newPi.value
                              .copyWith(apiTokenRequired: value ?? true);
                        },
                      ),
                      // CodeCard(pi.value.toJson().toString()),
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
                  //           Text('Scan QR code'),
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
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
    final leadingSize = Theme.of(context).textTheme.bodyText2!.fontSize!;

    return OutlinedButton(
      onPressed: status.maybeWhen(
          error: (e, s) => () {
                showModal(
                    context: context,
                    builder: (context) => ErrorDialog(
                          title: 'Pi-hole status',
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
          const Text('API status'),
          const SizedBox(width: 8.0),
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
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.0,
                      ),
                    )),
          ),
        ],
      ),
    );
  }
}

class _AuthenticationStatusButton extends HookConsumerWidget {
  const _AuthenticationStatusButton({
    Key? key,
    required this.params,
  }) : super(key: key);

  final PiholeRepositoryParams params;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(forwardDestinationsProvider(params));
    final leadingSize = Theme.of(context).textTheme.bodyText2!.fontSize!;

    return OutlinedButton(
      onPressed: status.maybeWhen(
          error: (e, s) => () {
                showModal(
                    context: context,
                    builder: (context) => ErrorDialog(
                          title: 'Authentication',
                          error: e,
                          stackTrace: s,
                        ));
              },
          orElse: () => () {
                ref.refresh(forwardDestinationsProvider(params));
              }),
      onLongPress: () {
        ref.refresh(forwardDestinationsProvider(params));
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Auth status'),
          const SizedBox(width: 8.0),
          AnimatedFader(
            child: status.when(
                data: (st) => Icon(
                      KIcons.success,
                      size: leadingSize,
                      color: Colors.green,
                    ),
                error: (e, s) => Icon(
                      KIcons.failure,
                      size: leadingSize,
                      color: Colors.red,
                    ),
                loading: () => SizedBox(
                      width: leadingSize,
                      height: leadingSize,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.0,
                      ),
                    )),
          ),
        ],
      ),
    );
  }
}

class PiTextField extends StatelessWidget {
  const PiTextField({
    Key? key,
    required this.controller,
    required this.style,
    required this.textCapitalization,
    required this.labelText,
    required this.hintText,
    this.labelStyle,
    this.iconData,
    this.keyboardType,
    this.prefixText,
    this.inputFormatters,
    this.obscureText = false,
    this.expands = false,
    this.maxLines,
    this.suffixIcon,
  }) : super(key: key);

  final TextEditingController controller;
  final IconData? iconData;
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
        prefixIcon: iconData == null
            ? null
            : Padding(
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
      labelText: 'Title',
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
      style: GoogleFonts.firaMono(),
      labelStyle: Theme.of(context).textTheme.headline6,
      keyboardType: TextInputType.url,
      textCapitalization: TextCapitalization.none,
      labelText: 'Base URL',
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
      style: GoogleFonts.firaMono(),
      labelStyle: Theme.of(context).textTheme.headline6,
      keyboardType: TextInputType.url,
      textCapitalization: TextCapitalization.none,
      hintText: const Pi().apiPath,
      labelText: 'API path',
      iconData: KIcons.apiPath,
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
        style: GoogleFonts.firaMono(),
        labelStyle: Theme.of(context).textTheme.headline6,
        keyboardType: TextInputType.visiblePassword,
        textCapitalization: TextCapitalization.none,
        hintText: '8f336d...',
        labelText: 'API token',
        iconData: KIcons.apiToken,
        obscureText: !show.value,
        maxLines: 1,
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
