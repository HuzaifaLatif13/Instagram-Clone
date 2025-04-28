import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_insta/screens/auth/login_screen.dart';
import 'package:my_insta/widgets/image_asset.dart';

import 'home/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), checkUserLogin);
  }

  void checkUserLogin() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is logged in, navigate to HomeScreen
      Get.offAll(() => MainScreen());
    } else {
      // No user is logged in, navigate to LoginScreen
      Get.offAll(() => const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ImageAsset(imagePath: 'assets/images/app_logo.png'),
            const SizedBox(height: 10),
            ImageAsset(imagePath: 'assets/images/app_title.png'),
          ],
        ),
      ),
    );
  }
}
