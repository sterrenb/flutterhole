import 'package:equatable/equatable.dart';
import 'package:flutterhole/model/serializable.dart';

const String titleKey = 'title';
const String hostKey = 'host';
const String apiPathKey = 'apipath';
const String portKey = 'port';
const String authKey = 'auth';
const String useSSLKey = 'useSSL';
const String allowSelfSignedKey = 'allowSelfSigned';
const String proxyKey = 'proxy_';
const String usernameKey = 'username';
const String passwordKey = 'password';

const String obscured = '<hidden>';

class Proxy extends Equatable {
  final String host;
  final int port;
  final String username;
  final String password;

  /// The string used by Dio when proxy is enabled.
  String get directConnection {
    if (host.isEmpty || port == null) {
      return '';
    } else {
      return '$host:$port';
    }
  }

  String get basicAuth {
    if (username.isEmpty || password.isEmpty) {
      return '';
    } else {
//      return base64Encode(utf8.encode('$username:$password'));
      return '$username:$password';
    }
  }

  Proxy({
    this.host = '',
    this.port = 8080,
    this.username = '',
    this.password = '',
  }) : super([
    host,
    port,
    username,
    password,
  ]);

  factory Proxy.copyWith(Proxy source, {
    String host,
    int port,
    String username,
    String password,
  }) =>
      Proxy(
        host: host ?? source.host,
        port: port ?? source.port,
        username: username ?? source.username,
        password: password ?? source.password,
      );
}

class Pihole extends Serializable {
  final String title;
  final String host;
  final String apiPath;
  final int port;
  final String auth;
  final bool useSSL;
  final bool allowSelfSigned;
  final Proxy proxy;

  String get baseUrl {
    final String scheme = (port == 443 || useSSL) ? 'https' : 'http';
    final String portString = (port == 80 && !useSSL) || (port == 443 && useSSL)
        ? ''
        : ':${port.toString()}';

    final String basicAuthString =
    proxy.basicAuth.isNotEmpty ? '${proxy.basicAuth}@' : '';
    final String hostString =
    proxy.directConnection.isNotEmpty ? '@${proxy.directConnection}' : host;

    if (proxy.basicAuth.isNotEmpty && proxy.directConnection.isNotEmpty) {
      return '$scheme://${proxy.basicAuth}${proxy.directConnection}';
    }

    return '$scheme://$basicAuthString$hostString$portString';
  }

  String get baseUrlObscured {
    if (proxy.basicAuth.isEmpty) return baseUrl;
    return baseUrl.replaceFirst(proxy.basicAuth, obscured);
  }

  Pihole({this.title = 'FlutterHole',
    this.host = 'pi.hole',
    this.apiPath = 'admin/api.php',
    this.port = 80,
    this.auth = '',
    this.useSSL = false,
    this.allowSelfSigned = false,
    Proxy proxy})
      : this.proxy = proxy ?? Proxy(),
        super([
        title,
        host,
        port,
        auth,
        useSSL,
        allowSelfSigned,
        proxy ?? Proxy(),
      ]);

  /// Returns a new Pihole with the given parameters, using the [source] as base.
  factory Pihole.copyWith(Pihole source, {
    String title,
    String host,
    String apiPath,
    int port,
    String auth,
    bool useSSL,
    bool allowSelfSigned,
    Proxy proxy,
  }) =>
      Pihole(
        title: title ?? source.title,
        host: host ?? source.host,
        apiPath: apiPath ?? source.apiPath,
        port: port ?? source.port,
        auth: auth ?? source.auth,
        useSSL: useSSL ?? source.useSSL,
        allowSelfSigned: allowSelfSigned ?? source.allowSelfSigned,
        proxy: proxy ?? source.proxy,
      );

  @override
  Map<String, String> toJson() =>
      {
        titleKey: title,
        hostKey: host,
        apiPathKey: apiPath,
        portKey: port.toString(),
        authKey: auth,
        useSSLKey: useSSL.toString(),
        allowSelfSignedKey: allowSelfSigned.toString(),
        '$proxyKey$hostKey': proxy.host,
        '$proxyKey$portKey': proxy.port.toString(),
        '$proxyKey$usernameKey': proxy.username,
        '$proxyKey$passwordKey': proxy.password,
      };

  Map<String, String> toObscuredJson() {
    Map<String, String> map = toJson();
    map.update(authKey, (str) => str.isEmpty ? '' : obscured);
    map.update('$proxyKey$usernameKey', (str) => str.isEmpty ? '' : obscured);
    map.update('$proxyKey$passwordKey', (str) => str.isEmpty ? '' : obscured);
    return map;
  }
}
