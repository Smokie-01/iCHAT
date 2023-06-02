import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:ichat/Api/Api.dart';
import 'package:ichat/Helper/Snackbar.dart';
import 'package:ichat/Helper/date_util.dart';
import 'package:ichat/Model/chat_messages.dart';

class MessageCard extends StatefulWidget {
  final ChatMessage message;
  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  final isRead = false;
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
      child: isMe ? _greenMessage() : _blueMessage(),
      onLongPress: () {
        _showModalBottomSheet(isMe);
      },
    );
  }

  Widget _greenMessage() {
    final mq = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (widget.message.read!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(left: mq.width * .02),
                child: Icon(Icons.done_all, color: Colors.blue),
              ),
            Padding(
              padding: EdgeInsets.all(mq.height * .02),
              child: Text(MyDateUtil.getTimeInFormat(
                  context: context, time: widget.message.sent)),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: widget.message.type == MessageType.image
                ? EdgeInsets.all(mq.width * .01)
                : EdgeInsets.all(mq.width * .035),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .02, vertical: mq.height * .02),
            decoration: widget.message.type == MessageType.image
                ? null
                : BoxDecoration(
                    color: Color.fromARGB(255, 169, 251, 151),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                    )),
            child: widget.message.type == MessageType.text
                ? Text(
                    widget.message.message,
                    style: TextStyle(fontSize: 20),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                        fit: BoxFit.fill,
                        imageUrl: "${widget.message.message}",
                        errorWidget: (context, url, error) =>
                            Icon(Icons.image)),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _blueMessage() {
    // update read status if the sender and reciver are different ;
    if (widget.message.read!.isEmpty) {
      APIs.updateReadStatus(widget.message);
    }
    final mq = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
              padding: widget.message.type == MessageType.image
                  ? EdgeInsets.all(mq.width * .01)
                  : EdgeInsets.all(mq.width * .035),
              margin: EdgeInsets.symmetric(
                  horizontal: mq.width * .02, vertical: mq.height * .02),
              decoration: widget.message.type == MessageType.image
                  ? null
                  : BoxDecoration(
                      color: Color.fromARGB(255, 153, 209, 255),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                        topRight: Radius.circular(30),
                      )),
              child: widget.message.type == MessageType.text
                  ? Text(
                      widget.message.message,
                      style: TextStyle(fontSize: 20),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                          fit: BoxFit.fill,
                          imageUrl: "${widget.message.message}",
                          errorWidget: (context, url, error) =>
                              Icon(Icons.image)),
                    )),
        ),
        Row(
          children: [
            Padding(
              padding: EdgeInsets.all(mq.height * .02),
              child: Text(MyDateUtil.getTimeInFormat(
                  context: context, time: widget.message.sent)),
            ),
          ],
        ),
      ],
    );
  }

  void _showModalBottomSheet(bool isMe) {
    final mq = MediaQuery.of(context).size;
    // A method to show bottom sheet and acces galLary and camera
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        context: context,
        builder: (_) {
          return ListView(
            padding:
                EdgeInsets.only(top: mq.height * .06, bottom: mq.height * .02),
            shrinkWrap: true,
            children: [
              widget.message.type == MessageType.text
                  ? _bottomSheetItems(
                      title: "Copy",
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.message))
                            .then((value) {
                          // to hide bottom sheet
                          Navigator.pop(context);

                          CustomDialog.snackbar(context, "Text Copied ");
                        });
                      },
                      icon: Icon(Icons.copy_all_rounded))
                  : _bottomSheetItems(
                      title: "Save Image ",
                      onTap: () async {
                        try {
                          await GallerySaver.saveImage(widget.message.message,
                                  albumName: "iChat")
                              .then((success) {
                            print(success);
                            Navigator.pop(context);
                            if (success != null && success) {
                              CustomDialog.snackbar(
                                  context, "Image saved succesfully");
                            }
                          });
                        } on Exception catch (e) {
                          print(e);
                        }
                      },
                      icon: Icon(Icons.download)),
              Divider(
                color: Colors.blueGrey,
                thickness: 1,
                indent: mq.width * .035,
                endIndent: mq.width * .035,
              ),
              if (widget.message.type == MessageType.text && isMe)
                _bottomSheetItems(
                    title: "Edit Messgae ",
                    onTap: () {
                      Navigator.pop(context);
                      _showEditMessageBottomSheet();
                    },
                    icon: Icon(Icons.edit_note)),
              if (isMe)
                _bottomSheetItems(
                    title: "Delete Message ",
                    onTap: () {
                      APIs.deleteMessage(widget.message).then((value) {
                        // to hide the bottom sheet ;
                        Navigator.pop(context);
                        CustomDialog.snackbar(context, "Message Deleted ");
                      });
                    },
                    icon: Icon(Icons.delete_forever, color: Colors.redAccent)),
              if (isMe)
                Divider(
                  color: Colors.blueGrey,
                  thickness: 1,
                  indent: mq.width * .035,
                  endIndent: mq.width * .035,
                ),
              _bottomSheetItems(
                  title:
                      "Sent At  : ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}",
                  onTap: () {},
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: Colors.green,
                  )),
              _bottomSheetItems(
                  title: widget.message.read!.isEmpty
                      ? "Read At : Message is Uread"
                      : "Read At :  ${MyDateUtil.getMessageTime(context: context, time: "${widget.message.read}")}",
                  onTap: () {},
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: Colors.blue,
                  )),
            ],
          );
        });
  }

  void _showEditMessageBottomSheet() {
    String editedMsg = widget.message.message;
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            contentPadding:
                EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [Icon(Icons.message), Text("  Update Messgae ")],
            ),
            content: TextFormField(
                autofocus: true,
                onChanged: (value) {
                  editedMsg = value;
                },
                maxLines: null,
                initialValue: widget.message.message,
                decoration: InputDecoration(border: OutlineInputBorder())),
            actions: [
              TextButton(
                child: Text(
                  "Cancel",
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text(
                  "Update",
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  if (mounted)
                    APIs.updateChatMessgae(
                      widget.message,
                      editedMsg,
                    );
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }
}

class _bottomSheetItems extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Icon icon;

  const _bottomSheetItems(
      {required this.title, required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
          top: mq.height * .015,
          left: mq.width * .03,
          bottom: mq.height * .035,
        ),
        child: Row(
          children: [
            icon,
            Flexible(child: Text("       $title")),
          ],
        ),
      ),
    );
  }
}
