import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keframe/keframe.dart';
import 'package:miko/model/message.dart';
import 'package:miko/theme/color.dart';

import 'dart:async';

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;
  final Future<void> Function() toBottom;

  const TypewriterText({
    Key? key,
    required this.text,
    this.duration = const Duration(milliseconds: 100),
    required this.style,
    required this.toBottom,
  }) : super(key: key);

  @override
  TypewriterTextState createState() => TypewriterTextState();
}

class TypewriterTextState extends State<TypewriterText>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  String _displayText = "";
  Timer? _timer;
  int _charIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    if (widget.text != oldWidget.text) {
      _charIndex = 0;
      _displayText = '';
      _startTyping();
      super.didUpdateWidget(oldWidget);
    }
  }

  void _startTyping() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.duration, (timer) async {
      if (_charIndex < widget.text.length) {
        setState(() {
          _displayText += widget.text[_charIndex];
        });
        _charIndex++;
        await widget.toBottom();
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Text(_displayText, style: widget.style);
  }
}

class Bubble extends StatelessWidget {
  final MessageType? type;
  final String avatarAssets;
  final String avatarUrl;
  final Color backgroundColor;
  final String text;
  final String image;
  final Function()? onTap;
  final Future<void> Function() toBottom;
  const Bubble(
      {super.key,
      required this.type,
      required this.backgroundColor,
      this.image = '',
      this.avatarAssets = '',
      this.avatarUrl = '',
      this.text = '',
      this.onTap,
      required this.toBottom});

  Widget avatar() {
    late Widget child;
    if (avatarUrl.isNotEmpty) {
      child = CachedNetworkImage(
          imageUrl: avatarUrl,
          errorWidget: (_, url, e) =>
              const Icon(Icons.error, color: Colors.red));
    } else {
      child = Image.asset(avatarAssets,
          errorBuilder: (_, url, e) =>
              const Icon(Icons.error, color: Colors.red));
    }

    return Container(
        width: 130.w,
        padding: EdgeInsets.only(
            left: type == MessageType.left ? 20.w : 10.w,
            right: type == MessageType.right ? 20.w : 10.w),
        child: ClipOval(child: child));
  }

  Widget assetsImage() {
    if (image.isEmpty) return const SizedBox();
    return ClipRRect(
        borderRadius: BorderRadiusDirectional.circular(20),
        child: Image.asset(image,
            width: 195,
            height: 260,
            errorBuilder: (_, url, e) =>
                const Icon(Icons.error, color: Colors.red)));
  }

  Widget bubble() {
    final style = TextStyle(color: Colors.white, fontSize: 40.r);
    Widget tw = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 0.7.sw),
        child: Wrap(children: [
          // Text(text, style: style),
          if (type == MessageType.middle) Text(text, style: style),
          if (type != MessageType.middle)
            TypewriterText(text: text, style: style, toBottom: toBottom)
        ]));

    Widget child;
    if (type == MessageType.middle) {
      child = tw;
    } else {
      child = ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Container(
              color: backgroundColor,
              padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 20.w),
              child: tw));
    }
    return GestureDetector(onTap: () => onTap!.call(), child: child);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start;
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center;
    if (text.length >= 18) crossAxisAlignment = CrossAxisAlignment.start;
    if (type == MessageType.left) {
      children = [avatar(), bubble()];
    }
    if (type == MessageType.middle) {
      children = [bubble()];
      mainAxisAlignment = MainAxisAlignment.center;
    }
    if (type == MessageType.right) {
      children = [bubble(), avatar()];
      mainAxisAlignment = MainAxisAlignment.end;
    }
    if (type == MessageType.image) {
      crossAxisAlignment = CrossAxisAlignment.start;
      children = [avatar(), assetsImage()];
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
          crossAxisAlignment: crossAxisAlignment,
          mainAxisAlignment: mainAxisAlignment,
          children: children),
    );
  }
}

class ChatList extends StatefulWidget {
  final Function(String) handleShowAD;
  final ScrollController controller;
  final List<Message>? oldMessages;
  final List<Message> messages;
  final Future<void> Function() toBottom;
  const ChatList(
      {super.key,
      required this.handleShowAD,
      required this.controller,
      this.oldMessages,
      required this.messages,
      required this.toBottom});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Widget _bodyItemBuilder(Message item, int index, BuildContext context) {
    late String avatar;
    late Color background;
    late Widget bubble;
    String iconBase(String value) => 'assets/icon/$value.webp';
    if (item.type == MessageType.left || item.type == MessageType.image) {
      background = MyTheme.background;
      final name = item.name;
      if (name == '未知用户') {
        avatar = iconBase('player');
      }
      if (name == 'Lily') {
        avatar = iconBase('Lily');
      }
      if (name == 'Miko') {
        avatar = iconBase('miko');
      }
      if (avatar.isEmpty) {
        EasyLoading.showError('设置消息头像异常');
        avatar = iconBase('miko');
      }
    }
    if (item.type == MessageType.left) {
      bubble = Bubble(
          type: item.type,
          avatarAssets: avatar,
          backgroundColor: background,
          toBottom: widget.toBottom,
          text: item.message);
    }
    if (item.type == MessageType.middle) {
      final msg = item.message;
      String key = '';
      if (msg.contains('广告')) {
        if (msg.contains('下线')) key = '下线';
        if (msg.contains('坏结局')) key = '坏结局';
      }
      final text = item.message;
      bubble = Bubble(
          type: item.type,
          toBottom: widget.toBottom,
          text: text,
          backgroundColor: Colors.transparent,
          onTap: () => widget.handleShowAD(key));
    }
    if (item.type == MessageType.right) {
      background = MyTheme.foreground62;
      const narmalAvatar = 'assets/icon/player.webp';
      bubble = Bubble(
        type: MessageType.right,
        toBottom: widget.toBottom,
        avatarAssets: narmalAvatar,
        backgroundColor: background,
        text: item.message,
      );
    }
    if (item.type == MessageType.image) {
      final assetsImage = 'assets/photo/${item.image}.webp';
      bubble = Bubble(
        type: MessageType.image,
        avatarAssets: avatar,
        toBottom: widget.toBottom,
        image: assetsImage,
        backgroundColor: Colors.transparent,
      );
    }
    return bubble;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizeCacheWidget(
        estimateCount: 50,
        child: ListView.builder(
            itemCount: widget.messages.length,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(top: 20.h, bottom: 40.h),
            controller: widget.controller,
            itemBuilder: (_, index) => FrameSeparateWidget(
                index: index,
                child:
                    _bodyItemBuilder(widget.messages[index], index, context))));

    // SizeCacheWidget(
    //     child: BuildMessageLayout(
    //         oldList: widget.oldMessages.reversed.toList(),
    //         newList: widget.messages.reversed.toList(),
    //         controller: widget.controller,
    //         builder: (context, item, index) => FrameSeparateWidget(
    //             index: index,
    //             child:
    //                 _bodyItemBuilder(widget.messages[index], index, context))));
  }
}

class ChooseButton extends StatelessWidget {
  final Function(String, int) onTap;
  final bool showChoose;
  final List<String> chooses;
  final List<int> jumps;
  const ChooseButton(
      {super.key,
      required this.onTap,
      required this.showChoose,
      required this.chooses,
      required this.jumps});

  Widget button(String text, int jump) {
    return GestureDetector(
        onTap: () => onTap(text, jump),
        child: Container(
            alignment: Alignment.center,
            color: Colors.transparent,
            child: Text(text, style: MyTheme.narmalStyle)));
  }

  @override
  Widget build(BuildContext context) {
    return !showChoose
        ? const SizedBox()
        : Container(
            width: 1.sw,
            color: MyTheme.foreground62,
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              button(chooses[0], jumps[0]),
              const Divider(color: Colors.grey),
              button(chooses[1], jumps[1])
            ]));
  }
}

class BuildMessageLayout extends StatefulWidget {
  final ScrollController controller;
  final List<Message> oldList;
  final List<Message> newList;
  final Widget Function(BuildContext context, Message item, int index) builder;

  const BuildMessageLayout({
    super.key,
    required this.controller,
    required this.builder,
    this.oldList = const [],
    this.newList = const [],
  });

  @override
  State<BuildMessageLayout> createState() => _BuildMessageLayoutState();
}

class _BuildMessageLayoutState extends State<BuildMessageLayout> {
  final _centerKey = GlobalKey();
  double _anchor = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extentInside = widget.controller.position.extentInside;
      final extentBefore = widget.controller.position.extentBefore;
      setState(() {
        _anchor = extentBefore / extentInside;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
        physics: const BouncingScrollPhysics(),
        controller: widget.controller,
        center: _centerKey,
        anchor: min(1, _anchor),
        slivers: [
          SliverList.builder(
              itemCount: widget.oldList.length,
              itemBuilder: (BuildContext context, int index) {
                return widget.builder(context, widget.oldList[index], index);
              }),
          SliverToBoxAdapter(key: _centerKey),
          SliverList.builder(
              itemCount: widget.newList.length,
              itemBuilder: (BuildContext context, int index) {
                return widget.builder(context, widget.newList[index], index);
              })
        ]);
  }
}
