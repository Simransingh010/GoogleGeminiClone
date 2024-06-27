part of 'chat_bot_bloc.dart';

@immutable
sealed class ChatBotEvent {}

class ChatGenerateNewTextMessageEvent extends ChatBotEvent {
  final String inputMessage;

  ChatGenerateNewTextMessageEvent({required this.inputMessage});
}
