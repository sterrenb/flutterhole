import 'package:equatable/equatable.dart';

const String titleKey = 'title';
const String hostKey = 'host';
const String apiPathKey = 'apipath';
const String portKey = 'port';
const String authKey = 'auth';
const String allowSelfSignedKey = 'allowselfsigned';

class Pihole extends Equatable {
  String title;
  String host;
  String apiPath;
  int port;
  String auth;
  bool allowSelfSigned;

  String get localKey => title.toLowerCase().replaceAll(' ', '_');

  String get baseUrl => '$host${port == 80 ? '' : ':${port.toString()}'}';

  String get basePath => '$baseUrl/$apiPath';

  static String toKey(String str) => str.toLowerCase().replaceAll(' ', '_');

  Pihole(
      {this.title = 'FlutterHole',
      this.host = 'pi.hole',
      this.apiPath = 'admin/api.php',
      this.port = 80,
        this.auth = '',
        this.allowSelfSigned = false})
      : super([title, host, port, auth, allowSelfSigned]);

  /// Returns a new Pihole with the given parameters, using the [source] as base.
  Pihole.copyWith(Pihole source,
      {String title,
        String host,
        String apiPath,
        int port,
        String auth,
        bool allowSelfSigned}) {
    this.title = title ?? source.title;
    this.host = host ?? source.host;
    this.apiPath = apiPath ?? source.apiPath;
    this.port = port ?? source.port;
    this.auth = auth ?? source.auth;
    this.allowSelfSigned = allowSelfSigned ?? source.allowSelfSigned;
  }

  Map<String, dynamic> toJson() => {
        titleKey: title,
        hostKey: host,
        apiPathKey: apiPath,
        portKey: port,
        authKey: auth,
    allowSelfSignedKey: allowSelfSigned,
      };
}
