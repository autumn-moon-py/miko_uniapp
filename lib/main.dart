import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:miko/page/chat/chat_page.dart';
import 'package:provider/provider.dart';

import 'global.dart';
import 'page/chat/chat_view_model.dart';

Future<void> main() async {
  await Global.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<ChatViewModel>(
              create: (_) => Global.getIt<ChatViewModel>()),
        ],
        child: ScreenUtilInit(
            designSize: const Size(1080, 1920),
            builder: (context, _) {
              return GetMaterialApp(
                title: '异次元通讯',
                theme: ThemeData(useMaterial3: false),
                debugShowCheckedModeBanner: false,
                builder: EasyLoading.init(),
                home: const ChatPage(),
              );
            }));
  }
}
