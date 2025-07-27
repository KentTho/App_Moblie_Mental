// lib/features/charts/page/emotion_chart_page.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mental_health_app/change_notifiers/chart_provider.dart';
import 'package:mental_health_app/models/emotion_chart_model.dart';
// Assuming you'll add fl_chart to your pubspec.yaml

class EmotionChartPage extends StatefulWidget {
  const EmotionChartPage({super.key});

  @override
  State<EmotionChartPage> createState() => _EmotionChartPageState();
}

class _EmotionChartPageState extends State<EmotionChartPage> {
  int selectedDays = 30; // Thêm tuỳ chọn số ngày

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    Provider.of<ChartProvider>(context, listen: false)
      .fetchEmotionChartData(context, days: selectedDays);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê cảm xúc'),
        actions: [
          DropdownButton<int>(
            value: selectedDays,
            items: [7, 14, 30, 90].map((days) =>
              DropdownMenuItem(
                value: days,
                child: Text('$days ngày'),
              )
            ).toList(),
            onChanged: (value) {
              setState(() {
                selectedDays = value!;
                _fetchData();
              });
            },
          )
        ],
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
                            ),
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

  const EmotionLineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Sắp xếp data theo ngày
    final sortedData = [...data]..sort((a, b) => a.date.compareTo(b.date));

    // Map màu sắc cho cảm xúc
    final emotionColors = {
      'joy': Colors.amber,
      'sadness': Colors.blue,
      'anger': Colors.red,
      'fear': Colors.purple,
      'surprise': Colors.orange,
      'disgust': Colors.green,
      'calm': Colors.teal,
      'excitement': Colors.pink,
      'neutral': Colors.grey,
    };

    // Lấy tất cả cảm xúc duy nhất
    final allEmotions = sortedData
        .expand((dp) => dp.emotionCounts.keys)
        .toSet()
        .toList();

    // Tạo legend
    final legends = allEmotions.map((emotion) => 
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            color: emotionColors[emotion],
          ),
          const SizedBox(width: 4),
          Text(emotion),
        ],
      ),
    ).toList();

    // Tạo dữ liệu biểu đồ
    final lineBarsData = allEmotions.map((emotion) {
      return LineChartBarData(
        spots: sortedData.map((dp) {
          return FlSpot(
            sortedData.indexOf(dp).toDouble(),
            dp.emotionCounts[emotion]?.toDouble() ?? 0,
          );
        }).toList(),
        isCurved: true,
        color: emotionColors[emotion] ?? Colors.black,
        barWidth: 3,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      );
    }).toList();

    // Tính toán min/max
    final maxY = sortedData.fold<double>(0, (max, dp) {
      final maxEmotion = dp.emotionCounts.values.fold<int>(0, (a, b) => a > b ? a : b);
      return max > maxEmotion ? max : maxEmotion.toDouble();
    }) + 1;

    return Column(
      children: [
        // Legend
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: legends,
        ),
        const SizedBox(height: 16),
        // Chart
        SizedBox(
          height: 300,
          child: LineChart(
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
                      if (index >= 0 && index < sortedData.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            sortedData[index].date.day.toString(),
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
              minX: 0,
              maxX: (sortedData.length - 1).toDouble(),
              minY: 0,
              maxY: maxY,
              lineBarsData: lineBarsData,
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final dataPoint = sortedData[spot.x.toInt()];
                      final emotion = allEmotions[spot.barIndex];
                      return LineTooltipItem(
                        '${dataPoint.formattedDate}\n',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text: '${emotion.capitalize()}: ${spot.y.toInt()}',
                            style: TextStyle(
                              color: emotionColors[emotion] ?? Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}