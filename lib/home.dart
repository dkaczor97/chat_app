import 'package:chat_app/chat.dart';
import 'package:chat_app/data/user.dart';
import 'package:chat_app/login.dart';
import 'package:chat_app/settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum EMenuOptions { settings, logout }

class HomeScreen extends StatefulWidget {
  final User currentUser;

  const HomeScreen({Key key, this.currentUser}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState(currentUser);
}

class _HomeScreenState extends State<HomeScreen> {
  final User currentUser;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  _HomeScreenState(this.currentUser);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chat App",
        ),
        actions: <Widget>[
          PopupMenuButton<EMenuOptions>(
            onSelected: _popupMenuSelected,
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<EMenuOptions>>[
              PopupMenuItem<EMenuOptions>(
                value: EMenuOptions.settings,
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.settings,
                      color: Colors.grey,
                    ),
                    Text("Opcje"),
                  ],
                ),
              ),
              PopupMenuItem<EMenuOptions>(
                value: EMenuOptions.logout,
                child: Row(
                  children: <Widget>[
                    Icon(Icons.exit_to_app, color: Colors.grey),
                    Text("Wyloguj"),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
      body: Container(
        child: StreamBuilder(
          stream: Firestore.instance.collection('users').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: Text("Trwa ładowanie"),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  final user = _userFromDocument(snapshot.data.documents[index]);
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(user.name[0]),
                    ),
                    title: Text(user.name),
                    subtitle: Text(user.about),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                    chattingUser: user,
                                    currentUser: currentUser,
                                  )));
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  void _popupMenuSelected(EMenuOptions option) async {
    switch (option) {
      case EMenuOptions.settings:
        {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                        currentUser: currentUser,
                      )));
          break;
        }
      case EMenuOptions.logout:
        {
          await FirebaseAuth.instance.signOut();
          await googleSignIn.disconnect();
          await googleSignIn.signOut();
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginScreen()));
          break;
        }
      default:
    }
  }

  User _userFromDocument(DocumentSnapshot doc) {
    return User(uid: doc['uid'], name: doc['name'], about: doc['about']);
  }
}
