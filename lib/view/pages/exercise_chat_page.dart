import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as GenAI;
// import 'package:flutter_gemma/flutter_gemma_interface.dart';
import 'package:trainerproject/view/typing_indicator.dart';

class ExerciseChatPage extends StatefulWidget {
  @override
  _ExerciseChatPageState createState() => _ExerciseChatPageState();
}

class _ExerciseChatPageState extends State<ExerciseChatPage> {
  List<Map<String, String>> messages = [];
  final TextEditingController _controller = TextEditingController();
  bool isGeneratingResponse = false;
  String typingResponse = "";
  late final GenAI.GenerativeModel model;
  late final GenAI.ChatSession chat;
  final FocusNode _textFieldFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();

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

  @override
  void initState() {
    model = GenAI.GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: "AIzaSyB94iyYtAxvk5580sv0cPJqsfz8mZnKtmk",
    );

    chat = model.startChat();
    super.initState();
  }

  Future<void> _sendChatMessage(String message) async {
    FocusManager.instance.primaryFocus?.unfocus();
    _scrollDown();
    setState(() {
      messages.add({'sender': 'user', 'text': message});
      messages.add({'sender': 'user', 'text': ""});
      // Simulate a response from the LLM
      isGeneratingResponse = true;
    });

    try {
      final response = await chat.sendMessage(
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
          messages.add({'sender': 'llm', 'text': text.trim()});
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

  void _sendMessage(String text) async {
    setState(
      () {
        messages.add({'sender': 'user', 'text': text});
        // Simulate a response from the LLM
        isGeneratingResponse = true;
      },
    );

    // final response = await model.generateContent();

//     final String modelPath = "/data/local/tmp/llm/model.bin";
//     final cacheDirFuture = getApplicationCacheDirectory();
//     final cacheDir = (await cacheDirFuture).absolute.path;

//     bool isGpu = true;
//     final options = switch (isGpu) {
//       true => LlmInferenceOptions.gpu(
//           modelPath: modelPath,
//           maxTokens: 2048,
//           sequenceBatchSize: 20,
//           temperature: 0.5,
//           topK: 40,
//         ),
//       false => LlmInferenceOptions.cpu(
//           modelPath: modelPath,
//           maxTokens: 2048,
//           temperature: 0.5,
//           topK: 40,
//           cacheDir: cacheDir,
//         ),
//     };

// // Create an inference engine
//     final engine = LlmInferenceEngine(options);
//     final responseStream = engine.generateResponse(text).listen((String token) {
//       if (token == null) {
//         setState(() {
//           isGeneratingResponse = false;
//           messages.add({'sender': 'llm', 'text': typingResponse});
//           typingResponse = "";
//         });
//       } else {
//         setState(() {
//           typingResponse = '$typingResponse$token';
//         });
//       }
//     });

    // final flutterGemma = FlutterGemmaPlugin.instance;
    // final a =
    //     flutterGemma.getResponseAsync(prompt: text).listen((String? token) {
    //   if (token == null) {
    //     setState(() {
    //       isGeneratingResponse = false;
    //       messages.add({'sender': 'llm', 'text': typingResponse});
    //       typingResponse = "";
    //     });
    //   } else {
    //     setState(() {
    //       typingResponse = '$typingResponse$token';
    //     });
    //   }
    // });
    // a.cancel();
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat with Trainer')),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverPersistentHeader(
                  delegate: MySliverPersistentHeaderDelegate(
                    title: 'General Chat',
                    isRep: false,
                  ),
                  pinned: true,
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      var message = messages[index];
                      return message['text']!.isEmpty
                          ? ChatMessageBubble(
                              sender: 'llm',
                              text: typingResponse,
                              isGeneratingResponse: true,
                            )
                          : ChatMessageBubble(
                              sender: message['sender']!,
                              text: message['text']!,
                              isGeneratingResponse: false,
                            );
                    },
                    childCount: messages.length,
                  ),
                ),
              ],
            ),
          ),
          ChatInputField(
            controller: _controller,
            onSend: _sendChatMessage,
            focusNode: _textFieldFocus,
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
        style: TextStyle(color: Colors.white, fontSize: 20),
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
  final String sender;
  final String text;
  final bool isGeneratingResponse;

  ChatMessageBubble(
      {required this.sender,
      required this.text,
      required this.isGeneratingResponse});

  @override
  Widget build(BuildContext context) {
    bool isUser = sender == 'user';
    return Row(
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isUser)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              child: Icon(Icons.auto_awesome),
            ),
          ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          constraints: BoxConstraints(maxWidth: 200),
          decoration: BoxDecoration(
            color: isUser ? Colors.blue[100] : Colors.green[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: isGeneratingResponse
              ? const TypingIndicator(
                  showIndicator: true,
                )
              : Text(text),
        ),
        if (isUser)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              child: Icon(Icons.person),
            ),
          ),
      ],
    );
  }
}

class GeneralChatSection extends StatelessWidget {
  final String message;

  GeneralChatSection({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(message),
    );
  }
}

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSend;
  final FocusNode focusNode;

  ChatInputField(
      {required this.controller,
      required this.onSend,
      required this.focusNode});

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
              decoration:
                  const InputDecoration(hintText: 'Type your message...'),
              onSubmitted: (text) {
                if (text.isNotEmpty) {
                  onSend(text);
                }
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onSend(controller.text);
              }
            },
          ),
        ],
      ),
    );
  }
}
