import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo_data.dart';
import '../core/constants.dart';
import '../core/app_utils.dart';
import '../localization/app_strings.dart';
import '../localization/app_strings_en.dart';

class DataProvider with ChangeNotifier {
  AppStrings localization = AppStringsEn();
  final _googleSignIn = GoogleSignIn();
  final List<TodoData> _todosList = [];
  List<TodoData> get todosList => _todosList;

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

  void clearTodoList() {
    _todosList.clear();
    notifyListeners();
  }

  Future<void> fetchTodos(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final collection = FirebaseFirestore.instance.collection(user.email!);
      var querySnapshot = await collection.get().catchError((e) {
        AppUtils.showErrorSnackbar(context: context, message: e.toString());
      });
      _todosList.clear();
      for (var doc in querySnapshot.docs) {
        _todosList.add(
          TodoData(
            docId: doc.id,
            taskName: doc["taskName"],
            taskDesc: doc["taskDesc"],
            taskTime: doc["taskTime"],
            isCompleted:
                doc["taskDone"] == Constants.taskDoneCode ? true : false,
          ),
        );
      }
      notifyListeners();
    } catch (e) {
      AppUtils.showErrorSnackbar(context: context, message: e.toString());
    }
  }

  Future<void> addTodo({
    required BuildContext context,
    required TodoData todoData,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final collection = FirebaseFirestore.instance.collection(user.email!);
      await collection.add({
        "taskName": todoData.taskName,
        "taskDesc": todoData.taskDesc,
        "taskTime": todoData.taskTime,
        "taskDone": Constants.taskNotDoneCode,
      }).catchError((e) {
        AppUtils.showErrorSnackbar(context: context, message: e.toString());
      });
    } catch (e) {
      AppUtils.showErrorSnackbar(context: context, message: e.toString());
    }
  }

  Future<void> updateTodo({
    required BuildContext context,
    required TodoData todoData,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final collection = FirebaseFirestore.instance.collection(user.email!);
      await collection.doc(todoData.docId).update({
        "taskName": todoData.taskName,
        "taskDesc": todoData.taskDesc,
        "taskTime": todoData.taskTime,
        "taskDone": todoData.isCompleted
            ? Constants.taskDoneCode
            : Constants.taskNotDoneCode,
      }).catchError((e) {
        AppUtils.showErrorSnackbar(context: context, message: e.toString());
      });
    } catch (e) {
      AppUtils.showErrorSnackbar(context: context, message: e.toString());
    }
  }

  Future<void> deleteTodo({
    required BuildContext context,
    required String docId,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final collection = FirebaseFirestore.instance.collection(user.email!);
      await collection.doc(docId).delete().catchError((e) {
        AppUtils.showErrorSnackbar(context: context, message: e.toString());
      });
    } catch (e) {
      AppUtils.showErrorSnackbar(context: context, message: e.toString());
    }
  }
}
