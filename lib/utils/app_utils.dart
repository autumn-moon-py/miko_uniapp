import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class Utils {
  ///读取剧本
  static Future<List> loadCVS(String chapter) async {
    //报错检查csv编码是否为utf-8
    try {
      final rawData = await rootBundle.loadString(
        "assets/story/$chapter.csv",
      );
      final result = const CsvToListConverter().convert(rawData, eol: '\r\n');
      return result;
    } catch (e) {
      return [];
    }
  }

  ///访问网站
  static Future<void> openWebSite(String url) async {
    await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalNonBrowserApplication);
  }
}
