import 'package:flutter/material.dart';
import 'package:google_model/models/chat_message_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> chatSessions = [];

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();
    List<Map<String, dynamic>> sessions = [];

    for (String key in keys) {
      if (key.startsWith('chatSession_')) {
        List<String>? sessionData = prefs.getStringList(key);
        if (sessionData != null) {
          List<ChatMessageModel> messages = sessionData
              .map((message) => ChatMessageModel.fromJson(jsonDecode(message)))
              .toList();
          sessions.add({
            'key': key,
            'messages': messages,
            'timestamp': int.parse(key.split('_')[1]),
          });
        }
      }
    }

    sessions.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

    setState(() {
      chatSessions = sessions;
    });
  }

  Future<void> _deleteChatSession(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    _loadChatHistory();
  }

  String _getSessionTopic(List<ChatMessageModel> messages) {
    if (messages.isNotEmpty) {
      String firstMessage = messages.first.parts.first.text;
      return firstMessage.length > 30
          ? '${firstMessage.substring(0, 30)}...'
          : firstMessage;
    }
    return 'Untitled Session';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title:
            const Text('Chat History', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[850],
      ),
      body: chatSessions.isEmpty
          ? Center(
              child: Text(
                'No chat history available.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[400],
                ),
              ),
            )
          : ListView.builder(
              itemCount: chatSessions.length,
              itemBuilder: (context, index) {
                String sessionKey = chatSessions[index]['key'];
                List<ChatMessageModel> messages =
                    chatSessions[index]['messages'];
                int timestamp = chatSessions[index]['timestamp'];
                String formattedDate = DateFormat('MMM d, y HH:mm')
                    .format(DateTime.fromMillisecondsSinceEpoch(timestamp));

                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  elevation: 4,
                  color: Colors.grey[850],
                  child: ListTile(
                    title: Text(
                      _getSessionTopic(messages),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      formattedDate,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red[300]),
                      onPressed: () => _deleteChatSession(sessionKey),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Colors.grey[900],
                            title: Text(
                              'Chat Messages',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: messages.map((message) {
                                  bool isUser = message.role == 'user';
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: isUser
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isUser ? 'You' : 'ChatBot',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isUser
                                                ? Colors.blueAccent[100]
                                                : Colors.greenAccent[100],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            color: isUser
                                                ? Colors.blueAccent
                                                    .withOpacity(0.2)
                                                : Colors.greenAccent
                                                    .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: Text(
                                            message.parts.first.text,
                                            style: TextStyle(
                                              color: isUser
                                                  ? Colors.blueAccent[100]
                                                  : Colors.greenAccent[100],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            actions: [
                              TextButton(
                                child: Text(
                                  'Close',
                                  style: TextStyle(color: Colors.blueAccent),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
