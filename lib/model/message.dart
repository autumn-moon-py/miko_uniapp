import 'dart:convert';

import 'package:flutter_easyloading/flutter_easyloading.dart';

enum MessageType { left, middle, right, image, none }

class Message {
  MessageType type;
  String message;
  String? name;
  String? image;
  String? avatarUrl;

  Message(
    this.message,
    this.type, {
    this.name,
    this.image,
    this.avatarUrl,
  });

  Message.full({
    this.message = '',
    this.type = MessageType.none,
    this.name,
    this.image,
    this.avatarUrl,
  });

  @override
  String toString() {
    return jsonEncode({
      'name': name,
      'message': message,
      'type': type.index,
      'avatarUrl': avatarUrl,
      'image': image
    });
  }

  static Message fromString(String jsonStr) {
    try {
      Map<String, dynamic> messageMap = jsonDecode(jsonStr);
      return Message.full(
        name: messageMap['name'],
        message: messageMap['message'],
        type: MessageType.values[messageMap['type']],
        avatarUrl: messageMap['avatarUrl'],
        image: messageMap['image'],
      );
    } catch (e) {
      EasyLoading.showError("Message装填异常:$e,raw:$jsonStr");
      return Message.full();
    }
  }
}
