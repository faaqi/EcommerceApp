import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lets_chat/constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

final _firestore = FirebaseFirestore.instance;
User currUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final msgTextController = TextEditingController();

  final _auth = FirebaseAuth.instance;

  bool spinner = false;
  String msg;

  Future<User> getCurrUSer() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        currUser = user;
        print(currUser.email);
      }
      return user;
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();

    getCurrUSer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('⚡Chat'),
        leading: null,
        backgroundColor: Colors.lightBlueAccent,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.close,
            ),
            onPressed: () async {
              setState(() {
                spinner = true;
              });
              await _auth.signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: false,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              MsgStreamBuild(),
              Container(
                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: msgTextController,
                        onChanged: (value) {
                          msg = value;
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    FlatButton(
                      child: Text(
                        'Send',
                        style: kSendButtonTextStyle,
                      ),
                      onPressed: () {
                        msgTextController.clear();

                        String time = DateTime.now().toString();

                        _firestore.collection('messages').add({
                          'Text': msg,
                          'Sender': currUser.email,
                          'Time': time
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MsgStreamBuild extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final messages = snapshot.data.docs.reversed;
        List<MessageBubble> msgWidgets = [];
        for (var msg in messages) {
          final text = msg.data()['Text'];
          final sender = msg.data()['Sender'];
          final time = msg.data()['Time'];
          final isMe = currUser.email;

          //  String formattedTime =DateFormat.jm().format(DateTime.parse(time));
          // print(formattedTime);

          final msgText = MessageBubble(
            text: text,
            sender: sender,
            isMe: isMe == sender,
            time: time,
          );
          msgWidgets.add(msgText);
          msgWidgets.sort((a, b) =>
              DateTime.parse(b.time).compareTo(DateTime.parse(a.time)));
        }

        return Expanded(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: ListView(
              reverse: true,
              children: msgWidgets,
            ),
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.text, this.sender, this.isMe, this.time});
  final String text;
  final String sender;
  final bool isMe;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text('$sender'),
          SizedBox(
            height: 5.0,
          ),
          Material(
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))
                : BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0)),
            color: isMe ? Colors.lightBlueAccent : Colors.deepOrangeAccent,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                '$text',
                style: TextStyle(fontSize: 15.0, color: Colors.white),
              ),
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Text('$time'),
        ],
      ),
    );
  }
}
