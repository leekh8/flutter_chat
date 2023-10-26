import 'package:flutter/material.dart';
import 'package:flutter_chat/services/chat_service.dart';

class ChatScreen extends StatelessWidget{
final ChatService _chatService = ChatService();

void _sendMessage(String message){
  _chatService.sendMessage(message, 'user_id');
}
  @override
  Widget build(BuildContext context){return Scaffold()}
}