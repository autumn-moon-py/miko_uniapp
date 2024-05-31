import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miko/theme/color.dart';
import 'package:miko/widget.dart';
import 'package:provider/provider.dart';
import 'chat_view_model.dart';
import 'controller.dart';
import 'widget.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Widget title() {
    return Builder(builder: (context) {
      final name = context.select((ChatViewModel model) => model.name);

      return Text(name, style: MyTheme.bigStyle);
    });
  }

  Widget body() {
    return Consumer<ChatViewModel>(builder: (context, model, child) {
      final messages = model.messages;

      return ChatList(
          controller: model.chatController,
          toBottom: model.toBottom,
          messages: messages,
          handleShowAD: (key) async {
            if (key == '下线') {
              EasyLoading.showToast('弹出广告');
              model.changeStartTime(0);
              await storyPlayer();
            }
            if (key == '坏结局') {
              EasyLoading.showToast('弹出广告');
              model.changeBE(false);
              await storyPlayer();
            }
          });
    });
  }

  Widget chooseButton() {
    return Builder(builder: (context) {
      bool isTap = false;
      final showChoose =
          context.select((ChatViewModel model) => model.showChoose);

      if (!showChoose) return const SizedBox();

      final model = context.read<ChatViewModel>();
      final leftChoose = model.leftChoose;
      final rightChoose = model.rightChoose;
      final leftJump = model.leftJump;
      final rightJump = model.rightJump;

      model.toBottom();

      return Align(
          alignment: Alignment.bottomCenter,
          child: ChooseButton(
              showChoose: showChoose,
              chooses: [leftChoose, rightChoose],
              jumps: [leftJump, rightJump],
              onTap: (text, jump) async {
                if (isTap) {
                  isTap = false;
                  model.changeShowChoose(false);
                  return;
                }
                isTap = true;
                model.changeShowChoose(false);
                sendRight(model, text);
                model.changeJump(jump);
                await Future.delayed(const Duration(milliseconds: 10));
                isTap = false;
                await storyPlayer();
              }));
    });
  }

  Widget _bg() {
    return Blur(
        blurColor: Colors.transparent,
        blur: 1.5,
        colorOpacity: 0.2,
        child: Image.asset('assets/images/聊天背景.webp',
            width: 1.sw, height: 1.sh, fit: BoxFit.cover));
  }

  Widget setButton() {
    return IconButton(
        onPressed: () {
          EasyLoading.showToast('设置');
        },
        icon: Icon(Icons.settings,
            color: Colors.white, size: MyTheme.narmalIconSize));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Stack(children: [
      _bg(),
      Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: MyTheme.foreground,
            centerTitle: true,
            elevation: 0,
            toolbarHeight: 40,
            title: title(),
            actions: [sb(10.w), setButton(), sb(10.w)],
          ),
          body: Stack(children: [
            SizedBox(
                height: 1.sh,
                child: Column(
                    children: [Expanded(child: body()), chooseButton()])),
          ])),
      Builder(builder: (context) {
        final name = context.select((ChatViewModel model) => model.name);
        if (name.isEmpty) return bg(true);
        return sb();
      })
    ]);
  }
}
