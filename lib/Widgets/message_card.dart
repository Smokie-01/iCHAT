import 'package:flutter/material.dart';
import 'package:ichat/Api/Api.dart';
import 'package:ichat/Model/chat_messages.dart';

class MessageCard extends StatefulWidget {
  final ChatMessage message;
  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return APIs.user.uid == widget.message.fromId
        ? _greenMessage()
        : _blueMessage();

    // : _greenMessage();
  }

  Widget _greenMessage() {
    final mq = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: mq.width * .02),
              child: Icon(Icons.done_all),
            ),
            Padding(
              padding: EdgeInsets.all(mq.height * .02),
              child: Text(widget.message.sent),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * .035),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .02, vertical: mq.height * .02),
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 169, 251, 151),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                )),
            child: Text(
              widget.message.message,
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _blueMessage() {
    final mq = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * .035),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .02, vertical: mq.height * .02),
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 153, 209, 255),
                // ,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                  topRight: Radius.circular(30),
                )),
            child: Text(
              widget.message.message,
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
        Row(
          children: [
            Padding(
              padding: EdgeInsets.all(mq.height * .02),
              child: Text(widget.message.sent),
            ),
            Padding(
              padding: EdgeInsets.only(right: mq.width * .02),
              child: Icon(Icons.done_all),
            ),
          ],
        ),
      ],
    );
  }
}
