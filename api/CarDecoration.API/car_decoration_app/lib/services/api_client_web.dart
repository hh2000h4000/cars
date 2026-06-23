import 'package:dio/dio.dart';

void setHttpClientAdapter(Dio dio) {
  // على الويب لا يوجد IOHttpClientAdapter — المتصفح يتعامل مع الشهادة مباشرة
}
