import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todoapp/screens/login_screen.dart';

class AfterLogin extends StatelessWidget {
  AfterLogin({Key? key}) : super(key: key);

  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Logged in as:\n${user.email}",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                try {
                  FirebaseAuth.instance.signOut().then((value) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (ctx) => const LoginScreen(),
                      ),
                    );
                  }).catchError((e) {
                    print("signoutError: $e");
                  });
                } catch (e) {
                  print("error: $e");
                }
              },
              child: const Text("Sign Out"),
            ),
          ],
        ),
      ),
    );
  }
}
