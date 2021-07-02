import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:url_launcher/url_launcher.dart';

final _dio = Dio(BaseOptions(headers: {
  HttpHeaders.userAgentHeader: 'flutterhole',
}));

Future<String> fetchPrivacyMarkdown() async {
  try {
    final Response response = await _dio.get(KUrls.privacyRawUrl);
    return response.data.toString();
  } catch (e) {
    return 'Failed to get privacy information: \n\n$e';
  }
}

Future<bool> launchUrl(String url) async {
  if (await canLaunch(url)) {
    return await launch(url);
  } else {
    log('Cannot launch $url');
    return false;
  }
}
