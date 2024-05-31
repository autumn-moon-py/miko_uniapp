import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'page/chat/chat_view_model.dart';

class Global {
  static final getIt = GetIt.instance;
  static late SharedPreferences local;

  //注册 getIt.registerSingleton<T>(T());
  //使用 Global.getIt<T>();
  static Future<void> init() async {
    widgetInit();
    await localInit();
    setupLocator();
  }

  static void setupLocator() {
    getIt.registerLazySingleton(() => ChatViewModel());
  }

  static Future<void> localInit() async {
    local = await SharedPreferences.getInstance();
  }

  static void widgetInit() {
    WidgetsFlutterBinding.ensureInitialized();
    SystemUiOverlayStyle systemUiOverlayStyle =
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}
