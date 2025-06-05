import 'package:flutter/material.dart';
import 'package:internflow/screens/authentication/authenticate.dart';
import 'package:internflow/screens/home/home.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Authenticate(),
    );
  }
}
