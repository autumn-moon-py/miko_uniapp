import 'package:flutter/material.dart';

enum StoryType {
  leftT,
  leftJump,
  leftBejump,
  leftJumpAndBejump,
  middleBejump,
  middleJumpAndBejump,
  middelT,
  rigthT,
  rightJump,
  choose,
  day,
  trend,
  image,
  wait,
  waitJump,
  be,
  none
}

class Story {
  int index = 0;
  String name = '';
  String msg = '';
  String pos = '';
  int jump = 0;
  int beJump = 0;
  String choose = '';
  int day = 0;
  int wait = 0;
  bool be = false;
  String image = '';
  StoryType type = StoryType.none;

  static final Map<String, StoryType> _positionToType = {
    '左': StoryType.leftT,
    '中': StoryType.middelT,
    '右': StoryType.rigthT,
    '日': StoryType.day,
    '动态': StoryType.trend,
    '图鉴': StoryType.image,
    'BE': StoryType.be,
  };

  void toType() {
    type = _positionToType[pos] ?? StoryType.none;
    if (type == StoryType.day) {
      day = int.tryParse(msg) ?? 0;
      msg = '';
    }
    if (type == StoryType.trend || type == StoryType.image) {
      image = type == StoryType.trend ? name : msg;
      name = '';
      msg = '';
    }
    if (type == StoryType.be) {
      be = true;
      msg = '已进入坏结局, 点击看广告跳过';
    }
  }

  void replaceName() {
    final nameMap = {
      'miko': '米可',
      'Miko': '米可',
      'iris': '爱丽丝',
      'Iris': '爱丽丝',
      'lily': '李莉',
      'Lily': '李莉'
    };
    name = nameMap[name] ?? name;
    msg = msg
        .replaceAll('Miko', '米可')
        .replaceAll('Iris', '爱丽丝')
        .replaceAll('Lily', '李莉');
  }

  Story.fromList(int value, List line) {
    index = value;
    String tagsText = line[2];
    List<String> tags = tagsText.split(',');
    name = line[0].toString();
    msg = line[1].toString();
    pos = tags[0];
    toType();

    if (tags.length == 1) return;

    for (var tag in tags) {
      if (tag.contains('选项')) {
        choose = msg;
        jump = int.tryParse(tags[2]) ?? 0;
        type = StoryType.choose;
      }

      if (tag.contains('分支')) {
        beJump = int.tryParse(tag.replaceAll('分支', '')) ?? 0;
        if (type == StoryType.leftT) {
          type = StoryType.leftBejump;
        }
        if (type == StoryType.middelT) {
          type = StoryType.middleBejump;
        }
      }

      if (tag.contains('等待')) {
        jump = int.tryParse(tags[1]) ?? 0;
        wait = int.tryParse(tags[3]) ?? 0;
        type = StoryType.wait;
        msg = '已进入下线等待, 点击看广告跳过';
        if (jump != 0) {
          type = StoryType.waitJump;
        }
      }
    }

    if (type == StoryType.middleBejump && tags.length == 3) {
      jump = int.tryParse(tags[1]) ?? 0;
      type = StoryType.middleJumpAndBejump;
    }

    if (type == StoryType.leftT && tags.length == 2) {
      jump = int.tryParse(tags[1]) ?? 0;
      type = StoryType.leftJump;
    }

    if (type == StoryType.leftBejump && tags.length == 3) {
      jump = int.tryParse(tags[1]) ?? 0;
      type = StoryType.leftJumpAndBejump;
    }

    if (type == StoryType.middleBejump && tags.length == 3) {
      jump = int.tryParse(tags[1]) ?? 0;
      type = StoryType.middleJumpAndBejump;
    }

    if (type == StoryType.rigthT && tags.length == 2) {
      jump = int.tryParse(tags[1]) ?? 0;
      type = StoryType.rightJump;
    }
  }

  void log() {
    debugPrint('index: $index ');
    if (name.isNotEmpty) {
      debugPrint('name: $name ');
    }
    if (msg.isNotEmpty) {
      debugPrint('msg: $msg ');
    }
    if (pos.isNotEmpty) {
      debugPrint('pos: $pos ');
    }
    if (jump != 0) {
      debugPrint('jump: $jump ');
    }
    if (beJump != 0) {
      debugPrint('beJump: $beJump ');
    }
    if (choose.isNotEmpty) {
      debugPrint('choose: $choose ');
    }
    if (day != 0) {
      debugPrint('day: $day ');
    }
    if (wait != 0) {
      debugPrint('wait: $wait ');
    }
    if (image.isNotEmpty) {
      debugPrint('image: $image ');
    }
    if (type != StoryType.none) {
      debugPrint('type: $type ');
    }
    if (be) {
      debugPrint('be: $be ');
    }
  }
}
