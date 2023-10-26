import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat/services/auth_service.dart';
import 'signIn_screen.dart';

class ChatScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  void _signOut(BuildContext context) async {
    await _authService.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        actions: [
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => _signOut(context),
              ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final messages = snapshot.data?.docs ?? [];

          List<Widget> messageWidgets = [];
          for (var message in messages) {
            final messageText = message['message'];
            final messageSender = message['sender'];
            final messageWidget = MessageWidget(messageSender, messageText);
            messageWidgets.add(messageWidget);
          }
          return ListView(
            reverse: true,
            children: messageWidgets,
          );
        },
      ),
    );
  }
}

class MessageWidget extends StatelessWidget {
  final String sender;
  final String text;

  MessageWidget(this.sender, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(sender),
          Text(text),
        ],
      ),
    );
  }
}
