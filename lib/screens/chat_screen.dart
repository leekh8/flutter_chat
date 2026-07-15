import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat/services/auth_service.dart';
import 'package:flutter_chat/services/chat_service.dart';
import 'signIn_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final AuthService _authService = AuthService();
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();
  // 엔터로 보낸 뒤에도 입력창에 커서가 남아 연속 입력이 가능하도록 포커스를 직접 관리한다.
  final FocusNode _inputFocus = FocusNode();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    final uid = _uid; // 로컬로 받아 null 승격 (구버전 Dart의 필드 승격 미지원 대비)
    if (text.isEmpty || uid == null || _sending) return;

    setState(() => _sending = true);
    try {
      await _chatService.sendMessage(text, uid);
      _controller.clear(); // 전송 성공 후에만 비운다 — 실패 시 입력한 글이 사라지지 않도록
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('전송 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
      _inputFocus.requestFocus(); // 전송 후 커서를 입력창에 되돌려 연속 입력 가능
    }
  }

  void _signOut() async {
    await _authService.signOut();
    if (!mounted) return; // State.mounted가 State.context 사용을 올바르게 가드
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                // 보안 규칙 거부·네트워크 오류를 무한 로딩으로 감추지 않는다
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('메시지를 불러오지 못했습니다.\n${snapshot.error}',
                          textAlign: TextAlign.center),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data?.docs ?? [];
                if (messages.isEmpty) {
                  return const Center(child: Text('첫 메시지를 보내보세요 👋'));
                }
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;
                    return MessageBubble(
                      sender: (data['sender'] ?? '').toString(),
                      text: (data['message'] ?? '').toString(),
                      isMine: data['sender'] == _uid,
                      // serverTimestamp는 서버 반영 전 잠시 null — 그때는 시간을 숨긴다
                      sentAt: (data['timestamp'] as Timestamp?)?.toDate(),
                    );
                  },
                );
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _inputFocus,
                autofocus: true, // 화면 진입 시 바로 입력 가능
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(), // 엔터 전송 후 _send가 포커스를 되돌린다
                decoration: const InputDecoration(
                  hintText: '메시지 입력...',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: _sending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              onPressed: _sending ? null : _send, // 중복 전송 방지
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMine;
  final DateTime? sentAt;

  const MessageBubble({
    super.key,
    required this.sender,
    required this.text,
    required this.isMine,
    this.sentAt,
  });

  /// HH:MM (24시간). 서버 반영 전이면 빈 문자열.
  String get _time {
    final t = sentAt;
    if (t == null) return '';
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = isMine
        ? '나'
        : (sender.length > 6 ? sender.substring(0, 6) : sender);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            _time.isEmpty ? label : '$label · $_time',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isMine
                  ? theme.colorScheme.primaryContainer
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText(text), // 메시지 복사 가능
          ),
        ],
      ),
    );
  }
}
