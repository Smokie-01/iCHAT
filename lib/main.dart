import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_notification_channel/notification_visibility.dart';
import 'package:ichat/screens/Profile_Screen.dart';
import 'package:ichat/screens/Splash_Screen.dart';
import 'package:ichat/screens/auth/loginScreen.dart';
import 'firebase_options.dart';
import 'screens/Home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';

//global object to acceses diffrent size of devices

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
// to hide the statusBar and Navigation Bar , in the app
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // to set a fix orientation of device , reegardless of the positions
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) async {
    await _initializeFirebase();
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      routes: {
        HomeScreen.namedRoute: (context) => HomeScreen(),
        LogInScreen.namedRoute: (context) => LogInScreen(),
        ProfileScreen.namedRoute: (context) => ProfileScreen(),
      },
      home: SplashScreen(),
    );
  }
}

_initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FlutterNotificationChannel.registerNotificationChannel(
    description: 'For Message Notification',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'chats',
    visibility: NotificationVisibility.VISIBILITY_PUBLIC,
  );
}
