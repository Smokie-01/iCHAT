import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ichat/Api/Api.dart';
import 'package:ichat/Helper/date_util.dart';
import 'package:ichat/Model/chat_messages.dart';
import 'package:ichat/Model/chat_user.dart';
import 'package:ichat/Widgets/message_card.dart';
import 'package:ichat/screens/View_Profile_Screen.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  static const namedRoute = "chat_screen";

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // for storing all the messgaes;
  List<ChatMessage> _chatMessages = [];
  bool _showEmoji = false, _isUploading = false;

  final _textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        //if showEmoji  is on and BackButton is pressed then closed search
        // or else simple close the current screen on back button is pressed
        onWillPop: () {
          if (_showEmoji) {
            setState(() {
              _showEmoji = !_showEmoji;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.blueGrey,
          appBar: AppBar(
            backgroundColor: Colors.white60,
            automaticallyImplyLeading: false,
            flexibleSpace: _appBar(),
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: APIs.getAllMessgaes(widget.user),
                  builder: ((context, snapshot) {
                    switch (snapshot.connectionState) {

                      // when data is loading
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return SizedBox();

                      // when data is fetched
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data!.docs;

                        _chatMessages = data
                            .map((e) => ChatMessage.fromJson(e.data()))
                            .toList();

                        if (_chatMessages.isNotEmpty) {
                          return ListView.builder(
                            reverse: true,
                            physics: BouncingScrollPhysics(),
                            itemCount: _chatMessages.length,
                            itemBuilder: ((context, index) {
                              return MessageCard(message: _chatMessages[index]);
                            }),
                          );
                        } else
                          return Center(
                              child: Text(
                            " Say Hii.. !!! ",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ));
                    }
                  }),
                ),
              ),
              if (_isUploading)
                Align(
                    alignment: Alignment.centerRight,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    )),
              _chatInput(),
              if (_showEmoji)
                SizedBox(
                  height: mq.height * .35,
                  child: EmojiPicker(
                    textEditingController: _textController,
                    config: Config(
                      columns: 7,
                      emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    final mq = MediaQuery.of(context).size;

    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ViewProfileScreen(chatUser: widget.user)));
      },
      child: StreamBuilder(
        stream: APIs.getUserInfo(widget.user),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!.docs;
            final list = data.map((e) => ChatUser.fromJson(e.data())).toList();

            return Row(
              children: [
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.black,
                    )),
                SizedBox(
                  width: 5,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * 0.3),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    height: mq.height * 0.060,
                    width: mq.height * 0.060,
                    imageUrl: list.isNotEmpty
                        ? "${list[0].imageUrl}"
                        : "${widget.user.imageUrl}",
                    errorWidget: (context, url, error) => CircleAvatar(
                      child: Icon(CupertinoIcons.person),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.isNotEmpty
                          ? "${list[0].name}"
                          : "${widget.user.name}",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(list.isNotEmpty
                        ? list[0].isOnline
                            ? 'Online'
                            : MyDateUtil.getLastACtiveTime(
                                context: context,
                                lastActive: "${list[0].lastActive}")
                        : MyDateUtil.getLastACtiveTime(
                            context: context,
                            lastActive: "${widget.user.lastActive}"))
                  ],
                )
              ],
            );
          }
          return SizedBox();
        }),
      ),
    );
  }

  Widget _chatInput() {
    final mq = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * 0.01),
      child: Row(
        children: [
          Expanded(
            child: Card(
              color: Colors.blueGrey.shade200,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _showEmoji = !_showEmoji;
                        });
                      },
                      icon: Icon(
                        Icons.emoji_emotions,
                        size: 26,
                      )),
                  Expanded(
                      child: TextFormField(
                    onTap: () {
                      if (_showEmoji)
                        setState(() {
                          _showEmoji = !_showEmoji;
                        });
                    },
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Type Something...."),
                  )),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick  multiple Images
                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 70);

                        for (var image in images) {
                          setState(() {
                            _isUploading = true;
                          });

                          // for uploading image to our fire base
                          await APIs.sendChatImage(
                              widget.user, File(image.path));
                          setState(() {
                            _isUploading = false;
                          });
                        }
                      },
                      icon: Icon(
                        Icons.image,
                        size: 26,
                      )),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);
                        if (image != null) {
                          setState(() {
                            _isUploading = true;
                          });
                          await APIs.sendChatImage(
                              widget.user, File(image.path));
                          setState(() {
                            _isUploading = true;
                          });
                        }
                      },
                      icon: Icon(
                        Icons.camera_alt_rounded,
                        size: 26,
                      ))
                ],
              ),
            ),
          ),
          IconButton(
              onPressed: () async {
                if (_textController.text.isNotEmpty) {
                  await APIs.sendMessgae(
                      widget.user, _textController.text, MessageType.text);
                  _textController.text = "";
                }
              },
              icon: Icon(Icons.send))
        ],
      ),
    );
  }
}
