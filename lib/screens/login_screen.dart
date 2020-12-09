import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lets_chat/constants.dart';
import 'package:lets_chat/screens/chat_screen.dart';
import 'package:lets_chat/components/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var data;
  String file;
  String userName;
  String password;

  bool spinner = false;

  final _auth = FirebaseAuth.instance;

  final formKey = GlobalKey<FormState>();

  bool validateAndSave() {
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  /*
  Future<String> loadAsset() async {
    String a = await rootBundle.loadString('assets/data.txt');
    file = a;
    return a;
  }

  bool validation() {
    List<String> first = [];

    int i = 0;
    first = file.split('\n');
    while (i < first.length - 1) {
      List<String> second = first[i].split(',');

      i++;

      if (userName == second[0]) {
        if (password == second[1]) {
          return true;
        }
      }
    }
  }

   */

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: spinner,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: Form(
              key: formKey,
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
                  TextFormField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        value.isEmpty ? 'Email can\'t be empty' : null,
                    decoration: KTextFielInputDecor,
                    onSaved: (value) => userName = value,
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextFormField(
                    textAlign: TextAlign.center,
                    obscureText: true,
                    validator: (value) =>
                        value.isEmpty ? 'Password can\'t be empty' : null,
                    decoration: KTextFielInputDecor.copyWith(
                        hintText: 'Enter your Password'),
                    onSaved: (value) => password = value,
                  ),
                  SizedBox(
                    height: 40.0,
                  ),
                  RoundedButton(
                    title: 'LOGIN',
                    color: Colors.lightBlueAccent,
                    onPressed: () async {
                      if (validateAndSave()) {
                        try {
                          final user = await _auth.signInWithEmailAndPassword(
                              email: userName, password: password);

                          if (user != null) {
                            Navigator.pushNamed(context, ChatScreen.id);
                          }
                          setState(() {
                            spinner = false;
                          });
                        } catch (e) {
                          print(e);
                        }

                        Navigator.pushNamed(context, ChatScreen.id);
                      } else {
                        print('Validation Faled.');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
