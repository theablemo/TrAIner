import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as GenAI;
import 'package:provider/provider.dart';
import 'package:trainerproject/constants.dart';
import 'package:trainerproject/controllers/providers/chat_provider.dart';
import 'package:trainerproject/controllers/providers/user_info_provider.dart';
import 'package:trainerproject/models/chat_exercise.dart';
import 'package:trainerproject/models/chat_message.dart';
import 'package:trainerproject/models/chat_rep.dart';
import 'package:trainerproject/models/exercise.dart';
import 'package:trainerproject/models/rep.dart';
import 'package:trainerproject/models/user_info.dart';
import 'package:trainerproject/view/typing_indicator.dart';

class ExerciseChatPage extends StatefulWidget {
  final Exercise exercise;
  final bool isGeneralChat;
  final Rep? rep;
  final int? repIndex;

  const ExerciseChatPage({
    super.key,
    required this.exercise,
    required this.isGeneralChat,
    this.rep,
    this.repIndex,
  });
  @override
  _ExerciseChatPageState createState() => _ExerciseChatPageState(
        exercise: exercise,
        isGeneralChat: isGeneralChat,
        rep: rep,
        repIndex: repIndex,
      );
}

class _ExerciseChatPageState extends State<ExerciseChatPage> {
  final Exercise exercise;
  final bool isGeneralChat;
  final Rep? rep;
  final int? repIndex;

  late final ChatExercise? chatExercise;
  late final ChatRep? chatRep;
  late List<ChatMessage> messages;

  final TextEditingController _controller = TextEditingController();
  bool isGeneratingResponse = false;
  String typingResponse = "";
  late final GenAI.GenerativeModel model;
  late final GenAI.ChatSession chat;
  final FocusNode _textFieldFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();

  _ExerciseChatPageState({
    required this.exercise,
    required this.isGeneralChat,
    this.rep,
    this.repIndex,
  });

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _textFieldFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    chatExercise = isGeneralChat ? exercise.chat : null;
    chatRep = !isGeneralChat ? rep!.chat : null;
    messages = isGeneralChat ? chatExercise!.messages : chatRep!.messages;

    final apiKey = Provider.of<ChatProvider>(context, listen: false).apiKey;

    final List<GenAI.Content> messageHistory = messages
        .map(
          (m) => GenAI.Content(
            m.sender.name,
            [GenAI.TextPart(m.content)],
          ),
        )
        .toList(growable: true);

    model = GenAI.GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
      systemInstruction: GenAI.Content.text(
        isGeneralChat
            ? Exercise.contextSettingPrompt()
            : Rep.contextSettingPrompt(),
      ),
    );
    chat = model.startChat(history: messageHistory);

    UserInfo userInfo =
        Provider.of<UserInfoProvider>(context, listen: false).userInfo!;

    if (messages.isEmpty) {
      if (!isGeneralChat) {
        chatRep!.wrongRepImagePath = rep!.picturePath;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        !isGeneralChat
            ? _sendChatMessage(
                Rep.generateWelcomeChatPrompt(
                    rep!.errors.map((e) => e.customName).join(', ')),
                true,
                true,
                chatRep!.wrongRepImagePath,
              )
            : _sendChatMessage(
                Exercise.generateWelcomeChatPrompt(
                  userInfo.firstName,
                  userInfo.age,
                  userInfo.weight,
                  userInfo.height,
                  userInfo.experienceLevel.name,
                  exercise.totalReps,
                  exercise.wrongReps,
                  exercise.generateErrorsSummary(),
                ),
                true,
                false,
                "");
      });
    }

    super.initState();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(
          milliseconds: 750,
        ),
        curve: Curves.easeOutCirc,
      ),
    );
  }

  Future<void> _sendChatMessage(String message, bool isInitializing,
      bool isImageMessage, String imagePath) async {
    FocusManager.instance.primaryFocus?.unfocus();
    _scrollDown();
    setState(() {
      // messages.add({'sender': 'user', 'text': message});
      // messages.add({'sender': 'user', 'text': ""});
      if (!isInitializing) {
        messages.add(
          ChatMessage(
            sender: MessageSender.user,
            content: message,
            timestamp: DateTime.now(),
          ),
        );
      }
      messages.add(
        ChatMessage(
          sender: MessageSender.llm,
          content: "",
          timestamp: DateTime.now(),
        ),
      );
      // Simulate a response from the LLM
      isGeneratingResponse = true;
    });

    try {
      final response = isImageMessage
          ? await chat.sendMessage(
              GenAI.Content.multi(
                [
                  GenAI.TextPart(message),
                  GenAI.DataPart(
                      'image/jpeg', await File(imagePath).readAsBytes()),
                ],
              ),
            )
          : await chat.sendMessage(
              GenAI.Content.text(message),
            );

      final text = response.text;

      if (text == null || text.isEmpty) {
        _showError('No response from API.');
        setState(() {
          messages.removeLast();
        });
      } else {
        setState(() {
          isGeneratingResponse = false;
          messages.removeLast();
          // messages.add({'sender': 'llm', 'text': text.trim()});
          messages.add(
            ChatMessage(
              sender: MessageSender.llm,
              content: text.trim(),
              timestamp: DateTime.now(),
            ),
          );
        });
      }
    } catch (e) {
      _showError(e.toString());
      setState(() {
        messages.removeLast();
        isGeneratingResponse = false;
      });
    } finally {
      _controller.clear();
      typingResponse = "";
      setState(() {
        isGeneratingResponse = false;
      });
      _scrollDown();
    }
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Something went wrong'),
          content: SingleChildScrollView(
            child: SelectableText(message),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with Trainer'),
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // SliverPersistentHeader(
                //   delegate: MySliverPersistentHeaderDelegate(
                //     title: 'General Chat',
                //     isRep: false,
                //   ),
                //   pinned: true,
                // ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == 0 && !isGeneralChat) {
                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Hero(
                                tag: 'rep$repIndex',
                                child: Image.file(
                                  File(rep!.picturePath),
                                  fit: BoxFit.cover,
                                  width: MediaQuery.of(context).size.width / 3,
                                ),
                              ),
                              Column(
                                // crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  // const Text("Rep Errors"),
                                  ...rep!.errors.map(
                                    (e) {
                                      return Chip(
                                        label: Text(e.customName),
                                        backgroundColor: errorColor,
                                        side: BorderSide.none,
                                      );
                                    },
                                  )
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                      var message = !isGeneralChat
                          ? messages[index - 1]
                          : messages[index];
                      return message.content.isEmpty
                          ? ChatMessageBubble(
                              sender: MessageSender.llm,
                              text: typingResponse,
                              isGeneratingResponse: true,
                            )
                          : ChatMessageBubble(
                              sender: message.sender,
                              text: message.content,
                              isGeneratingResponse: false,
                            );
                    },
                    childCount:
                        !isGeneralChat ? messages.length + 1 : messages.length,
                  ),
                ),
              ],
            ),
          ),
          ChatInputField(
            controller: _controller,
            onSend: _sendChatMessage,
            focusNode: _textFieldFocus,
            isGeneratingReponse: isGeneratingResponse,
          ),
        ],
      ),
    );
  }
}

class MySliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final bool isRep;

  MySliverPersistentHeaderDelegate({required this.title, required this.isRep});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: isRep ? Colors.blue : Colors.green,
      alignment: Alignment.center,
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }

  @override
  double get maxExtent => 60.0;

  @override
  double get minExtent => 60.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;
}

class ChatMessageBubble extends StatelessWidget {
  final MessageSender sender;
  final String text;
  final bool isGeneratingResponse;

  const ChatMessageBubble({
    super.key,
    required this.sender,
    required this.text,
    required this.isGeneratingResponse,
  });

  @override
  Widget build(BuildContext context) {
    bool isUser = sender == MessageSender.user;
    return Row(
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isUser)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              child: Icon(Icons.auto_awesome),
            ),
          ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          constraints: const BoxConstraints(maxWidth: 285),
          decoration: BoxDecoration(
            color: isUser ? Colors.blue[100] : Colors.green[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: isGeneratingResponse
              ? const TypingIndicator(
                  showIndicator: true,
                )
              : MarkdownBody(data: text),
        ),
        if (isUser)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              child: Icon(Icons.person),
            ),
          ),
      ],
    );
  }
}

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String, bool, bool, String) onSend;
  final FocusNode focusNode;
  final bool isGeneratingReponse;

  const ChatInputField(
      {super.key,
      required this.controller,
      required this.onSend,
      required this.focusNode,
      required this.isGeneratingReponse});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              focusNode: focusNode,
              controller: controller,
              textInputAction: TextInputAction.send,
              enabled: !isGeneratingReponse,
              decoration:
                  const InputDecoration(hintText: 'Type your message...'),
              onSubmitted: (text) {
                if (text.isNotEmpty) {
                  onSend(text, false, false, "");
                }
              },
            ),
          ),
          IconButton(
            disabledColor: Colors.grey,
            icon: const Icon(Icons.send),
            onPressed: !isGeneratingReponse
                ? () {
                    if (controller.text.isNotEmpty) {
                      onSend(controller.text, false, false, "");
                    }
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

// class GeneralChatSection extends StatelessWidget {
//   final String message;

//   const GeneralChatSection({super.key, required this.message});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Text(message),
//     );
//   }
// }


