import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:miko/model/story.dart';
import 'package:miko/page/chat/chat_view_model.dart';
import 'package:miko/model/message.dart';
import 'package:provider/provider.dart';

bool waitTyping = true;

///发送间隔
Future<void> sendInterval(int length) async {
  int wait = length * 100 + 500;
  await Future.delayed(Duration(milliseconds: !waitTyping ? 100 : wait));
}

Future<void> sendLeft(ChatViewModel chatModel, String name, String msg) async {
  if (name != '') chatModel.changeName(name);
  Message message = Message(
    msg,
    MessageType.left,
    name: name,
  );
  chatModel.addItem(message);
  await sendInterval(msg.length);
  await chatModel.toBottom();
}

Future<void> sendMiddle(ChatViewModel chatModel, String msg) async {
  Message message = Message(msg, MessageType.middle);
  chatModel.addItem(message);
  await sendInterval(2);
  await chatModel.toBottom();
}

Future<void> sendRight(ChatViewModel chatModel, String msg) async {
  Message message = Message(msg, MessageType.right);
  chatModel.addItem(message);
  await sendInterval(msg.length);
  await chatModel.toBottom();
}

Future<void> sendImage(ChatViewModel chatModel, String msg) async {
  Message message = Message('', MessageType.image, image: msg);
  chatModel.addItem(message);
  await sendInterval(2);
  await chatModel.toBottom();
}

// 进入下线等待
Future<void> waitStart(ChatViewModel chatModel) async {
  final now = DateTime.now().millisecondsSinceEpoch;
  // if(kDebugMode) await chatModel.changeStartTime(0);
  if (now >= chatModel.startTime) {
    await chatModel.changeStartTime(0);
  }
  if (now < chatModel.startTime) {
    int newTime = chatModel.startTime - now;
    await Future.delayed(Duration(milliseconds: newTime));
  }
}

// 进入BE
Future<void> enterBe(ChatViewModel chatModel, Story lineInfo) async {
  final msg = lineInfo.msg;
  await sendMiddle(chatModel, msg);
  await chatModel.enterBe();
}

Future<void> debugPlayer(ChatViewModel chatModel) async {
  final choose1 = chatModel.leftChoose;
  final jump1 = chatModel.leftJump;
  final choose2 = chatModel.rightChoose;
  final jump2 = chatModel.rightJump;
  late int jump;
  late String text;
  int random = math.Random().nextInt(10);
  if (random % 2 == 0) {
    jump = jump1;
    text = choose1;
  } else {
    jump = jump2;
    text = choose2;
  }
  await chatModel.changeShowChoose(false);
  await sendRight(chatModel, text);
  await chatModel.changeJump(jump);
}

///播放器
Future<void> storyPlayer() async {
  final chatModel = Get.context!.read<ChatViewModel>();

  do {
    if (chatModel.story.isEmpty) break;
    if (chatModel.be) break;

    if (chatModel.leftChoose.isNotEmpty && chatModel.rightChoose.isNotEmpty) {
      debugPrint('有选项');
      // await debugPlayer(chatModel);
      break;
    }
    if (chatModel.startTime > 0) {
      debugPrint('已下线');
      await waitStart(chatModel);
      continue;
    }
    if (chatModel.line < 0 || chatModel.line >= chatModel.story.length) {
      EasyLoading.showError('异常索引:章节${chatModel.chapter},索引${chatModel.line}');
      break;
    }
    final lineInfo = chatModel.story[chatModel.line];
    if (chatModel.line >= chatModel.story.length - 1) {
      debugPrint('进入结尾');
      await chatModel.nextChapter();
      break;
    } else {
      await chatModel.changeLine(chatModel.line + 1);
    }

    if (kDebugMode) lineInfo.log();

    final type = lineInfo.type;
    switch (type) {
      case StoryType.leftT:
        final jump = chatModel.jump;
        if (jump != 0) continue;
        final name = lineInfo.name;
        final msg = lineInfo.msg;
        await sendLeft(chatModel, name, msg);
        break;
      case StoryType.leftJump:
        final jump = chatModel.jump;
        if (jump != 0) continue;
        final name = lineInfo.name;
        final msg = lineInfo.msg;
        await sendLeft(chatModel, name, msg);
        await chatModel.changeJump(lineInfo.jump);
        break;
      case StoryType.leftBejump:
        final beJump = lineInfo.beJump;
        final jump = chatModel.jump;
        if (beJump != jump) continue;
        await chatModel.changeJump(0);
        final name = lineInfo.name;
        final msg = lineInfo.msg;
        await sendLeft(chatModel, name, msg);
        break;
      case StoryType.leftJumpAndBejump:
        final beJump = lineInfo.beJump;
        final jump = chatModel.jump;
        if (beJump != jump) continue;
        await chatModel.changeJump(lineInfo.jump);
        final name = lineInfo.name;
        final msg = lineInfo.msg;
        await sendLeft(chatModel, name, msg);
        break;
      case StoryType.middleBejump:
        final beJump = lineInfo.beJump;
        final jump = chatModel.jump;
        if (beJump != jump) continue;
        await chatModel.changeJump(0);
        final msg = lineInfo.msg;
        await sendMiddle(chatModel, msg);
        break;
      case StoryType.middleJumpAndBejump:
        final beJump = lineInfo.beJump;
        final jump = chatModel.jump;
        if (beJump != jump) continue;
        await chatModel.changeJump(lineInfo.jump);
        final msg = lineInfo.msg;
        await sendMiddle(chatModel, msg);
        break;
      case StoryType.middelT:
        final jump = chatModel.jump;
        if (jump != 0) continue;
        final msg = lineInfo.msg;
        await sendMiddle(chatModel, msg);
        break;
      case StoryType.rigthT:
        final jump = chatModel.jump;
        if (jump != 0) continue;
        final msg = lineInfo.msg;
        await sendRight(chatModel, msg);
        break;
      case StoryType.rightJump:
        final jump = chatModel.jump;
        if (jump != 0) continue;
        final msg = lineInfo.msg;
        await chatModel.changeJump(lineInfo.jump);
        await sendRight(chatModel, msg);
        break;
      case StoryType.choose:
        final leftChoose = chatModel.leftChoose;
        final rightChoose = chatModel.rightChoose;
        final choose = lineInfo.choose;
        final jump = chatModel.jump;
        if (jump != 0) continue;
        final newJump = lineInfo.jump;
        if (leftChoose.isEmpty) {
          chatModel.changeLeftChoose(choose);
          chatModel.changeLeftJump(newJump);
          continue;
        } else if (rightChoose.isEmpty) {
          chatModel.changeRightChoose(choose);
          chatModel.changeRightJump(newJump);
          continue;
        }
        break;
      case StoryType.day:
        await chatModel.changeDay(lineInfo.day);
        break;
      case StoryType.trend:
        final jump = chatModel.jump;
        if (jump != 0) continue;
        final name = chatModel.name;
        final image = lineInfo.image;
        final msg = lineInfo.msg;
        await sendLeft(chatModel, name, msg);
        sendImage(chatModel, image);
        break;
      case StoryType.image:
        final jump = chatModel.jump;
        if (jump != 0) continue;
        final image = lineInfo.image;
        await sendImage(chatModel, image);
        break;
      case StoryType.wait:
        final jump = chatModel.jump;
        if (jump != 0) continue;
        final wait = DateTime.now().millisecondsSinceEpoch +
            Duration(minutes: lineInfo.wait).inMilliseconds;
        await chatModel.changeStartTime(wait);
        final msg = lineInfo.msg;
        await sendMiddle(chatModel, msg);
        continue;
      case StoryType.waitJump:
        final jump = chatModel.jump;
        if (jump != 0) continue;
        await chatModel.changeJump(lineInfo.jump);
        final wait = DateTime.now().millisecondsSinceEpoch +
            Duration(minutes: lineInfo.wait).inMilliseconds;
        chatModel.changeStartTime(wait);
        continue;
      case StoryType.be:
        final jump = chatModel.jump;
        if (jump != 0) continue;
        await enterBe(chatModel, lineInfo);
      case StoryType.none:
        continue;
    }
  } while (chatModel.line < chatModel.story.length);
}
