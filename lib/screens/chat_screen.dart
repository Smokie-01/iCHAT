import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ichat/Api/Api.dart';
import 'package:ichat/Model/chat_messages.dart';
import 'package:ichat/Model/chat_user.dart';
import 'package:ichat/Widgets/message_card.dart';

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
  final _textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    print(data[0].data());
                    _chatMessages = data
                        .map((e) => ChatMessage.fromJson(e.data()))
                        .toList();
                    print(_chatMessages[0].message);

                    if (_chatMessages.isNotEmpty) {
                      return ListView.builder(
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
          _chatInput(),
        ],
      ),
    );
  }

  Widget _appBar() {
    final mq = MediaQuery.of(context).size;

    return InkWell(
      onTap: () {},
      child: Row(
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
              imageUrl: "${widget.user.imageUrl}",
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
                "${widget.user.name}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 2,
              ),
              Text("Last Active ")
            ],
          )
        ],
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
                      onPressed: () {},
                      icon: Icon(
                        Icons.emoji_emotions,
                        size: 26,
                      )),
                  Expanded(
                      child: TextFormField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Type Something...."),
                  )),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.image,
                        size: 26,
                      )),
                  IconButton(
                      onPressed: () {},
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
                  await APIs.sendMessgae(widget.user, _textController.text);
                  _textController.text = "";
                }
              },
              icon: Icon(Icons.send))
        ],
      ),
    );
  }
}
