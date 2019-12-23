import 'package:chat_app/data/user.dart';
import 'package:chat_app/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLogged = false;
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkIfNewUser();
  }

  void _checkIfNewUser() async {
    isLogged = await _googleSignIn.isSignedIn();
    if (isLogged) {
      _logIn();
      //next screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Logowanie"),
        ),
        body: Center(
            child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 50),
              child: Icon(
                Icons.message,
                size: 150,
              ),
            ),
            Text(
              "Chat App",
              style: TextStyle(fontSize: 40),
            ),
            Container(
              margin: EdgeInsets.only(top: 50),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                color: Colors.lightBlue,
                child: Text(
                  "Zaloguj z Google",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                onPressed: _logIn,
              ),
            )
          ],
        )));
  }

  void _logIn() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
    AuthResult authResult = await _auth.signInWithCredential(credential);
    FirebaseUser user = authResult.user;
    User currentUser;
    if (user != null) {
      final snapshot = await Firestore.instance
          .collection('users')
          .where('uid', isEqualTo: user.uid)
          .getDocuments();
      final documents = snapshot.documents;
      if (documents.isEmpty) {
        _createUser(user);
        currentUser = User(uid: user.uid, name: user.displayName, about: "");
      } else {
        currentUser = User(
            uid: user.uid,
            name: documents[0]['name'],
            about: documents[0]['about']);
      }
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(
                    currentUser: currentUser,
                  )));
    } else {}
  }

  void _createUser(FirebaseUser user) {
    Firestore.instance
        .collection('users')
        .document(user.uid)
        .setData({'name': user.displayName, 'uid': user.uid, 'about': ""});
  }
}
