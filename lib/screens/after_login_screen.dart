import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todoapp/core/app_utils.dart';
import '../provider/data_provider.dart';

class AfterLogin extends StatelessWidget {
  final BuildContext ctxForProgressDialog;
  AfterLogin({Key? key, required this.ctxForProgressDialog}) : super(key: key);

  final user = FirebaseAuth.instance.currentUser!;

  CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestore.instance.collection(user.email!);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DataProvider>(
      context,
      listen: false,
    );
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Logged in as:\n${user.displayName}\n${user.email}",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              try {
                AppUtils.showProgressBar(ctxForProgressDialog);
                provider.signOut(context).then(
                      (value) => Navigator.of(ctxForProgressDialog).pop(),
                    );
              } catch (e) {
                print("error: $e");
              }
            },
            child: const Text("Sign Out"),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              try {
                _collection.get().then((querySnapshot) {
                  print("leng: ${querySnapshot.docs.length}");
                  for (var doc in querySnapshot.docs) {
                    print("Doc id: ${doc.id}");
                    print("dfdf: ${doc["taskDesc"]}");
                  }
                });
              } catch (e) {
                print("error: $e");
              }
            },
            child: const Text("Fetch Data"),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              try {
                _collection.add({
                  "taskName": "Test",
                  "taskDesc": "This is a test",
                  "taskTime": DateTime.now().toIso8601String(),
                }).then((querySnapshot) {});
              } catch (e) {
                print("error: $e");
              }
            },
            child: const Text("Add Data"),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              try {
                _collection.doc("L9EZUvETC4wdyhk9dUdW").update({
                  "taskName": "Test1234",
                  "taskDesc": "This is a test1233",
                  "taskTime": DateTime.now().toIso8601String(),
                }).then((querySnapshot) {});
              } catch (e) {
                print("error: $e");
              }
            },
            child: const Text("Update Data"),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              try {
                _collection
                    .doc("gHoKYwAZtJkCSJUb7D8b")
                    .delete()
                    .then((querySnapshot) {});
              } catch (e) {
                print("error: $e");
              }
            },
            child: const Text("Delete Data"),
          ),
        ],
      ),
    );
  }
}
