import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String text;
  final String sender;
  final Timestamp timestamp;

  Message({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
  });

  factory Message.fromDocument(QueryDocumentSnapshot doc) {
    return Message(
      id: doc.id,
      text: doc['message'],
      sender: doc['sender'],
      timestamp: doc['timestamp'],
    );
  }
}
