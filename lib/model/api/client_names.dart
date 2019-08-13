import 'dart:convert';

import 'package:flutterhole/model/serializable.dart';
import 'package:meta/meta.dart';

class ClientNames extends Serializable {
  final List<Client> clients;

  ClientNames(
    this.clients,
  ) : super([clients]);

  factory ClientNames.fromString(String str) =>
      ClientNames.fromJson(json.decode(str));

  factory ClientNames.fromJson(Map<String, dynamic> json) => ClientNames(
        List<Client>.from(json["clients"].map((x) => Client.fromJson(x))),
      );

  @override
  Map<String, dynamic> toJson() => {
        "clients": List<dynamic>.from(clients.map((x) => x.toJson())),
      };
}

class Client extends Serializable {
  final String name;
  final String ip;

  Client({
    @required this.name,
    @required this.ip,
  }) : super([name, ip]);

  factory Client.fromJson(Map<String, dynamic> json) => Client(
        name: json["name"],
        ip: json["ip"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "name": name,
        "ip": ip,
      };
}
