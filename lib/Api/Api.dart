import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:ichat/Model/chat_messages.dart';

import 'package:ichat/Model/chat_user.dart';

class APIs {
  // For Authentication
  static FirebaseAuth auth = FirebaseAuth.instance;
// For accesing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // For accesing the firebase Storage to store user generated data
  static FirebaseStorage storage = FirebaseStorage.instance;

  static GoogleSignIn googleSignIn = GoogleSignIn();
  //its getter to get auth current users

  // A variable for storing self information
  static late ChatUser me;

  // this will return the current user
  static User get user {
    return auth.currentUser!;
  }

  static Future<void> getSlefInfo() async {
    // get the users info for creating new user
    firestore.collection("users").doc(user.uid).get().then((user) {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
      } else {
        createUser().then((value) => {getSlefInfo()});
      }
    });
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

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser() {
    // a method to get all user from firebase to ui
    return firestore
        .collection("users")
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static Future<void> updateUserInfo() async {
    // function to update user personal info
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
        .snapshots();
  }

  static Future<void> sendMessgae(ChatUser chatUser, String msg) async {
    print(msg);
    // time when messgae was send
    final sentTime = DateTime.now().millisecondsSinceEpoch.toString();

    // It is the message which is going to send
    final ChatMessage message = ChatMessage(
        fromId: user.uid,
        toId: chatUser.id,
        sent: sentTime,
        read: "",
        type: MessageType.text,
        message: msg);

    // it is the location ,where the chats are going to store
    final ref = firestore.collection(
        "chatsMessages/${getConversationID(chatUser.id)}/messages/");
    await ref.doc(sentTime).set(message.toJson());
  }

  // String getConversationID(String id) {
  //   return user.uid.hashCode <= id.hashCode
  //       ? '${user.uid}_${id}'
  //       : "${id}_${user.uid}";
  // }

}
