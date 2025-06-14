import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:internflow/models/UserModel.dart';
import 'package:internflow/services/auth.dart';
import 'package:internflow/wrapper.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserModel?>.value(
      initialData: UserModel(uid: ""),
      value: AuthServices().user,
      child: MaterialApp(
        title: 'InternFlow',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.cyan,
            accentColor: Colors.cyanAccent,
          ).copyWith(secondary: Colors.cyanAccent, primary: Colors.cyan),
        ),
        debugShowCheckedModeBanner: false,
        home: Wrapper(),
      ),
    );
  }
}
