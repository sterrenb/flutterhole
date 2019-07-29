import 'package:equatable/equatable.dart';

const String titleKey = 'title';
const String hostKey = 'host';
const String apiPathKey = 'apipath';
const String portKey = 'port';
const String authKey = 'auth';
const String allowSelfSignedKey = 'allowselfsigned';

class Pihole extends Equatable {
  final String title;
  final String host;
  final String apiPath;
  final int port;
  final String auth;
  final bool allowSelfSigned;

  String get localKey => Pihole.toKey(this.title);

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
  factory Pihole.copyWith(Pihole source,
      {String title,
        String host,
        String apiPath,
        int port,
        String auth,
        bool allowSelfSigned}) =>
      Pihole(
        title: title ?? source.title,
        host: host ?? source.host,
        apiPath: apiPath ?? source.apiPath,
        port: port ?? source.port,
        auth: auth ?? source.auth,
        allowSelfSigned: allowSelfSigned ?? source.allowSelfSigned,
      );

  Map<String, dynamic> toJson() => {
        titleKey: title,
        hostKey: host,
        apiPathKey: apiPath,
        portKey: port,
        authKey: auth,
    allowSelfSignedKey: allowSelfSigned,
      };
}
