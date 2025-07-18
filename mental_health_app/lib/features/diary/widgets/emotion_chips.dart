import 'package:flutter/material.dart';

class EmotionChips extends StatelessWidget {
  final List<String> emotions;

  const EmotionChips({super.key, required this.emotions});

  static const Map<String, String> emotionEmoji = {
    "joy": "😄",
    "sadness": "😢",
    "anger": "😠",
    "fear": "😨",
    "surprise": "😲",
    "disgust": "🤢",
    "calm": "😌",
    "excitement": "🤩",
    "neutral": "😐",
  };

  static const Map<String, String> emotionTooltip = {
    "joy": "Niềm vui",
    "sadness": "Nỗi buồn",
    "anger": "Tức giận",
    "fear": "Sợ hãi",
    "surprise": "Ngạc nhiên",
    "disgust": "Chán ghét",
    "calm": "Bình tĩnh",
    "excitement": "Hào hứng",
    "neutral": "Trung lập",
  };

  static const Map<String, Color> emotionColor = {
    "joy": Colors.yellow,
    "sadness": Colors.blue,
    "anger": Colors.redAccent,
    "fear": Colors.deepPurple,
    "surprise": Colors.orangeAccent,
    "disgust": Colors.green,
    "calm": Colors.teal,
    "excitement": Colors.pinkAccent,
    "neutral": Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: emotions.map((emotion) {
        final emoji = emotionEmoji[emotion] ?? "❓";
        final label = emotionTooltip[emotion] ?? "Không rõ";
        final color = emotionColor[emotion] ?? Colors.grey;

        return Tooltip(
          message: label, // Tooltip mô tả cảm xúc
          child: Chip(
            avatar: Text(
              emoji,
              style: const TextStyle(fontSize: 18),
            ),
            label: Text(
              emotion[0].toUpperCase() + emotion.substring(1),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: color,
            elevation: 2,
          ),
        );
      }).toList(),
    );
  }
}
