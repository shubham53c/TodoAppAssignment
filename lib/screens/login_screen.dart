import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todoapp/provider/data_provider.dart';
import './after_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    try {
      FirebaseAuth.instance.authStateChanges().listen((event) {
        if (event != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (ctx) => AfterLogin(),
            ),
          );
        } else {
          print("errew: something went wrong");
        }
      });
    } catch (e) {
      print("errew: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                try {
                  FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: "testuser100@firebase.com",
                          password: "testuser100")
                      .catchError((e) {
                    print("errew: $e");
                  });
                } catch (e) {
                  print("ee: $e");
                }
              },
              child: const Text("Sign In"),
            ),
            ElevatedButton(
              onPressed: () {
                try {
                  final provider = Provider.of<DataProvider>(
                    context,
                    listen: false,
                  );
                  provider.googleLogin();
                } catch (e) {
                  print("ee: $e");
                }
              },
              child: const Text("Google Sign In"),
            ),
          ],
        ),
      ),
    );
  }
}
