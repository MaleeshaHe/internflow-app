import 'package:flutter/material.dart';
import 'package:internflow/models/UserModel.dart';
import 'package:internflow/screens/authentication/authenticate.dart';
import 'package:internflow/screens/home/home.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    //the user data that the provider proides this can be a user data or can be null.
    final user = Provider.of<UserModel?>(context);

    if (user == null) {
      return Authenticate();
    } else {
      return Home();
    }
  }
}
