// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:ichat/Model/chat_user.dart';
import 'package:ichat/screens/View_Profile_Screen.dart';

class ProfileDialog extends StatelessWidget {
  ChatUser chatUser;
  ProfileDialog({
    Key? key,
    required this.chatUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return AlertDialog(
      content: Container(
        height: mq.height * .35,
        width: mq.width * .6,
        child: Stack(children: [
          Positioned(
            top: mq.height * .070,
            left: mq.width * 0.04,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(mq.height * .25),
              child: CachedNetworkImage(
                height: mq.height * 0.25,
                width: mq.height * 0.25,
                fit: BoxFit.cover,
                imageUrl: "${chatUser.imageUrl}",
                errorWidget: (context, url, error) => CircleAvatar(
                  child: Icon(CupertinoIcons.person),
                ),
              ),
            ),
          ),
          Positioned(
              top: mq.height * .011,
              left: mq.width * .011,
              child: Text(
                "${chatUser.name}",
                style: TextStyle(fontSize: 18),
              )),
          Positioned(
              left: mq.width * .5,
              child: IconButton(
                iconSize: 30,
                icon: Icon(Icons.info),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              ViewProfileScreen(chatUser: chatUser)));
                },
              ))
        ]),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
