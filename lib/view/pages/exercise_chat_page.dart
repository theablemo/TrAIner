import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Squat Trainer Chat',
      home: ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Map<String, String>> messages = [];
  TextEditingController _controller = TextEditingController();

  void _sendMessage(String text) {
    setState(() {
      messages.add({'sender': 'user', 'text': text});
      // Simulate a response from the LLM
      messages
          .add({'sender': 'llm', 'text': 'This is a response from the LLM.'});
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat with Trainer')),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverPersistentHeader(
                delegate: MySliverPersistentHeaderDelegate(
                  title: 'Rep #1 - Error: Knee valgus',
                  isRep: true,
                ),
                pinned: true,
              ),
            ),
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverPersistentHeader(
                delegate: MySliverPersistentHeaderDelegate(
                  title: 'General Chat',
                  isRep: false,
                ),
                pinned: true,
              ),
            ),
          ];
        },
        body: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverOverlapInjector(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        var message = messages[index];
                        return ChatMessageBubble(
                          sender: message['sender']!,
                          text: message['text']!,
                        );
                      },
                      childCount: messages.length,
                    ),
                  ),
                  SliverOverlapInjector(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      GeneralChatSection(
                        message: 'What are the benefits of squats?',
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            ChatInputField(
              controller: _controller,
              onSend: _sendMessage,
            ),
          ],
        ),
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

  ChatMessageBubble({required this.sender, required this.text});

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
              child: Icon(Icons.android),
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
          child: Text(text),
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

  ChatInputField({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: 'Type your message...'),
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
