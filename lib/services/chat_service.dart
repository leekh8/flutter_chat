import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat/models/message.dart';

class ChatService {
  final CollectionReference chatCollection =
  FirebaseFirestore.instance.collection('chats');

  Future<void> sendMessage(String message, String userId) async {
    return chatCollection.add({
      'message': message,
      'sender': userId,
      'timestamp': Timestamp.now(),
    });
  }

  Stream<List<Message>> get messages {
    return chatCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Message.fromDocument(doc);
      }
      ).toList();
    }
        }
