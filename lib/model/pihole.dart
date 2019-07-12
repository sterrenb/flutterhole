import 'package:equatable/equatable.dart';

const String titleKey = 'title';
const String hostKey = 'host';
const String apiPathKey = 'apipath';
const String portKey = 'port';
const String authKey = 'auth';

class Pihole extends Equatable {
  String title;
  String host;
  String apiPath;
  int port;
  String auth;

  String get localKey => title.toLowerCase().replaceAll(' ', '_');

  static String toKey(String str) => str.toLowerCase().replaceAll(' ', '_');

  Pihole(
      {this.title = 'FlutterHole',
      this.host = 'pi.hole',
      this.apiPath = 'admin/api.php',
      this.port = 80,
      this.auth =
          '3f4fa74468f336df5c4cf1d343d160f8948375732f82ea1a057138ae7d35055c'})
      : super([title, host, port, auth]);

  /// Returns a new Pihole with the given parameters, using the [source] as base.
  Pihole.copyWith(Pihole source,
      {String title, String host, String apiPath, int port, String auth}) {
    this.title = title ?? source.title;
    this.host = host ?? source.host;
    this.apiPath = apiPath ?? source.apiPath;
    this.port = port ?? source.port;
    this.auth = auth ?? source.auth;
  }

  Map<String, dynamic> toJson() => {
        titleKey: title,
        hostKey: host,
        apiPathKey: apiPath,
        portKey: port,
        authKey: auth,
      };
}
