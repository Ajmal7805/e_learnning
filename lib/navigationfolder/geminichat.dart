import 'dart:developer';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class Geminichat extends StatefulWidget {
  const Geminichat({super.key});

  @override
  State<Geminichat> createState() => _GeminichatState();
}

class _GeminichatState extends State<Geminichat> {
  final Gemini gemini = Gemini.instance;

  List<ChatMessage> messages = [];

  final ChatUser currentUser = ChatUser(id: '0', firstName: 'User');

  final ChatUser geminiUser = ChatUser(
    id: '1',
    firstName: 'Gemini',
    profileImage:
        "https://seeklogo.com/images/G/google-gemini-logo-A5787B2669-seeklogo.com.png",
  );

  bool _isTyping = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini Chat'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: _buildChatUI(),
    );
  }

  Widget _buildChatUI() {
    return DashChat(
      currentUser: currentUser,
      onSend: _handleSendMessage,
      messages: messages,
      typingUsers: _isTyping ? [geminiUser] : [],
      messageOptions: const MessageOptions(
        currentUserContainerColor: Color(0xFF2B3A67),
        containerColor: Color(0xFF3F5AA6),
        textColor: Colors.white,
      ),
    );
  }

  void _handleSendMessage(ChatMessage userMessage) {
    setState(() {
      messages.insert(0, userMessage);
      _isTyping = true;
    });

    try {
      final String question = userMessage.text;

      final List<Content> history = messages
          .skip(1) // Skip the just-sent user message
          .map((m) => Content(
                role: m.user.id == geminiUser.id ? 'model' : 'user',
                parts: [Parts(text: m.text)],
              ))
          .toList()
          .reversed
          .toList();

      String fullResponse = "";

      // ignore: deprecated_member_use
      gemini.streamGenerateContent(question,).listen(
        (event) {
          final responsePart = event.content?.parts
                  ?.map((p) => p) // Use the correct property for text content
                  .join() ??
              "";

          fullResponse += responsePart;

          final ChatMessage aiMessage = ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: fullResponse,
          );

          setState(() {
            if (messages.isNotEmpty && messages.first.user.id == geminiUser.id) {
              messages[0] = aiMessage;
            } else {
              messages.insert(0, aiMessage);
            }
          });
        },
        onDone: () {
          setState(() {
            _isTyping = false;
          });
          log("Gemini stream completed");
        },
        onError: (error) {
          setState(() {
            _isTyping = false;
            messages.insert(
              0,
              ChatMessage(
                user: geminiUser,
                createdAt: DateTime.now(),
                text: "Sorry, an error occurred. Please try again.",
              ),
            );
          });
          log("Gemini stream error: $error");
        },
      );
    } catch (e) {
      log("Exception in _handleSendMessage: $e");
      setState(() {
        _isTyping = false;
      });
    }
  }
}
