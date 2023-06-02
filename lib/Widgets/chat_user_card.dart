import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ichat/Api/Api.dart';
import 'package:ichat/Helper/date_util.dart';
import 'package:ichat/Model/chat_messages.dart';

import 'package:ichat/Model/chat_user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ichat/Widgets/dialog/profile_custom_dialog.dart';

import '../screens/chat_screen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  ChatUserCard({required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  ChatMessage? _message;
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Card(
      margin: EdgeInsets.symmetric(
          horizontal: mq.width * 0.04, vertical: mq.height * 0.01),
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(user: widget.user)));
          },
          child: StreamBuilder(
            stream: APIs.getLastMessage(widget.user),
            builder: (context, snapshot) {
              // this used check weather the data is available or not ;
              if (snapshot.hasData) {
                final data = snapshot.data!.docs;

                // this list contains list of chatMessages between two specific users
                final _list =
                    data.map((e) => ChatMessage.fromJson(e.data())).toList();

                // check weather the list is weather or empty or not;
                if (_list.isNotEmpty) {
                  _message = _list[0];
                }
              } else {
                return ListTile(
                  // Placeholder UI when data is null or loading
                  title: Text("${widget.user.name}"),
                  subtitle: Text("Loading..."),
                  leading: CircularProgressIndicator(),
                );
              }

              return ListTile(
                  // user name
                  title: Text("${widget.user.name}"),

                  // user about
                  subtitle: Text(
                    _message != null
                        ? _message!.type == MessageType.image
                            ? "image"
                            : _message!.message
                        : "${widget.user.about}",
                    maxLines: 1,
                  ),
                  // users profile picture;
                  leading: InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (_) {
                            return ProfileDialog(
                              chatUser: widget.user,
                            );
                          });
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * 0.3),
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        height: mq.height * 0.070,
                        width: mq.height * 0.070,
                        imageUrl: "${widget.user.imageUrl}",
                        errorWidget: (context, url, error) => CircleAvatar(
                          child: Icon(
                            CupertinoIcons.person,
                          ),
                        ),
                      ),
                    ),
                  ),
                  trailing:
                      //this ternary operator is used to check weather is null or not;
                      _message == null
                          ? null

                          // its nested ternary operator , to check weather the sender and the reciver is same or not;
                          : _message!.read!.isEmpty &&
                                  _message!.fromId != APIs.user.uid
                              ?
                              //show this container if message is unRead
                              Container(
                                  width: 15,
                                  height: 15,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.green),
                                )
                              :
                              // else show this text widget
                              Text(
                                  MyDateUtil.getLastMessageTime(
                                      context: context,
                                      time: _message!.sent,
                                      showYear: true),
                                  style: TextStyle(color: Colors.black54),
                                ));
            },
          )),
    );
  }
}
