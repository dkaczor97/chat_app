import 'package:chat_app/data/user.dart';
import 'package:chat_app/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final User currentUser;

  const SettingsScreen({Key key, this.currentUser}) : super(key: key);
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameFieldController = TextEditingController();
  final _aboutFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameFieldController.text = widget.currentUser.name;
    _aboutFieldController.text = widget.currentUser.about;
  }

  _SettingsScreenState();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Opcje"),
        ),
        body: Container(
          padding: EdgeInsets.fromLTRB(16.0, 30.0, 16.0, 16.0),
          child: Column(
            children: <Widget>[
              TextField(
                maxLines: 1,
                decoration: InputDecoration(
                    labelText: 'Nazwa', hasFloatingPlaceholder: true),
                controller: _nameFieldController,
              ),
              TextField(
                minLines: 2,
                maxLines: 5,
                decoration: InputDecoration(
                    labelText: 'Opis', hasFloatingPlaceholder: true),
                controller: _aboutFieldController,
              ),
              RaisedButton(
                child: Text("Zapisz"),
                onPressed: () {
                  _save();
                },
              )
            ],
          ),
        ));
  }

  void _save() {
    Firestore.instance
        .collection('users')
        .document(widget.currentUser.uid)
        .setData({
      'name': _nameFieldController.text,
      'about': _aboutFieldController.text,
      'uid': widget.currentUser.uid
    });
    widget.currentUser.name = _nameFieldController.text;
    widget.currentUser.about = _aboutFieldController.text;

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen(
                  currentUser: widget.currentUser,
                )));
  }
}
