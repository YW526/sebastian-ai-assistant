import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:sebastian_app/services/chat_service.dart';

const String _kUserId = 'user1';
const String _kAssistantId = 'assistant';

/// 홈 화면 채팅: 로컬 Nest `GET/POST /chat/messages` + [ChatService].
class TC extends StatefulWidget {
  const TC({super.key});

  @override
  State<TC> createState() => _TCState();
}

class _TCState extends State<TC> {
  final _chatController = InMemoryChatController();
  final _chatService = ChatService();
  bool _loading = true;
  String? _error;
  bool _sending = false;

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await _chatService.fetchMessages();
      for (final row in rows) {
        await _chatController.insertMessage(_mapToTextMessage(row));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  TextMessage _mapToTextMessage(Map<String, dynamic> m) {
    final raw = m['createdAt'];
    DateTime created;
    if (raw is String) {
      created = DateTime.parse(raw);
    } else {
      created = DateTime.now().toUtc();
    }
    if (!created.isUtc) {
      created = created.toUtc();
    }
    final role = m['senderRole'] as String? ?? 'user';
    return TextMessage(
      id: 'm_${m['id']}',
      authorId: role == 'user' ? _kUserId : _kAssistantId,
      createdAt: created,
      text: m['message'] as String? ?? '',
    );
  }

  void _onMessageSend(String text) {
    _sendToServer(text);
  }

  Future<void> _sendToServer(String text) async {
    if (_sending) return;
    setState(() => _sending = true);
    try {
      final data = await _chatService.sendMessage(text);
      final um = data['userMessage'];
      final am = data['assistantMessage'];
      if (um is Map) {
        await _chatController.insertMessage(
          _mapToTextMessage(Map<String, dynamic>.from(um)),
        );
      }
      if (am is Map) {
        await _chatController.insertMessage(
          _mapToTextMessage(Map<String, dynamic>.from(am)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _loadHistory,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    return Chat(
      chatController: _chatController,
      currentUserId: _kUserId,
      onMessageSend: _onMessageSend,
      resolveUser: (UserID id) async {
        if (id == _kUserId) {
          return User(id: id, name: '나');
        }
        return User(id: id, name: '세바스찬');
      },
    );
  }
}
