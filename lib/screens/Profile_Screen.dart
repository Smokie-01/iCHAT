import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ichat/Helper/Snackbar.dart';
import 'package:ichat/Model/chat_user.dart';
import 'package:ichat/screens/auth/loginScreen.dart';
import 'package:image_picker/image_picker.dart';

import '../Api/Api.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  static const namedRoute = "ProfileScreen";

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    void showBotttomSheet() {
      // A method to show bottom sheet and acces galLary and camera
      showModalBottomSheet(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          context: context,
          builder: (_) {
            return ListView(
              padding: EdgeInsets.only(
                  top: mq.height * .06, bottom: mq.height * .02),
              shrinkWrap: true,
              children: [
                Text(
                  "Pick Profile Picture",
                  style: TextStyle(fontSize: 25),
                  textAlign: TextAlign.center,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            backgroundColor: Colors.white,
                            fixedSize: Size(mq.width * .3, mq.height * .15)),
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          // Pick an image.
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery, imageQuality: 70);
                          if (image != null) {
                            setState(() {
                              _image = image.path;
                            });
                            APIs.updateUserProfile(File(_image!));
                            Navigator.pop(context);
                          }
                        },
                        child: Image.asset("images/gallery.png")),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            backgroundColor: Colors.white,
                            fixedSize: Size(mq.width * .3, mq.height * .15)),
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          // Pick an image.
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.camera, imageQuality: 70);
                          if (image != null) {
                            setState(() {
                              _image = image.path;
                            });
                            APIs.updateUserProfile(File(_image!));

                            Navigator.pop(context);
                          }
                        },
                        child: Image.asset("images/camera.png"))
                  ],
                )
              ],
            );
          });
    }

    Future<void> signOut() async {
      // Sign out from Firebase Authenticatio

      // it shows custom progress indicator
      CustomDialog.showProgressIndicator(context);

      //it will remove the User id from app
      await APIs.auth.signOut().then((value) async => {
            //it will remove the id from data base
            await APIs.googleSignIn.signOut().then((value) => {
                  // this will pop the loading indicator
                  Navigator.pop(context),

                  // this will remove the homeScreen from stack
                  Navigator.pop(context),
                  // this will take you to the loading screen
                  Navigator.pushReplacementNamed(
                      context, LogInScreen.namedRoute)
                })
          });

      // Sign out from Google Sign-In.
    }

    final ChatUser chatUser =
        ModalRoute.of(context)!.settings.arguments as ChatUser;

    return GestureDetector(
      // this is use to hide keyborad if anywhere type
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: Text("Profile Screen")),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: mq.height * 0.01),
          child: FloatingActionButton.extended(
            onPressed: signOut,
            icon: Icon(Icons.logout),
            label: Text('LogOut'),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
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
                  Stack(children: [
                    _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(mq.height * .1),
                            child: Image.file(
                              File((_image!)),
                              height: mq.height * 0.2,
                              width: mq.height * 0.2,
                              fit: BoxFit.cover,
                            ))
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(mq.height * .1),
                            child: CachedNetworkImage(
                              height: mq.height * 0.2,
                              width: mq.height * 0.2,
                              fit: BoxFit.fill,
                              imageUrl: "${chatUser.imageUrl}",
                              errorWidget: (context, url, error) =>
                                  CircleAvatar(
                                child: Icon(CupertinoIcons.person),
                              ),
                            ),
                          ),
                    Positioned(
                      bottom: 5,
                      right: -20,
                      child: MaterialButton(
                        child: Icon(Icons.edit),
                        onPressed: showBotttomSheet,
                        color: Colors.white,
                        shape: CircleBorder(),
                      ),
                    )
                  ]),
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.03,
                  ),
                  Text("${chatUser.email}"),
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.03,
                  ),
                  TextFormField(
                    initialValue: "${chatUser.name}",
                    onSaved: (newValue) => APIs.me.name = newValue ?? "",
                    validator: (value) =>
                        value!.isNotEmpty ? null : 'Required Feild',
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: " eg. Happy singh ",
                        label: Text("Name")),
                  ),
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.03,
                  ),
                  TextFormField(
                    initialValue: "${chatUser.about}",
                    onSaved: (newValue) => APIs.me.about = newValue,
                    validator: (value) =>
                        value!.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: "About",
                        label: Text("About")),
                  ),
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.02,
                  ),
                  ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          APIs.updateUserInfo().then((value) {
                            CustomDialog.snackbar(
                                context, "Profile Updated Succesfully");
                          });
                        }
                      },
                      icon: Icon(Icons.edit),
                      label: Text('Update'))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
