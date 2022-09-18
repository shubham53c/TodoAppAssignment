import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import './after_login_screen.dart';
import './sign_in_screen.dart';
import '../core/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.accentColor,
              ),
            );
          } else if (snapshot.hasData) {
            return AfterLogin(
              ctxForProgressDialog: context,
            );
          } else {
            return SignInScreen(
              ctxForProgressDialog: context,
            );
          }
        },
      ),
    );
  }
}
