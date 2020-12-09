import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lets_chat/components/rounded_button.dart';
import 'package:lets_chat/constants.dart';
import 'chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String email;
  String password;
  String passLen = 'Password must be 6 characters long';
  String minLen =
      'Password is less than 6 characters. It must be 6 or more than 6 characters long.';

  bool spinner = false;

  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: spinner,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: Hero(
                    tag: 'logo',
                    child: Container(
                      child: Image.asset('images/logo.png'),
                      height: 200.0,
                    ),
                  ),
                ),
                SizedBox(
                  height: 40.0,
                ),
                TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    email = value;
                  },
                  decoration: KTextFielInputDecor,
                ),
                SizedBox(
                  height: 8.0,
                ),
                TextField(
                  textAlign: TextAlign.center,
                  obscureText: true,
                  onChanged: (value) {
                    if (value.length >= 5) {
                      password = value;
                    } else {
                      passLen = minLen;
                    }
                  },
                  decoration: KTextFielInputDecor.copyWith(
                      hintText: 'Enter your Password'),
                ),
                SizedBox(
                  height: 8.0,
                ),
                Text(
                  passLen,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.right,
                ),
                Padding(
                  padding: EdgeInsets.all(50.0),
                  child: RoundedButton(
                    title: 'REGISTER',
                    color: Colors.lightBlueAccent,
                    onPressed: () async {
                      setState(() {
                        spinner = true;
                      });
                      try {
                        final newUser =
                            await _auth.createUserWithEmailAndPassword(
                                email: email, password: password);

                        if (newUser != null) {
                          spinner = false;

                          Navigator.pushNamed(context, ChatScreen.id);
                        } else {
                          spinner = false;
                        }

                        spinner = false;
                      } catch (e) {
                        print(e);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
