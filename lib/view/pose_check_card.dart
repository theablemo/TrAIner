import 'package:flutter/material.dart';

class PoseCheckCard extends StatelessWidget {
  final String checkTitle;
  final bool currentSitutation;
  const PoseCheckCard(
      {super.key, required this.checkTitle, required this.currentSitutation});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Card(
      color: currentSitutation
          ? Colors.greenAccent.withOpacity(0.9)
          : Colors.red.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: mq.size.width * 0.45,
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            currentSitutation
                ? const Icon(Icons.check_circle)
                : const Icon(Icons.cancel),
            const SizedBox(
              width: 5,
            ),
            Expanded(
              child: Text(
                checkTitle,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.clip,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
