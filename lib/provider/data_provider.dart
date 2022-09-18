import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../core/app_utils.dart';
import '../localization/app_strings.dart';
import '../localization/app_strings_en.dart';

class DataProvider with ChangeNotifier {
  AppStrings localization = AppStringsEn();
  final _googleSignIn = GoogleSignIn();

  Future<void> loginWithEmailAndPassword({
    required BuildContext context,
    required String userEmail,
    required String userPassword,
  }) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: userEmail,
        password: userPassword,
      )
          .catchError((e) {
        AppUtils.showErrorSnackbar(context: context, message: e.toString());
      });
    } catch (e) {
      AppUtils.showErrorSnackbar(context: context, message: e.toString());
    }
  }

  Future<void> googleLogin(BuildContext context) async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(Constants.googleSignInPrefsKey, true);
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance
          .signInWithCredential(credential)
          .catchError((e) {
        AppUtils.showErrorSnackbar(context: context, message: e.toString());
      });
    } catch (e) {
      AppUtils.showErrorSnackbar(context: context, message: e.toString());
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final googleSignedIn =
          prefs.getBool(Constants.googleSignInPrefsKey) ?? false;
      if (googleSignedIn) {
        await _googleSignIn.disconnect().catchError((e) {
          AppUtils.showErrorSnackbar(context: context, message: e.toString());
        });
        prefs.remove(Constants.googleSignInPrefsKey);
      }
      await FirebaseAuth.instance.signOut().catchError((e) {
        AppUtils.showErrorSnackbar(context: context, message: e.toString());
      });
    } catch (e) {
      AppUtils.showErrorSnackbar(context: context, message: e.toString());
    }
  }
}
