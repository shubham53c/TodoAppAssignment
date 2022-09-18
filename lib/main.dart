import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todoapp/screens/sign_in_screen.dart';
import './core/constants.dart';
import './provider/data_provider.dart';
import './screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: DataProvider(),
      child: const MaterialApp(
        title: Constants.appName,
        home: SignInScreen(),
      ),
    );
  }
}
