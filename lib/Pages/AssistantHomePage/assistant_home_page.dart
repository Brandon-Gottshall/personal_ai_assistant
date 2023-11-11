// lib/assistant_home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:my_ai_assistant/models/services/logger.dart';
import '../../models/data/message.dart';
import '../../models/services/open_ai_agent.dart';

class AssistantHomePage extends StatefulWidget {
  const AssistantHomePage({Key? key}) : super(key: key);

  @override
  State<AssistantHomePage> createState() => _AssistantHomePageState();
}

class _AssistantHomePageState extends State<AssistantHomePage> {
  final List<Message> messages = [];
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  late final OpenAIAgent openAIAgent;

  @override
  void initState() {
    super.initState();
    openAIAgent = OpenAIAgent.instance; // Use singleton instance
    _listenToMessages();
    _initAgent();
  }

  void _initAgent() async {
    await openAIAgent.initialize(); // Initialize the OpenAIAgent
  }

  void _listenToMessages() {
    openAIAgent.messagesStream.listen(
      (newMessages) {
        LoggerService().log('Received new messages: $newMessages');

        // If there is only one message, insert it at the beginning of the list.
        if (newMessages.length == 1) {
          setState(() {
            messages.insert(0, newMessages[0]);
          });
        } else {
        setState(() {
          messages.addAll(newMessages);
        });
        _scrollToBottom();
        }
      },
      onError: (error) {
        LoggerService().log('Error occurred while listening to messages: $error');
      },
    );
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

void _sendMessage() async {
  final userMessage = messageController.text.trim();
  if (userMessage.isNotEmpty) {
    LoggerService().log('Sending message: $userMessage');
    messageController.clear();
    _scrollToBottom();

    try {
      await openAIAgent.addMessageToThread(userMessage);
      await openAIAgent.createRun(); // Start a new run if required
    } catch (e) {
      LoggerService().log('Error sending message to OpenAI agent: $e');
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(30),
        child: AppBar(
          title: Container(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [ 
                const Text('Personal Assistant'),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => {}, // Add settings page navigation
                ),
],)
          ),
        ),
      ),
      body: Container(
        color: Colors.black87,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                controller: scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return Align(
                    alignment: message.isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: message.isUserMessage ? Colors.blue : Colors.white70,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: MarkdownBody(
                        data: message.text
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 30),
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy < -5) {
                    _showHistoryDrawer();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                      hintText: 'Type a message',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        color: Colors.blueGrey,
                        onPressed: _sendMessage,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHistoryDrawer() {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext bc) {
      return Wrap(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Chatbot Conversation History'),
            onTap: () => {}, // Your history handling logic
          ),
          const Divider(),
          // Example conversation history items with a chatbot
          ListTile(
            leading: const Icon(Icons.question_answer),
            title: const Text('Yesterday: Weather Inquiry'),
            subtitle: const Text('Chatbot: Tomorrow will be sunny.'),
            onTap: () => {}, // Your onTap logic for this item
          ),
          ListTile(
            leading: const Icon(Icons.question_answer),
            title: const Text('Last Week: Recipe Suggestions'),
            subtitle: const Text('Chatbot: Here\'s a recipe for spaghetti.'),
            onTap: () => {}, // Your onTap logic for this item
          ),
          ListTile(
            leading: const Icon(Icons.question_answer),
            title: const Text('Monday: Tech News Update'),
            subtitle: const Text('Chatbot: Latest smartphone release...'),
            onTap: () => {}, // Your onTap logic for this item
          ),
          // Add more stubbed history items as needed
        ],
      );
    }
  );
}




  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    openAIAgent.dispose(); // Dispose the OpenAIAgent resources
    super.dispose();
  }
}
