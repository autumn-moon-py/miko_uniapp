import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'theme/color.dart';

Widget sb([double? width, double? height]) =>
    SizedBox(width: width, height: height);

Widget buildDefaultItem(
    {required IconData leading,
    required String title,
    String? subTitle,
    Widget? button,
    Function? onTap}) {
  return GestureDetector(
      onTap: () => onTap?.call(),
      child: ListTile(
          leading:
              Icon(leading, color: Colors.grey, size: MyTheme.narmalIconSize),
          title: Text(title, style: MyTheme.bigStyle),
          subtitle: subTitle == null
              ? null
              : Text(subTitle,
                  style: MyTheme.narmalStyle.copyWith(fontSize: 12)),
          trailing: button ??
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.grey, size: 20)));
}

Widget bg([bool showLoading = false]) {
  return Stack(children: [
    Container(color: MyTheme.background),
    showLoading
        ? Center(
            child: SizedBox(
                width: 100.w,
                child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white))))
        : sb()
  ]);
}
