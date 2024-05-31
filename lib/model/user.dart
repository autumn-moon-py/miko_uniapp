import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:miko/global.dart';
import 'package:miko/model/message.dart';

class User {
  String avatar = '';
  String name = '';
  String chapter = '第一章';
  int playLine = 0;
  List<Message> oldMessages = [];
  int startTime = 0;
  int day = 1;
  int jump = 0;
  bool showAd = false;
  final local = Global.local;

  Future<void> load() async {
    avatar = local.getString('avatar') ?? avatar;
    name = local.getString('name') ?? name;
    playLine = local.getInt('playLine') ?? playLine;
    chapter = local.getString('chapter') ?? chapter;
    loadMessage(local.getStringList('oldMessage') ?? []);
    startTime = local.getInt('startTime') ?? startTime;
    day = local.getInt('day') ?? day;
    jump = local.getInt('jump') ?? jump;
  }

  Future<void> save() async {
    local.setString('avatar', avatar);
    local.setString('name', name);
    local.setString('chapter', chapter);
    local.setInt('playLine', playLine);
    local.setInt('startTime', startTime);
    local.setInt('day', day);
    local.setInt('jump', jump);
  }

  void errorT(bool success) {
    if (!success) EasyLoading.showError('保存失败');
  }

  void addOldMessage(Message item) {
    if (oldMessages.length == 10) {
      oldMessages.removeAt(0);
    }
    oldMessages.add(item);
    saveMessage();
  }

  Future<void> saveMessage() async {
    var messageList = oldMessages.map((msg) => msg.toString()).toList();
    local.setStringList('oldMessage', messageList);
  }

  void loadMessage(List<String> messageList) {
    oldMessages = messageList.map((json) => Message.fromString(json)).toList();
  }
}
