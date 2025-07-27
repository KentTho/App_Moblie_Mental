import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mental_health_app/models/emotion_chart_model.dart';

class EmotionLineChart extends StatelessWidget {
  final List<EmotionDataPoint> data;

  const EmotionLineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Sắp xếp dữ liệu từ mới nhất đến cũ nhất
    final sortedData = [...data]..sort((a, b) => b.date.compareTo(a.date));
    final allEmotions = sortedData.expand((e) => e.emotionCounts.keys).toSet().toList();

    // Tính toán giá trị max cho trục Y (làm tròn lên số nguyên gần nhất + 2)
    final maxY = (sortedData.fold<double>(0, (max, dp) {
      final maxEmotion = dp.emotionCounts.values.fold<int>(0, (a, b) => a > b ? a : b);
      return max > maxEmotion ? max : maxEmotion.toDouble();
    })).ceilToDouble() + 2;

    // Kiểm tra dấu hiệu trầm cảm
    final showDepressionWarning = _checkDepressionWarning(sortedData);

    return Column(
      children: [
        // Cảnh báo trầm cảm nếu có
        if (showDepressionWarning) _buildDepressionWarning(),
        
        // Chú thích (legend) được thiết kế rõ ràng hơn
        _buildEmotionLegend(allEmotions),
        
        const SizedBox(height: 16),
        
        // Biểu đồ chính
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 16, top: 8),
            child: LineChart(
              LineChartData(
                lineBarsData: _createLineBarsData(sortedData, allEmotions),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 1,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey[300]!,
                    strokeWidth: 0.8,
                    dashArray: value % 2 == 0 ? null : [4, 4],
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: Colors.grey[300]!,
                    strokeWidth: 0.5,
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < sortedData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '${sortedData[index].date.day}/${sortedData[index].date.month}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
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
                      interval: maxY > 5 ? 2 : 1,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.grey.shade400,
                    width: 1,
                  ),
                ),
                minX: 0,
                maxX: (sortedData.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.white,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (spots) {
                      return spots.map((spot) {
                        final dataPoint = sortedData[spot.x.toInt()];
                        final emotion = allEmotions[spot.barIndex];
                        return LineTooltipItem(
                          '${dataPoint.formattedDate}\n',
                          const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: '${emotion.capitalize()}: ${spot.y.toInt()}',
                              style: TextStyle(
                                color: _getEmotionColor(emotion),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
                // Thêm baseline cảnh báo
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: 3,
                      color: Colors.orange.withOpacity(0.6),
                      strokeWidth: 1.5,
                      dashArray: [5, 5],
                      label: HorizontalLineLabel(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 8),
                        labelResolver: (value) => 'Mức cao',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Xây dựng chú thích cảm xúc
  Widget _buildEmotionLegend(List<String> emotions) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: emotions.map((emotion) => 
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getEmotionColor(emotion).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _getEmotionColor(emotion),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                emotion.capitalize(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ).toList(),
    );
  }

  // Cảnh báo trầm cảm
  Widget _buildDepressionWarning() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
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
              style: TextStyle(
                color: Colors.orange[800],
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Kiểm tra dấu hiệu trầm cảm
  bool _checkDepressionWarning(List<EmotionDataPoint> data) {
    if (data.length < 14) return false; // Ít hơn 2 tuần không đánh giá
    
    final negativeEmotions = ['sadness', 'fear', 'anger'];
    int highNegativeDays = 0;
    int lowPositiveDays = 0;

    for (final dp in data.take(14)) { // Chỉ xét 2 tuần gần nhất
      // Kiểm tra cảm xúc tiêu cực cao
      final hasHighNegative = negativeEmotions.any((emotion) => 
        (dp.emotionCounts[emotion] ?? 0) >= 3);
      
      // Kiểm tra cảm xúc tích cực thấp
      final positiveCount = (dp.emotionCounts['joy'] ?? 0) + 
                          (dp.emotionCounts['excitement'] ?? 0);
      
      if (hasHighNegative) highNegativeDays++;
      if (positiveCount <= 1) lowPositiveDays++;
    }

    return highNegativeDays >= 10 || lowPositiveDays >= 12;
  }

  List<LineChartBarData> _createLineBarsData(
    List<EmotionDataPoint> sortedData,
    List<String> allEmotions,
  ) {
    return allEmotions.map((emotion) {
      final isNegative = ['sadness', 'fear', 'anger'].contains(emotion);
      
      return LineChartBarData(
        spots: sortedData.map((dp) {
          return FlSpot(
            sortedData.indexOf(dp).toDouble(),
            dp.emotionCounts[emotion]?.toDouble() ?? 0,
          );
        }).toList(),
        isCurved: true,
        curveSmoothness: 0.3,
        color: _getEmotionColor(emotion),
        barWidth: 3,
        shadow: BoxShadow(
          color: _getEmotionColor(emotion).withOpacity(0.2),
          blurRadius: 8,
          spreadRadius: 2,
        ),
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 4,
              color: _getEmotionColor(emotion),
              strokeWidth: isNegative ? 1.5 : 0,
              strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: isNegative,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _getEmotionColor(emotion).withOpacity(0.3),
              _getEmotionColor(emotion).withOpacity(0.05),
            ],
          ),
        ),
      );
    }).toList();
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'joy': return const Color.fromARGB(255, 255, 251, 3); // green
      case 'sadness': return const Color(0xFF2196F3); // blue
      case 'anger': return const Color(0xFFF44336); // red
      case 'fear': return const Color(0xFF9C27B0); // purple
      case 'surprise': return const Color(0xFFFF9800); // orange
      case 'disgust': return const Color(0xFF8BC34A); // light green
      case 'calm': return const Color.fromARGB(255, 7, 238, 255); // cyan
      case 'excitement': return const Color(0xFFE91E63); // pink
      case 'enjoyment': return const Color.fromARGB(255, 140, 253, 95); // brown
      default: return Colors.grey;
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}