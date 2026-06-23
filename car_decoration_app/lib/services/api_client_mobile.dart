import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

void setHttpClientAdapter(Dio dio) {
  (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) => true;
    return client;
  };
}
