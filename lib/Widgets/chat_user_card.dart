import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ichat/Api/Api.dart';
import 'package:ichat/Model/chat_user.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../screens/chat_screen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  ChatUserCard({required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Card(
      margin: EdgeInsets.symmetric(
          horizontal: mq.width * 0.04, vertical: mq.height * 0.01),
      child: InkWell(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user)));
        },
        child: ListTile(
          title: Text("${widget.user.name}"),
          subtitle: Text(
            "${widget.user.about}",
            maxLines: 1,
          ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(mq.height * 0.3),
            child: CachedNetworkImage(
              height: mq.height * 0.070,
              width: mq.height * 0.070,
              imageUrl: "${widget.user.imageUrl}",
              errorWidget: (context, url, error) => CircleAvatar(
                child: Icon(CupertinoIcons.person),
              ),
            ),
          ),
          trailing: Text("12:00 PM"),
        ),
      ),
    );
  }
}
