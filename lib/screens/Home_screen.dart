import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ichat/Api/Api.dart';
import 'package:ichat/Helper/Snackbar.dart';
import 'package:ichat/Widgets/chat_user_card.dart';
import '../Model/chat_user.dart';
import 'Profile_Screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});
  static const namedRoute = "HomeScreen";
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //to store the all user
  List<ChatUser> _list = [];
  // to search users from the list
  final List<ChatUser> _searchList = [];
  // boolean to check weather its searching or not
  bool _isSearching = false;
  @override
  void initState() {
    super.initState();
    /* this will give the inital value true(Online) as soon as 
    user opens  to home screen */
    APIs.getSlefInfo();

    SystemChannels.lifecycle.setMessageHandler((message) {
      //message = pause ----> user offline
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains("pause")) {
          APIs.updateActiveStatus(false);
        }
        //message = resume ----> user online
        if (message.toString().contains("resume")) {
          APIs.updateActiveStatus(true);
        }
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        //if search is on and BackButton is pressed then closed search
        // or else simple close the current screen on back button is pressed
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: _isSearching
                ? Padding(
                    padding: const EdgeInsets.only(),
                    child: TextFormField(
                      onChanged: (value) {
                        // when search Text changes update the UI;
                        _searchList.clear();
                        for (var user in _list) {
                          // this will check the enterd value is available in the list or not;
                          if (user.name!.contains(value.toLowerCase()) ||
                              user.email!.contains(value.toLowerCase())) {
                            _searchList.add(user);
                          }
                          setState(() {
                            _searchList;
                          });
                        }
                      },
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: "Name, Email..",
                        border: InputBorder.none,
                      ),
                    ),
                  )
                : Text("iChat"),
            centerTitle: true,
            leading:
                IconButton(onPressed: () {}, icon: Icon(CupertinoIcons.home)),
            backgroundColor: _isSearching ? Colors.white : Colors.black,
            actions: [
              //search user button
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon: Icon(_isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search)),
              // more aoptins button
              IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, ProfileScreen.namedRoute,
                        arguments: APIs.me);
                  },
                  icon: Icon(Icons.more_vert))
            ],
          ),
          //FLoating action button to add new user
          floatingActionButton: IconButton(
            iconSize: 35,
            color: Colors.blueGrey,
            onPressed: () {
              _addChatUser();
            },
            icon: Icon(
              CupertinoIcons.person_add_solid,
            ),
          ),
          body: StreamBuilder(
            stream: APIs.getAllUser(),
            builder: ((context, snapshot) {
              switch (snapshot.connectionState) {

                // when data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return Center(child: CircularProgressIndicator());

                // when data is fetched
                case ConnectionState.active:
                case ConnectionState.done:
                  final data = snapshot.data?.docs;
                  _list =
                      data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                          [];
                  if (_list.isNotEmpty) {
                    return ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount:
                          _isSearching ? _searchList.length : _list.length,
                      itemBuilder: ((context, index) {
                        return ChatUserCard(
                          user:
                              _isSearching ? _searchList[index] : _list[index],
                        );
                      }),
                    );
                  } else {
                    return Center(child: Text("No Connections has found !! "));
                  }
              }
            }),
          ),
        ),
      ),
    );
  }

  void _addChatUser() {
    String email = "";
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            contentPadding:
                EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [Icon(Icons.message), Text("  Add Users  ")],
            ),
            content: TextFormField(
                autofocus: true,
                onChanged: (value) {
                  email = value;
                },
                maxLines: null,
                decoration: InputDecoration(
                    hintText: "Email Id",
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder())),
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
                  "Add",
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  if (email.isNotEmpty) {
                    await APIs.addChatuser(email).then((value) {
                      if (!value) {
                        CustomDialog.snackbar(context, "User does nto exsist");
                      }
                    });
                  }
                },
              )
            ],
          );
        });
  }
}
