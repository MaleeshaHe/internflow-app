import 'package:flutter/material.dart';
import 'package:internflow/services/auth.dart';

class SignIn extends StatefulWidget {
  final Function toggle;
  const SignIn({Key? key, required this.toggle}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthServices _auth = AuthServices();

  //from key
  final _formKey = GlobalKey<FormState>();
  //email password states
  String email = "";
  String password = "";
  String error = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Sign In Screen',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (val) =>
                          val!.isEmpty ? 'Enter an email' : null,
                      onChanged: (val) {
                        setState(() => email = val);
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (val) => val!.length < 6
                          ? 'Enter a password 6+ chars long'
                          : null,
                      onChanged: (val) {
                        setState(() => password = val);
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          dynamic result = await _auth
                              .signInUsingEmailAndPassword(email, password);
                          if (result == null) {
                            setState(() => error = 'Error signing in');
                          } else {
                            setState(
                                () => error = 'Signed in as ${result.uid}');
                          }
                        }
                      },
                      child: const Text('Sign In'),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      error,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Sign in as an anonymous user
            ElevatedButton(
              onPressed: () async {
                dynamic result = await _auth.signInAnonymously();
                if (result == null) {
                  setState(() => error = 'Error signing in');
                } else {
                  setState(() => error = 'Signed in as ${result.uid}');
                }
              },
              child: const Text('Sign in Anonymously'),
            ),
            const SizedBox(height: 20),
            // Toggle to register page
            ElevatedButton(
              onPressed: () {
                widget.toggle();
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
