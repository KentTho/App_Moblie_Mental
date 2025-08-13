import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mental_health_app/models/emotion_chart_model.dart';

class EmotionPieChart extends StatefulWidget {
  final List<EmotionDataPoint> data;
  const EmotionPieChart({super.key, required this.data});

  @override
  State<EmotionPieChart> createState() => _EmotionPieChartState();
}

class _EmotionPieChartState extends State<EmotionPieChart> with SingleTickerProviderStateMixin {
  int? touchedIndex;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, int> totalEmotionCounts = {};
    for (final dp in widget.data) {
      dp.emotionCounts.forEach((emotion, count) {
        totalEmotionCounts[emotion] = (totalEmotionCounts[emotion] ?? 0) + count;
      });
    }

    final allEmotions = totalEmotionCounts.keys.toList();
    final totalCount = totalEmotionCounts.values.fold<int>(0, (sum, val) => sum + val);
    final showDepressionWarning = _checkDepressionWarning(widget.data);

    return Column(
      children: [
        if (showDepressionWarning) _buildDepressionWarning(),
        const SizedBox(height: 12),
        _buildEmotionLegend(allEmotions),
        const SizedBox(height: 20),
        SizedBox(
          height: 250,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(touchCallback: (event, response) {
                    setState(() {
                      if (!event.isInterestedForInteractions || response == null || response.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex = response.touchedSection!.touchedSectionIndex;
                    });
                  }),
                  sections: allEmotions.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final emotion = entry.value;
                    final count = totalEmotionCounts[emotion] ?? 0;
                    final percentage = totalCount == 0 ? 0 : (count / totalCount) * 100;
                    final isTouched = idx == touchedIndex;
                    return PieChartSectionData(
                      value: count.toDouble(),
                      title: "${percentage.toStringAsFixed(1)}%",
                      color: _getEmotionColor(emotion).withOpacity(isTouched ? 1 : 0.7),
                      radius: isTouched ? 90 : 70,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 37, 36, 36),
                      ),
                      badgeWidget: isTouched
                          ? Icon(_getEmotionIcon(emotion), color: Colors.white, size: 24)
                          : null,
                      badgePositionPercentageOffset: 1.2,
                    );
                  }).toList(),
                  sectionsSpace: 6,
                  centerSpaceRadius: 50,
                  centerSpaceColor: Colors.white,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionLegend(List<String> emotions) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: emotions.map((emotion) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _getEmotionColor(emotion).withOpacity(0.25),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: _getEmotionColor(emotion).withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: _getEmotionColor(emotion),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                emotion.capitalize(),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDepressionWarning() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.orange.shade50, Colors.orange.shade100]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange[800]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Chúng tôi nhận thấy nhiều cảm xúc tiêu cực trong 2 tuần qua. '
              'Bạn có muốn nói chuyện với chuyên gia?',
              style: TextStyle(color: Colors.orange[800], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  bool _checkDepressionWarning(List<EmotionDataPoint> data) {
    if (data.length < 14) return false;
    final negativeEmotions = ['sadness', 'fear', 'anger'];
    int highNegativeDays = 0;
    int lowPositiveDays = 0;

    for (final dp in data.take(14)) {
      final hasHighNegative = negativeEmotions.any((emotion) => (dp.emotionCounts[emotion] ?? 0) >= 3);
      final positiveCount = (dp.emotionCounts['joy'] ?? 0) + (dp.emotionCounts['excitement'] ?? 0);
      if (hasHighNegative) highNegativeDays++;
      if (positiveCount <= 1) lowPositiveDays++;
    }
    return highNegativeDays >= 10 || lowPositiveDays >= 12;
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'joy':
        return const Color(0xFFFFEB3B);
      case 'sadness':
        return const Color(0xFF2196F3);
      case 'anger':
        return const Color(0xFFF44336);
      case 'fear':
        return const Color(0xFF9C27B0);
      case 'surprise':
        return const Color(0xFFFF9800);
      case 'disgust':
        return const Color(0xFF8BC34A);
      case 'calm':
        return const Color(0xFF00BCD4);
      case 'excitement':
        return const Color(0xFFE91E63);
      case 'enjoyment':
        return const Color(0xFF8CFD5F);
      default:
        return Colors.grey;
    }
  }

  LinearGradient _getEmotionGradient(String emotion, int index) {
    final baseColor = _getEmotionColor(emotion);
    return LinearGradient(
      colors: [baseColor.withOpacity(0.7), baseColor.withOpacity(0.95)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  IconData _getEmotionIcon(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'joy':
        return Icons.emoji_emotions;
      case 'sadness':
        return Icons.sentiment_dissatisfied;
      case 'anger':
        return Icons.whatshot;
      case 'fear':
        return Icons.warning_amber_rounded;
      case 'calm':
        return Icons.self_improvement;
      case 'excitement':
        return Icons.celebration;
      case 'enjoyment':
        return Icons.emoji_events;
      default:
        return Icons.sentiment_neutral;
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
