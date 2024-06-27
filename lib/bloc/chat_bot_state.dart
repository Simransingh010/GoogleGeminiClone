part of 'chat_bot_bloc.dart';

@immutable
sealed class ChatBotState {}

final class ChatBotInitial extends ChatBotState {}

class ChatSuccessState extends ChatBotState {
  final List<ChatMessageModel> messages;

  ChatSuccessState({required this.messages});
}
