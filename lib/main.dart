import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Story Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _userInput = TextEditingController();
  FlutterTts flutterTts = FlutterTts();
  static const apiKey =
      "AIzaSyDy8p1S4JvowBb61hfXeSt8rQ1N0hpqhjM"; 
  final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
  final List<Message> _messages = [];
  bool _isLoading = false;

  Future<void> sendMessage() async {
    final message = "Generate story of Prompt: ${_userInput.text.trim()}";
    if (message.isEmpty) return;

    print('User input: $message');

    setState(() {
      _messages.add(Message(isUser: true, message: message, date: DateTime.now()));
      _isLoading = true; 
    });

    final content = [Content.text(message)];
    try {
      final response = await model.generateContent(content);
      final responseMessage = response.text ?? "";
      print('Response from AI: $responseMessage');

      setState(() {
        _messages.add(Message(isUser: false, message: responseMessage, date: DateTime.now()));
      });

      
      await flutterTts.setLanguage("en-US");
      await flutterTts.setPitch(1); 
      await flutterTts.speak(responseMessage); 
    } catch (e) {
      print('Error: $e');
      setState(() {
        _messages.add(Message(
            isUser: false,
            message: 'Error generating response. Please try again.',
            date: DateTime.now()));
      });
    } finally {
      setState(() {
        _isLoading = false; 
      });
    }
  }

  Future<void> stopSpeaking() async {
    await flutterTts.stop(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background2.jpg'),
            fit: BoxFit.cover, 
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Story Generator ...',
                    style: TextStyle(
                      color: Color.fromARGB(255, 184, 167, 13), 
                      fontSize: 40, 
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(width: 8), 
                  Image(
                    image: AssetImage('assets/title.png'), 
                    height: 120, 
                    width: 120, 
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 20, left: 20),
                    child: TextFormField(
                      style: const TextStyle(color: Colors.black),
                      controller: _userInput,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        label: const Text('Enter Your Prompt'),
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                      keyboardType: TextInputType.multiline, 
                      maxLines: null, 
                    ),
                  ),
                  const SizedBox(height: 8), 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            sendMessage();
                            _userInput.clear(); 
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 45, 42, 42),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min, 
                              children: [
                                if (_isLoading) 
                                  const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                else ...[
                                  const Text(
                                    'Generate',
                                    style: TextStyle(color: Colors.white, fontSize: 22),
                                  ),
                                  const SizedBox(width: 10), 
                                  const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                  ),
                                ],
                                if (_isLoading)
                                  const SizedBox(width: 15),
                                if (_isLoading)
                                  const Text('Generating...', style: TextStyle(color: Colors.white)), 
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 20), 
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: stopSpeaking, 
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 255, 0, 0), 
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Center(
                                child: Text(
                                  'Stop',
                                  style: TextStyle(color: Colors.white, fontSize: 22),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Messages(
                    isUser: message.isUser,
                    message: message.message,
                    date: DateFormat('HH:mm').format(message.date),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Message {
  final bool isUser;
  final String message;
  final DateTime date;

  Message({required this.isUser, required this.message, required this.date});
}

class Messages extends StatelessWidget {
  final bool isUser;
  final String message;
  final String date;

  const Messages({
    super.key,
    required this.isUser,
    required this.message,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(vertical: 15).copyWith(
        left: isUser ? 100 : 10,
        right: isUser ? 10 : 100,
      ),
      decoration: BoxDecoration(
        color: isUser ? Colors.blueAccent : Colors.grey.shade400,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(10),
          bottomLeft: isUser ? const Radius.circular(10) : Radius.zero,
          topRight: const Radius.circular(10),
          bottomRight: isUser ? Radius.zero : const Radius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(fontSize: 16, color: isUser ? Colors.white : Colors.black),
          ),
          Text(
            date,
            style: TextStyle(fontSize: 10, color: isUser ? Colors.white : Colors.black),
          ),
        ],
      ),
    );
  }
}