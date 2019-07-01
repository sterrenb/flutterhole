import 'package:equatable/equatable.dart';

const String titleKey = 'title';
const String hostKey = 'host';
const String portKey = 'port';
const String authKey = 'auth';

class Pihole extends Equatable {
  final String title;
  final String host;
  final int port;
  final String auth;

  String get key => title.toLowerCase().replaceAll(' ', '_');

  Pihole(
      {this.title = 'FlutterHole',
      this.host = 'pi.hole',
      this.port = 80,
      this.auth =
          '3f4fa74468f336df5c4cf1d343d160f8948375732f82ea1a057138ae7d35055c'})
      : super([title, host, port, auth]);

  Map<String, dynamic> toJson() => {
        titleKey: title,
        hostKey: host,
        portKey: port,
        authKey: auth,
      };
}
