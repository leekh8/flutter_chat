// Firestore의 'QueryDocumentSnapshot' 으로부터 'Message' 객체 생성하는 factory constructor

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
    final data = doc.data() as Map<String,
        dynamic>; // 'doc.data()'를 'data' 변수에 저장, 'data' 앱을 사용해 필요한 필드 값 가져옴
    if (data.containsKey('message') &&
        data.containsKey('sender') &&
        data.containsKey('timestamp')) {
      return Message(
        id: doc.id,
        text: doc['message'],
        sender: doc['sender'],
        timestamp: doc['timestamp'],
      );
    } else {
      throw Exception('Missing required fields');
    }
  }
}
