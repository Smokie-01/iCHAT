import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ichat/Helper/date_util.dart';

import 'package:ichat/Model/chat_user.dart';

class ViewProfileScreen extends StatefulWidget {
  static const namedRoute = "ViewProfileScreen";
  ChatUser chatUser;
  ViewProfileScreen({required this.chatUser});

  @override
  State<ViewProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return GestureDetector(
      // this is use to hide keyborad if anywhere type
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.blueGrey,
        floatingActionButton:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            "Joined At :  ",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            MyDateUtil.getLastMessageTime(
                context: context,
                time: '${widget.chatUser.createdAT}',
                showYear: true),
            style: TextStyle(
              fontSize: 18,
            ),
          )
        ]),
        appBar: AppBar(
            backgroundColor: Colors.white60,
            title: Center(
                child: Text(
              "${widget.chatUser.name},",
              style: TextStyle(color: Colors.black),
            ))),
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: mq.width * 0.05,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: mq.width,
                  height: mq.height * 0.03,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .1),
                  child: CachedNetworkImage(
                    height: mq.height * 0.2,
                    width: mq.height * 0.2,
                    fit: BoxFit.cover,
                    imageUrl: "${widget.chatUser.imageUrl}",
                    errorWidget: (context, url, error) => CircleAvatar(
                      child: Icon(CupertinoIcons.person),
                    ),
                  ),
                ),
                SizedBox(
                  width: mq.width,
                  height: mq.height * 0.03,
                ),
                Text(
                  " User Email :  ${widget.chatUser.email}",
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  width: mq.width,
                  height: mq.height * 0.03,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    "About : ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${widget.chatUser.about}',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  )
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
