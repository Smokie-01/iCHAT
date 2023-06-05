import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:ichat/Helper/Snackbar.dart';

import 'package:ichat/Model/chat_messages.dart';

import 'package:ichat/Model/chat_user.dart';
import 'package:http/http.dart' as http;
import 'package:ichat/screens/auth/loginScreen.dart';

class APIs {
  // For Authentication
  static FirebaseAuth auth = FirebaseAuth.instance;
// For accesing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // For accesing the firebase Storage to store user generated data
  static FirebaseStorage storage = FirebaseStorage.instance;

  // For PushNotifications usinf Firebase Messaging
  static FirebaseMessaging _fireMessaging = FirebaseMessaging.instance;

  static GoogleSignIn googleSignIn = GoogleSignIn();
  //its getter to get auth current users

  // A variable for storing self information
  static late ChatUser me;

  // this will return the current user
  static User get user {
    return auth.currentUser!;
  }

  static Future<void> getFirebaseMessagingToken() async {
    await _fireMessaging.requestPermission();

    await _fireMessaging.getToken().then((token) {
      if (token != null) {
        me.pushToken = token;
      }
    });
  }

  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        'to': chatUser.id,
        "notification": {
          'title': "${chatUser.name}",
          'msg': "$msg",
          "android_channel_id": "chats"
        },
        "data": {"some_data": "User Id :" "${me.id}"}
      };
      http.Response resposnse =
          await http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
              headers: {
                HttpHeaders.contentTypeHeader: "aplication/json",
                HttpHeaders.authorizationHeader:
                    "AAAAXRJ9J7Y:APA91bEC49fl6444SyjTu9OHl3eFcVjoe-JZPfzNtBaNzwVgF6BO12n6w57DVIKvkPb764fYpN-zBDIAwoKEAf5--VxiTPuQfvrQuxaRysJnaZUamrhTsDre12VPND7uboPOtbTDWo8K"
              },
              body: jsonEncode(body));
    } on Exception catch (e) {
      print("Error : $e");
    }
  }

  static Future<void> getSlefInfo() async {
    // get the users info for creating new user
    firestore.collection("users").doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();

        // this Functionality is used to check weather the user is online or not;
        APIs.updateActiveStatus(true);
      } else {
        createUser().then((value) => {getSlefInfo()});
      }
    });
  }

  // To add a specific user we want
  static Future<bool> addChatuser(String email) async {
    // check weatther the user exist or not in database
    final data = await (firestore
        .collection("users")
        .where("email", isEqualTo: email)
        .get());
    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      await (firestore
          .collection("users")
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({}));
      return true;
    } else {
      // user dont exisit ;
      return false;
    }
  }

  static Future<bool> removeUser(String id) async {
    // check weatther the user exist or not in database
    final data =
        await (firestore.collection("users").where("id", isEqualTo: id).get());
    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      await (firestore
          .collection("users")
          .doc(user.uid)
          .collection('my_users')
          .doc(id)
          .delete());
      return true;
    } else {
      // user dont exisit ;
      return false;
    }
  }

// check weather user already exist or not
  static Future<bool> userExisit() async {
    // check weatther the user exist or not in database
    final userDocSnapshot =
        await (firestore.collection("users").doc(user.uid).get());
    return userDocSnapshot.exists;
  }

  static Future<void> createUser() async {
    // create a user
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
        name: user.displayName,
        id: user.uid,
        email: user.email,
        imageUrl: user.photoURL,
        pushToken: "",
        lastActive: time,
        isOnline: false,
        createdAT: time,
        about: " Hey I am using iChat !");

    return await firestore
        .collection("users")
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  static Future<void> signOut(BuildContext context) async {
    // Sign out from Firebase Authenticatio

    APIs.updateActiveStatus(false);
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

                APIs.auth = FirebaseAuth.instance,
                // this will take you to the loading screen
                Navigator.pushReplacementNamed(context, LogInScreen.namedRoute)
              })
        });

    // Sign out from Google Sign-In.
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser(
      List<String> usersIds) {
    // a method to get all user from firebase to ui
    return firestore
        .collection("users")
        .where("id", whereIn: usersIds)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUserId() {
    // a method to get all user from firebase to ui
    return firestore
        .collection("users")
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  static Future<void> sendFirstMessgae(
      ChatUser chatUser, String msg, MessageType messageType) async {
    await (firestore
        .collection("users")
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessgae(chatUser, msg, messageType)));
  }

// function to update user personal info
  static Future<void> updateUserInfo() async {
    await (firestore.collection("users").doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    }));
  }

  static Future<void> updateUserProfile(File file) async {
    // getting file extension
    final extension = file.path.split(".").last;

    // create a referenc in firebase Storage
    final ref = storage.ref().child("profile_pictures/ ${user.uid}.$extension");

// upload the file in that storage
    await ref.putFile(file);

    // get the url of that file
    me.imageUrl = await ref.getDownloadURL();

    // update the url in firebase data
    await (firestore.collection("users").doc(user.uid).update({
      'imageUrl': me.imageUrl,
    }));
  }

// a method to get all user from firebase to ui
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection("users")
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection("users").doc(user.uid).update({
      "isOnline": isOnline,
      "last_active": DateTime.now().millisecondsSinceEpoch.toString(),
      "push_token": me.pushToken,
    });
  }

// Get Last seen of the user;

  /// ************** CHAT RELATED APIs **********************

  // this method returs unique id for Conversations beettwen the user
  static String getConversationID(String id) {
    return user.uid.hashCode <= id.hashCode
        ? '${user.uid}_${id}'
        : "${id}_${user.uid}";
  }

// A method to get a specific conversation between users ;
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessgaes(
      ChatUser user) {
    return firestore
        .collection("chatsMessages/${getConversationID(user.id)}/messages/")
        .orderBy("sent", descending: true)
        .snapshots();
  }

  static Future<void> sendMessgae(
      ChatUser chatUser, String msg, MessageType messageType) async {
    // time when messgae was send
    final sentTime = DateTime.now().millisecondsSinceEpoch.toString();

    // It is the message which is going to send
    final ChatMessage message = ChatMessage(
        fromId: user.uid,
        toId: chatUser.id,
        sent: sentTime,
        read: "",
        type: messageType,
        message: msg);

    // it is the location ,where the chats are going to store
    final ref = firestore.collection(
        "chatsMessages/${getConversationID(chatUser.id)}/messages/");
    await ref.doc(sentTime).set(message.toJson()).then((value) =>
        sendPushNotification(
            chatUser, messageType == MessageType.text ? msg : 'image'));
  }

  static Future<void> updateReadStatus(ChatMessage message) async {
    firestore
        .collection(
            "chatsMessages/${getConversationID(message.fromId)}/messages/")
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Future<void> deleteMessage(ChatMessage message) async {
    firestore
        .collection(
            "chatsMessages/${getConversationID(message.toId)}/messages/")
        .doc(message.sent)
        .delete();
    if (message.type == MessageType.image) {
      storage.refFromURL(message.message).delete();
    }
  }

  static Future<void> updateChatMessage(
      ChatMessage message, String updatedMsg) async {
    firestore
        .collection(
            "chatsMessages/${getConversationID(message.toId)}/messages/")
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    // for getting last message for a specific task ;
    return firestore
        .collection("chatsMessages/${getConversationID(user.id)}/messages/")
        .orderBy("sent", descending: true)
        .limit(1) // limit is used for , how many meaasges you need from doc;
        .snapshots();
  }

  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    // getting file extension
    final extension = file.path.split(".").last;

    // create a referenc in firebase Storage
    final ref = storage.ref().child(
        "images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$extension");

// upload the file in that storage
    await ref.putFile(file);

    // get the url of that file
    final imageURL = await ref.getDownloadURL();

    // update the url in firebase data
    await sendMessgae(chatUser, imageURL, MessageType.image);
  }
}
