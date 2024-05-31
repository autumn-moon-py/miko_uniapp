import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:miko/model/story.dart';
import 'package:miko/page/chat/controller.dart';

import '../../model/message.dart';
import '../../model/user.dart';
import '../../utils/app_utils.dart';

class ChatViewModel with ChangeNotifier {
  List<String> chapters = ['第一章', '第二章', '第三章', '第四章', '第五章', '第六章'];
  List<Message> messages = [];
  List<Story> story = [];
  bool showChoose = false;
  List<String> chooses = [];
  List<int> jumps = [];
  int beJump = 0;
  final user = User();
  final chatController = ScrollController();
  String name = '';
  bool be = false;

  ChatViewModel() {
    init();
  }

  void test() {
    if (!kDebugMode) return;
    // changeJump(24);
  }

  Future<void> init() async {
    await user.load();
    await changeStory();
    test();
    messages.addAll(user.oldMessages);
    notifyListeners();
    await storyPlayer();
  }

  void changeBE(bool value) {
    be = value;
  }

  void changeName(String value) {
    if (name != value) {
      name = value;
      notifyListeners();
    }
  }

  Future<void> nextChapter() async {
    final oldIndex = chapters.indexOf(chapter);
    if (oldIndex == chapters.length) return;
    if (oldIndex + 1 > chapters.length) return;
    final newChapter = chapters[oldIndex + 1];
    debugPrint('切换章节: $newChapter');
    EasyLoading.showToast('切换章节:$chapter');
    await changeChapter(newChapter);
    await storyPlayer();
  }

  Future<void> changeChapter(String chapter) async {
    beJump = 0;
    messages.clear();
    user.playLine = 0;
    user.chapter = chapter;
    user.day = 1;
    await user.save();
    await changeStory();
  }

  String get chapter => user.chapter;

  void changeLeftJump(int jump) {
    if (jumps.isEmpty) {
      jumps.add(jump);
    } else {
      jumps[0] = jump;
    }
  }

  int get leftJump {
    if (jumps.isNotEmpty) return jumps[0];
    return 0;
  }

  void changeRightJump(int jump) {
    if (jumps.length == 1) {
      jumps.add(jump);
    } else {
      jumps[1] = jump;
    }
    changeShowChoose(true);
  }

  int get rightJump {
    if (jumps.length == 2) return jumps[1];
    return 0;
  }

  Future<void> enterBe() async {
    final index = story.indexWhere((element) => element.day == user.day);
    if (index == -1) return;
    await changeLine(index);
  }

  Future<void> changeDay(int day) async {
    user.day = day;
    await user.save();
  }

  int get resetLine => user.day;

  Future<void> changeJump(int jump) async {
    user.jump = jump;
    await user.save();
    if (jump == 0) return;
    int index = story.indexWhere((element) => element.beJump == jump);
    if (index <= 0) {
      EasyLoading.showError('异常跳转:章节:$chapter,jump:$jump');
      return;
    }
    changeLine(index);
  }

  int get jump => user.jump;

  void changeBeJump(int value) => beJump = value;

  Future<void> changeLine(int line) async {
    user.playLine = line;
    await user.save();
  }

  int get line => user.playLine;

  Future<void> changeStory() async {
    story.clear();
    List<List> story0 = await Utils.loadCVS(chapter) as List<List>;
    if (story0.isEmpty) {
      EasyLoading.showError("剧本加载失败:$chapter");
      return;
    }
    List<Story> story1 = [];
    int index = 0;
    for (var sl in story0) {
      final ss = Story.fromList(index, sl);
      index++;
      if (ss.type != StoryType.none) story1.add(ss);
    }
    story.addAll(story1);
  }

  Future<void> toBottom() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final pos = chatController.position.maxScrollExtent;
    chatController.jumpTo(pos);
  }

  void addItem(Message item) {
    messages.add(item);
    notifyListeners();
    user.addOldMessage(item);
  }

  void clearMessage() {
    messages.clear();
    debugPrint('清空聊天历史');
    notifyListeners();
  }

  Future<void> changeShowChoose(bool value) async {
    if (!value) {
      chooses.clear();
      jumps.clear();
      user.playLine -= 2;
      await user.save();
    }
    showChoose = value;
    notifyListeners();
  }

  void changeLeftChoose(String leftChoose) {
    if (chooses.isEmpty) {
      chooses.add(leftChoose);
    } else {
      chooses[0] = leftChoose;
    }
    notifyListeners();
  }

  String get leftChoose {
    if (chooses.isNotEmpty) {
      return chooses[0];
    }
    return '';
  }

  void changeRightChoose(String rightChoose) {
    if (chooses.length == 1) {
      chooses.add(rightChoose);
    } else {
      chooses[1] = rightChoose;
    }
    notifyListeners();
  }

  String get rightChoose {
    if (chooses.length == 2) {
      return chooses[1];
    }
    return '';
  }

  Future<void> changeStartTime(int startTime) async {
    user.startTime = startTime;
    await user.save();
  }

  int get startTime => user.startTime;
}
