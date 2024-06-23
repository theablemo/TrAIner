import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'package:trainerproject/models/rep.dart';

class RepChatPage extends StatefulWidget {
  final Rep wrongRep;
  const RepChatPage({
    Key? key,
    required this.wrongRep,
  }) : super(key: key);
  @override
  State<RepChatPage> createState() => _RepChatPageState();
}

class _RepChatPageState extends State<RepChatPage> {
  static const platform = MethodChannel('com.example.native_interaction/image');
  bool isImageReady = false;
  String generatedImage = '';

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getImage();
    });
    super.initState();
  }

  Future<void> _getImage() async {
    final imagePath = widget.wrongRep.picturePath;
    try {
      final File imageFile = File(imagePath);
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final Uint8List result = await platform.invokeMethod('getImage', {
        'text': "A person doing squat with wide knees being wide.",
        'image': imageBytes,
      });
      // Save the processed image
      final Directory tempDir = await getApplicationDocumentsDirectory();
      final String tempPath =
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png';
      final File processedImageFile = File(tempPath);
      await processedImageFile.writeAsBytes(result);
      setState(() {
        isImageReady = true;
        generatedImage = tempPath;
      });

      // print('Processed image saved at $tempPath');
    } on PlatformException catch (e) {
      // print("Failed to get image: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat with Trainer')),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  delegate: MySliverPersistentHeaderDelegate(
                    title: 'Rep #1 - Error: Knee valgus',
                    isRep: true,
                  ),
                  pinned: true,
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    // RepChatSection(
                    //   repNumber: 1,
                    //   error: 'Knee valgus',
                    //   originalImage: widget.wrongRep.picturePath,
                    //   generatedImage: ,
                    //   llmMessage: 'Keep your knees aligned with your toes...',
                    // ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Rep #1 - Error: Ridi',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Image.file(File(widget.wrongRep.picturePath)),
                          Icon(Icons.arrow_downward),
                          isImageReady
                              ? Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Image.file(File(generatedImage)),
                                    IconButton(
                                      icon: Icon(Icons.info_outline),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text('Prompt Used'),
                                            content: Text(
                                              'This is the prompt that was used to generate the image.',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                )
                              : CircularProgressIndicator(),
                          Text('Keep your knees aligned with your toes...'),
                        ],
                      ),
                    )
                  ]),
                ),
              ],
            ),
          ),
          // ChatInputField(),
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

class RepChatSection extends StatelessWidget {
  final int repNumber;
  final String error;
  final String originalImage;
  final String generatedImage;
  final String llmMessage;

  RepChatSection({
    required this.repNumber,
    required this.error,
    required this.originalImage,
    required this.generatedImage,
    required this.llmMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rep #$repNumber - Error: $error',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Image.file(File(originalImage)),
          Icon(Icons.arrow_downward),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Image.file(File(generatedImage)),
              IconButton(
                icon: Icon(Icons.info_outline),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Prompt Used'),
                      content: Text(
                          'This is the prompt that was used to generate the image.'),
                    ),
                  );
                },
              ),
            ],
          ),
          Text(llmMessage),
        ],
      ),
    );
  }
}

// class GeneralChatSection extends StatelessWidget {
//   final String message;

//   GeneralChatSection({required this.message});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Text(message),
//     );
//   }
// }

// class ChatInputField extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               decoration: InputDecoration(hintText: 'Type your message...'),
//             ),
//           ),
//           IconButton(
//             icon: Icon(Icons.send),
//             onPressed: () {
//               // Handle send action
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
