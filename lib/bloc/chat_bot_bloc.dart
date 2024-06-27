import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:google_model/models/chat_message_model.dart';
import 'package:google_model/repos/chat_repository.dart';
import 'package:meta/meta.dart';

part 'chat_bot_event.dart';
part 'chat_bot_state.dart';

class ChatBotBloc extends Bloc<ChatBotEvent, ChatBotState> {
  ChatBotBloc() : super(ChatSuccessState(messages: [])) {
    on<ChatGenerateNewTextMessageEvent>(chatGenerateNewTextMessageEvent);
  }
  List<ChatMessageModel> messsages = [];

  FutureOr<void> chatGenerateNewTextMessageEvent(
      ChatGenerateNewTextMessageEvent event, Emitter<ChatBotState> emit) async {
    messsages.add(ChatMessageModel(
        role: 'user', parts: [ChatPartModel(text: event.inputMessage)]));
    emit(ChatSuccessState(messages: messsages));

    String generatedText = await ChatRepo.chatTextGenerationRepo(messsages);

    if (generatedText.length > 0) {
      messsages.add(ChatMessageModel(
          role: 'model', parts: [ChatPartModel(text: generatedText)]));
      emit(ChatSuccessState(messages: messsages));
    }
  }
}
