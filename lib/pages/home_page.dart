import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:google_model/bloc/chat_bot_bloc.dart';
import 'package:google_model/models/chat_message_model.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

import 'history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ChatBotBloc chatBotBloc = ChatBotBloc();
  TextEditingController textEditingController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  List<String> suggestions = [
    "Invent a new color",
    "Describe time to a fish",
    "Design a 26th letter",
    "Explain dreams to a robot",
    "Create a new emotion",
    "Invent a sixth sense",
    "Describe silence visually",
    "Imagine life without gravity",
    "Redefine happiness",
    "Design a new body part",
    "Explain jokes to an AI",
    "Create a new law of physics",
    "Describe light to the blind",
    "Invent a new fundamental taste",
    "Reimagine sleep",
    "Design a universal language",
    "Explain money to an alien",
    "Create a new mathematical operation",
    "Describe smell to someone without it",
    "Invent a new form of matter",
  ];
  List<String> selectedSuggestions = [];
  List<ChatMessageModel> chatSession = [];

  @override
  void dispose() {
    _scrollController.dispose();
    textEditingController.dispose();
    chatBotBloc.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _randomizeSuggestions();
  }

  void _randomizeSuggestions() {
    suggestions.shuffle(Random());
    selectedSuggestions = [];
  }

  Future<void> _saveChatSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String sessionKey = 'chatSession_${DateTime.now().millisecondsSinceEpoch}';
    List<String> sessionData =
        chatSession.map((e) => jsonEncode(e.toJson())).toList();
    List<String>? existingSessions = prefs.getStringList('chatSessions');
    existingSessions = existingSessions ?? [];
    existingSessions.add(sessionKey);
    await prefs.setStringList('chatSessions', existingSessions);
    await prefs.setStringList(sessionKey, sessionData);
  }

  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HistoryPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        backgroundColor: Colors.deepPurple[900],
        title: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: const Text(
            'TwilightThinker',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: _navigateToHistory,
          ),
        ],
      ),
      body: BlocConsumer<ChatBotBloc, ChatBotState>(
        bloc: chatBotBloc,
        listener: (context, state) {
          if (state is ChatSuccessState) {
            setState(() {
              chatSession = state.messages;
            });
            _saveChatSession();
          }
        },
        builder: (context, state) {
          switch (state.runtimeType) {
            case ChatSuccessState:
              List<ChatMessageModel> messages =
                  (state as ChatSuccessState).messages;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              });
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withOpacity(0.9),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          bool isUser = messages[index].role == 'user';
                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.7,
                              ),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? Colors.deepPurple[700]
                                    : Colors.grey[800],
                                borderRadius:
                                    BorderRadius.circular(12).copyWith(
                                  bottomLeft: isUser
                                      ? const Radius.circular(12)
                                      : const Radius.circular(0),
                                  bottomRight: isUser
                                      ? const Radius.circular(0)
                                      : const Radius.circular(12),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isUser ? "You" : "Athene",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isUser
                                          ? Colors.white
                                          : Colors.blueGrey[300],
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    messages[index].parts.first.text,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isUser
                                          ? Colors.white
                                          : Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (chatBotBloc.generating)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 100,
                              width: 100,
                              child: Lottie.asset(
                                  'assets/images/twilight_loader.json'),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Loading...',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 8,
                      ),
                      child: Column(
                        children: [
                          ChipsChoice<String>.multiple(
                            value: selectedSuggestions,
                            onChanged: (val) {
                              setState(() {
                                selectedSuggestions = val;
                                if (selectedSuggestions.isNotEmpty) {
                                  String selectedText =
                                      selectedSuggestions.last;
                                  selectedSuggestions.clear();
                                  chatBotBloc.add(
                                    ChatGenerateNewTextMessageEvent(
                                        inputMessage: selectedText),
                                  );
                                }
                              });
                            },
                            choiceItems: C2Choice.listFrom<String, String>(
                              source: suggestions,
                              value: (i, v) => v,
                              label: (i, v) => v,
                            ),
                            choiceStyle: C2ChipStyle.toned(
                              backgroundColor: Colors.deepPurple[700],
                              selectedStyle: C2ChipStyle.filled(
                                color: Colors.deepPurple[900],
                              ),

                              // : const TextStyle(color: Colors.white),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: textEditingController,
                                  style: const TextStyle(color: Colors.white),
                                  cursorColor: Colors.deepPurple[300],
                                  decoration: InputDecoration(
                                    hintText: 'Ask Something...',
                                    hintStyle: TextStyle(color: Colors.white70),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    fillColor: Colors.grey[900],
                                    filled: true,
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide(
                                          color: Colors.deepPurple[300]!),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  if (textEditingController.text.isNotEmpty) {
                                    String text = textEditingController.text;
                                    textEditingController.clear();
                                    chatBotBloc.add(
                                        ChatGenerateNewTextMessageEvent(
                                            inputMessage: text));
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.deepPurple[700],
                                  child: const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
