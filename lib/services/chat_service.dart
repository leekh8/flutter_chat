import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase cloud Firestore 사용



class ChatService {
  final CollectionReference chatCollection =
      FirebaseFirestore.instance.collection('chats');

  Future sendMessage(String message, String userId) async {
    // 메시지 문자열과 사용자 id를 받아 firebase의 'chat' 컬랙션에 새 문서 추가
    // timestamp를 사용해 메시지가 언제 보내졌는지 기록
    return await chatCollection.add({
      'message': message,
      'sender': userId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
