import 'package:flutter/material.dart';
import 'package:ichat/Api/Api.dart';
import 'package:ichat/screens/Home_screen.dart';
import 'package:ichat/screens/auth/loginScreen.dart';

import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const namedRoute = "LoginScreen";

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // this future delayed is used for splash screen
    Future.delayed(Duration(seconds: 2), () {
      //current user is firebase Auth instance
      var loggedInUser = APIs.auth.currentUser;

      // This If-else Is to check weather weather user is already logged in or not
      if (loggedInUser != null) {
        Navigator.of(context).pushReplacementNamed(HomeScreen.namedRoute);
      } else {
        Navigator.of(context).pushReplacementNamed(LogInScreen.namedRoute);
      }
    });
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
          Positioned(
              width: mq.width * .4,
              top: mq.height * .15,
              right: mq.width * .30,
              child: Image.asset("images/chat.png")),

          Positioned(
              left: mq.width * .25,
              bottom: mq.height * .08,
              // width: mq.width * .9,
              height: mq.height * .07,
              child: Text(
                "Hello iChat here",
                style: TextStyle(fontSize: 30),
              ))
        ],
      ),
    );
  }
}
