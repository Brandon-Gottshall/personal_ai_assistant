// lib/models/services/open_ai_agent.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database.dart';
import 'dart:async';
import '../data/message.dart';

// Singleton class to manage interactions with OpenAI API.
class OpenAIAgent {
  // Singleton instance.
  static final OpenAIAgent _instance = OpenAIAgent._internal();

  // Singleton instance getter.
  static OpenAIAgent get instance => _instance;

  // Database service.
  final databaseService = DatabaseService();

  // Thread and run identifiers.
  String _currentThreadId = '';
  String _currentRunId = '';

  // API key for OpenAI.
  final String apiKey = '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';

  // Timer for periodically checking the run status.
  Timer? _timer;

  // Stream controller to manage message broadcasting.
  final StreamController<List<Message>> _messagesController = StreamController<List<Message>>.broadcast();

  // Stream getter.
  Stream<List<Message>> get messagesStream => _messagesController.stream;


  // Constructor for singleton pattern.
  factory OpenAIAgent() {
    return _instance;
  }

  OpenAIAgent._internal();

  // Connects to the database and initializes the agent.
  Future<void> connectToDatabase() async {
    LoggerService().log('Connecting to database...');
    await databaseService.connect(
      databaseName: 'my_ai_assistant',
      username: 'postgres',
      password: 'password',
    );
    LoggerService().log('Connected to database successfully.');
  }

  // Initializes the agent by loading saved thread and run IDs.
  Future<void> initialize() async {
    LoggerService().log('Initializing OpenAIAgent...');
    final prefs = await SharedPreferences.getInstance();
    _currentThreadId = prefs.getString('threadId') ?? '';
    _currentRunId = prefs.getString('currentRunId') ?? '';

    // Create a new thread if none exists.
    if (_currentThreadId.isEmpty) {
      LoggerService().log('No existing thread found. Creating a new thread...');
      _currentThreadId = await createThread();
      await prefs.setString('currentThreadId', _currentThreadId);
      LoggerService().log('New thread created with ID: $_currentThreadId');
      // Add new thread ID to database.
      await databaseService.insertThreadID(_currentThreadId);
    } else {
      LoggerService().log('Existing thread found with ID: $_currentThreadId');
      // Retrieve and update messages upon initialization.
      final messages = await getMessages();
      _updateMessages(messages, initialUpdate: true);
    }
  }

  // Updates the messages stream with the provided messages.
  void _updateMessages(List<Message> messages, {bool initialUpdate = false}) {
    // If there are more than one messages, and this is not the initial update,
    // then the last message is the one we want to add to the stream.
    if (messages.length > 1 && !initialUpdate) {
      _messagesController.add([messages[0]]);
    } else {
      _messagesController.add(messages);
    }
  }

  // Creates a new thread in OpenAI and returns its ID.
  Future<String> createThread() async {
    final url = Uri.parse('https://api.openai.com/v1/threads');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
        'OpenAI-Beta': 'assistants=v1'
      },
    );

    // Handle response and log accordingly.
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      LoggerService().log('Thread created successfully with ID: ${responseData['id']}');
      return responseData['id'];
    } else {
      LoggerService().log('Thread creation failed with status: ${response.statusCode}.');
      return '';
    }
  }

  // Stores the provided thread ID.
  void setThreadId(String threadId) {
    _currentThreadId = threadId;
  }

  // Adds a user message to the current thread.
  Future<void> addMessageToThread(String userMessage) async {
    if (_currentThreadId.isEmpty) {
      LoggerService().log('Thread ID is not set. Unable to add message.');
      return;
    }

    // Add message to UI
    _updateMessages([Message(text: userMessage, isUserMessage: true)]);

    final url = Uri.parse('https://api.openai.com/v1/threads/$_currentThreadId/messages');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
        'OpenAI-Beta': 'assistants=v1'
      },
      body: jsonEncode({
        'role': 'user',
        'content': userMessage,
      }),
    );

    // Log success or failure of message addition.
    if (response.statusCode == 200) {
      LoggerService().log('Message added to thread successfully.');
    } else {
      LoggerService().log('Failed to add message to thread. Status code: ${response.statusCode}.');
    }
  }

  // Initiates a run on the current thread.
  Future<void> createRun() async {
    if (_currentThreadId.isEmpty) {
      LoggerService().log('Thread ID is not set. Unable to create run.');
      return;
    }

    final url = Uri.parse('https://api.openai.com/v1/threads/$_currentThreadId/runs');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json', 
        'OpenAI-Beta': 'assistants=v1'
      },
      body: jsonEncode({
        'assistant_id': 'asst_GNIcbPdARMiPcLc5OqKxaogu'
      }),
    );

    // Handle run creation response.
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      _currentRunId = responseData['id'];
      LoggerService().log('Run created successfully with ID: $_currentRunId');
      _startRunStatusCheck();
    } else {
      LoggerService().log('Failed to create run. Status code: ${response.statusCode}.');
      LoggerService().log('Response body: ${response.body}');
    }
  }

  // Retrieves the status of the current run.
  Future<dynamic> getRunStatus() async {
    if (_currentRunId.isEmpty) {
      LoggerService().log('Run ID is not set. Unable to get run status.');
      return;
    }

    final url = Uri.parse('https://api.openai.com/v1/threads/$_currentThreadId/runs/$_currentRunId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'OpenAI-Beta': 'assistants=v1'
      },
    );

    // Log and return run status.
    if (response.statusCode == 200) {
      LoggerService().log('Run status retrieved successfully.');
      return jsonDecode(response.body);
    } else {
      LoggerService().log('Failed to retrieve run status. Status code: ${response.statusCode}.');
      return {'status': 'failed'};
    }
  }

  // Periodically checks the status of the current run and handles completion or failure.
  void _startRunStatusCheck() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      final runStatus = await getRunStatus();
      if (runStatus != null) {
        if (runStatus['status'] == 'completed') {
          _timer?.cancel();
          LoggerService().log('Run completed successfully.');
          // Retrieve and update messages upon run completion.
          final messages = await getMessages();
          _updateMessages(messages);
        } else if (runStatus['status'] == 'failed') {
          _timer?.cancel();
          LoggerService().log('Run failed.');
          // Handle run failure here.
        }
      }
    });
  }

  // Retrieves messages from the current thread.
  Future<List<Message>> getMessages() async {
    if (_currentThreadId.isEmpty) {
      LoggerService().log('Thread ID is not set. Unable to retrieve messages.');
      return [];
    }

    final url = Uri.parse('https://api.openai.com/v1/threads/$_currentThreadId/messages');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'OpenAI-Beta': 'assistants=v1'
      },
    );

    // Process and return messages.
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      List<Message> messages = [];
      for (var messageData in responseData['data']) {
        messages.add(Message.fromJson(messageData));
      }
      LoggerService().log('Messages retrieved successfully.');
      return messages;
    } else {
      LoggerService().log('Failed to retrieve messages. Status code: ${response.statusCode}.');
      LoggerService().log('Response body: ${response.body}');
      return [];
    }
  }

  // Cleans up resources when the agent is no longer needed.
  void dispose() {
    _messagesController.close();
    _timer?.cancel();
  }
}
