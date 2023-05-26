import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ichat/Api/Api.dart';
import 'package:ichat/Helper/Snackbar.dart';
import 'package:ichat/screens/Home_screen.dart';

import '../../main.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});
  static const namedRoute = "LoginScreen";

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  bool _isAnimate = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  _handleGooglelogin() {
    // it shows the custom progress indicator
    CustomDialog.showProgressIndicator(context);

    _signInWithGoogle().then((user) async {
      Navigator.pop(context);

      if (user != null) {
        if (await APIs.userExisit()) {
          Navigator.pushReplacementNamed(context, HomeScreen.namedRoute);
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacementNamed(context, LogInScreen.namedRoute);
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup("google.com");
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      print(e);
      CustomDialog.snackbar(
          context, "Something went wrong (Check your internet connection)");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // initializing media query to acceses diffrent screen
    final mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(" Welcome to iChat"),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          //app logo
          AnimatedPositioned(
              duration: Duration(seconds: 1),
              width: mq.width * .4,
              top: mq.height * .15,
              right: _isAnimate ? mq.width * .30 : -mq.width * .5,
              child: Image.asset("images/chat.png")),
          // Logo go google login
          Positioned(
              bottom: mq.height * .15,
              left: mq.width * .05,
              width: mq.width * .9,
              height: mq.height * .07,
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(), backgroundColor: Colors.black),
                  onPressed: _handleGooglelogin,
                  icon: Image.asset(
                    "images/google.png",
                    height: mq.height * .05,
                  ),
                  label: Text(
                    "Sign In With Google",
                    style: TextStyle(fontSize: 19),
                  )))
        ],
      ),
      //FLoating action button to add new user
    );
  }
}
