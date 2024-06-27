import 'dart:convert';

import 'package:flutter/foundation.dart';

class ChatMessageModel {
  final String role;
  final List<ChatPartModel> parts;

  ChatMessageModel({
    required this.role,
    required this.parts,
  });

  // Map<String, dynamic> toMap() {
  //   return {
  //     'role': role,
  //     'parts': parts.map((x) => x.toMap()).toList(),
  //   };
  // }

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'parts': parts.map((x) => x.toMap()).toList(),
    };
  }

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      role: map['role'] ?? '',
      parts: List<ChatPartModel>.from(
          map['parts']?.map((x) => ChatPartModel.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatMessageModel.fromJson(String source) =>
      ChatMessageModel.fromMap(json.decode(source));
}

class ChatPartModel {
  final String text;

  ChatPartModel({
    required this.text,
  });

  ChatPartModel copyWith({
    String? text,
  }) {
    return ChatPartModel(
      text: text ?? this.text,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
    };
  }

  factory ChatPartModel.fromMap(Map<String, dynamic> map) {
    return ChatPartModel(
      text: map['text'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatPartModel.fromJson(String source) =>
      ChatPartModel.fromMap(json.decode(source));

  @override
  String toString() => 'ChatPartModel(text: $text)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatPartModel && other.text == text;
  }

  @override
  int get hashCode => text.hashCode;
}
