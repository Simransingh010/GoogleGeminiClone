import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_model/models/chat_message_model.dart';
import 'package:google_model/repos/chat_repository.dart';

part 'chat_bot_event.dart';
part 'chat_bot_state.dart';

class ChatBotBloc extends Bloc<ChatBotEvent, ChatBotState> {
  ChatBotBloc() : super(ChatSuccessState(messages: const [])) {
    on<ChatGenerateNewTextMessageEvent>(chatGenerateNewTextMessageEvent);
  }

  List<ChatMessageModel> messages = [];
  bool generating = false;

  FutureOr<void> chatGenerateNewTextMessageEvent(
      ChatGenerateNewTextMessageEvent event, Emitter<ChatBotState> emit) async {
    messages.add(ChatMessageModel(
        role: 'user', parts: [ChatPartModel(text: event.inputMessage)]));
    emit(ChatSuccessState(messages: messages));

    generating = true;

    String generatedText = await ChatRepo.chatTextGenerationRepo(messages);

    if (generatedText.isNotEmpty) {
      messages.add(ChatMessageModel(
          role: 'model', parts: [ChatPartModel(text: generatedText)]));
      emit(ChatSuccessState(messages: messages));
    }

    generating = false;
  }
}
