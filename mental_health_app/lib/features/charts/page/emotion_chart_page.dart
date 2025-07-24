// lib/features/charts/page/emotion_chart_page.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mental_health_app/change_notifiers/chart_provider.dart';
import 'package:mental_health_app/models/emotion_chart_model.dart';
// Assuming you'll add fl_chart to your pubspec.yaml

class EmotionChartPage extends StatefulWidget {
  const EmotionChartPage({Key? key}) : super(key: key);

  @override
  State<EmotionChartPage> createState() => _EmotionChartPageState();
}

class _EmotionChartPageState extends State<EmotionChartPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChartProvider>(context, listen: false).fetchEmotionChartData(context);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emotional Trends'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Consumer<ChartProvider>(
        builder: (context, chartProvider, child) {
          if (chartProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (chartProvider.errorMessage != null) {
            return Center(
              child: Text(
                'Error: ${chartProvider.errorMessage}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (chartProvider.emotionChartData == null || chartProvider.emotionChartData!.data.isEmpty) {
            return const Center(
              child: Text(
                'No emotion data available yet. Start journaling!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Emotional Journey Over Time',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 300,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: EmotionLineChart(data: chartProvider.emotionChartData!.data),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Daily Emotion Breakdown:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: chartProvider.emotionChartData!.data.length,
                  itemBuilder: (context, index) {
                    final dataPoint = chartProvider.emotionChartData!.data[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dataPoint.formattedDate,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...dataPoint.emotionCounts.entries.map((entry) =>
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: Text(
                                  '${entry.key.capitalize()}: ${entry.value} notes',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                ),
                              ),
                            ).toList(),
                            if (dataPoint.emotionCounts.isEmpty)
                              const Text(
                                'No specific emotions recorded for this day.',
                                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Helper extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

// Simplified Emotion Line Chart using fl_chart
class EmotionLineChart extends StatelessWidget {
  final List<EmotionDataPoint> data;

  const EmotionLineChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Map emotions to unique colors
    final Map<String, Color> emotionColors = {
      'joy': Colors.yellow.shade700,
      'sadness': Colors.blue.shade700,
      'anger': Colors.red.shade700,
      'fear': Colors.purple.shade700,
      'surprise': Colors.orange.shade700,
      'disgust': Colors.green.shade700,
      'calm': Colors.teal.shade700,
      'excitement': Colors.pink.shade700,
      'neutral': Colors.grey.shade700,
    };

    // Get all unique emotions present in the data
    final Set<String> allEmotions = data.fold<Set<String>>(
      {},
      (previousValue, element) => previousValue..addAll(element.emotionCounts.keys),
    );

    // Create a list of LineChartBarData for each emotion
    final List<LineChartBarData> lineBarsData = allEmotions.map((emotion) {
      return LineChartBarData(
        spots: data.asMap().entries.map((entry) {
          final int index = entry.key;
          final EmotionDataPoint dataPoint = entry.value;
          return FlSpot(index.toDouble(), dataPoint.emotionCounts[emotion]?.toDouble() ?? 0);
        }).toList(),
        isCurved: true,
        color: emotionColors[emotion] ?? Colors.black, // Default to black if color not found
        barWidth: 3,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      );
    }).toList();

    // Determine min/max X and Y values for the chart
    final double minX = 0;
    final double maxX = (data.length - 1).toDouble();
    final double minY = 0;
    final double maxY = data.fold<int>(0, (max, dp) => max > dp.emotionCounts.values.fold<int>(0, (a, b) => a > b ? a : b) ? max : dp.emotionCounts.values.fold<int>(0, (a, b) => a > b ? a : b)).toDouble() + 1; // Max count + 1 for padding

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      data[index].date.day.toString(), // Show day of month
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1),
        ),
        minX: minX,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        lineBarsData: lineBarsData,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final flSpot = touchedSpot;
                final dataPoint = data[flSpot.x.toInt()];
                final emotion = allEmotions.elementAt(touchedSpot.barIndex); // Get emotion from bar index
                return LineTooltipItem(
                  '${dataPoint.formattedDate}n',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: '${emotion.capitalize()}: ${flSpot.y.toInt()}',
                      style: TextStyle(color: emotionColors[emotion] ?? Colors.white, fontSize: 12),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
