import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ichat/screens/Profile_Screen.dart';
import 'package:ichat/screens/Splash_Screen.dart';
import 'package:ichat/screens/auth/loginScreen.dart';
import 'firebase_options.dart';
import 'screens/Home_screen.dart';
import 'package:firebase_core/firebase_core.dart';

//global object to acceses diffrent size of devices

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
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
