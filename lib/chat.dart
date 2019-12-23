import 'package:chat_app/data/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final User chattingUser;
  final User currentUser;

  const ChatScreen({Key key, this.chattingUser, this.currentUser})
      : super(key: key);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _inputController = TextEditingController();
  String _groupChatId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    String currentUserId = widget.currentUser.uid;
    String chattingUserId = widget.chattingUser.uid;
    if (currentUserId.hashCode <= chattingUserId.hashCode) {
      _groupChatId = '$currentUserId-$chattingUserId';
    } else {
      _groupChatId = '$chattingUserId-$currentUserId';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: new Text(widget.chattingUser.name),
        ),
        body: Column(
          children: <Widget>[_buildMessages(), _buildInput()],
        ));
  }

  Widget _buildInput() {
    return Row(
      children: <Widget>[
        Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: TextField(
              controller: _inputController,
            ),
          ),
        ),
        Material(
            child: Container(
          child: IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              _sendMessage(_inputController.text);
            },
          ),
        ))
      ],
    );
  }

  void _sendMessage(String content) {
    if (content.trim() != '') {
      _inputController.clear();
      var doc = Firestore.instance
          .collection('messages')
          .document(_groupChatId)
          .collection(_groupChatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(doc, {
          'idFrom': widget.currentUser.uid,
          'idTo': widget.chattingUser.uid,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'content': content
        });
      });
    }
  }

  Widget _buildMessages() {
    return Flexible(
      child: StreamBuilder(
        stream: Firestore.instance
            .collection('messages')
            .document(_groupChatId)
            .collection(_groupChatId)
            .orderBy('timestamp', descending: true)
            .limit(20)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemCount: snapshot.data.documents.length,
              reverse: true,
              itemBuilder: (context, index) {
                var doc = snapshot.data.documents[index];
                if (doc['idFrom'] == widget.currentUser.uid) {
                  return Row(
                    children: <Widget>[
                      Container(
                        child: Text(
                          doc['content'],
                          style: TextStyle(color: Colors.white),
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        width: 200.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: Colors.blue),
                        margin: EdgeInsets.only(bottom: 10.0, right: 10.0),
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.end,
                  );
                } else {
                  return Container(
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              child: Text(
                                doc['content'],
                              ),
                              padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                              width: 200.0,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: Colors.grey[350]),
                              margin: EdgeInsets.only(left: 10.0),
                            )
                          ],
                        )
                      ],
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                    margin: EdgeInsets.only(bottom: 10.0),
                  );
                }
              },
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
