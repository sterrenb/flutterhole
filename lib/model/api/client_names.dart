import 'dart:convert';

import 'package:flutterhole/model/serializable.dart';
import 'package:meta/meta.dart';

class ClientNames extends Serializable {
  ClientNames(this.clients,);

  final List<Client> clients;

  @override
  List<Object> get props => [clients];

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
  Client({
    @required this.name,
    @required this.ip,
  });

  final String name;
  final String ip;

  @override
  List<Object> get props => [name, ip];

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
