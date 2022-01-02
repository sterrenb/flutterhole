import 'package:animations/animations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
import 'package:flutterhole/widgets/settings/single_pi_form.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pihole_api/pihole_api.dart';

final _paramsProvider = Provider.family<PiholeRepositoryParams, Pi>((ref, pi) {
  print("Returning params for ${pi.baseUrl + "/" + pi.apiPath}");

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
      body: MobileMaxWidth(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            _PiTitleField(titleController),
            const SizedBox(height: 20.0),
            const GridSectionHeader('Host details', KIcons.host),
            const SizedBox(height: 20.0),
            _BaseUrlField(baseUrlController),
            const SizedBox(height: 20.0),
            _ApiPathField(apiPathController),
            const SizedBox(height: 20.0),
            Wrap(
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
            // CodeCard(pi.value.toString()),
          ],
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
                      child: const CircularProgressIndicator(
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
        child: Text(text ?? url),
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

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: style,
      textCapitalization: textCapitalization,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.all(style.fontSize ?? 8.0),
          child: Icon(iconData),
        ),
        labelText: labelText,
        labelStyle: labelStyle,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: hintText,
        prefixText: prefixText,
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
    );
  }
}
