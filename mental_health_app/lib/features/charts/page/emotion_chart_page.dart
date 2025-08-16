import 'package:flutter/material.dart';
import 'package:mental_health_app/features/home/homepage.dart';
import 'package:provider/provider.dart';
import 'package:mental_health_app/change_notifiers/chart_provider.dart';
import 'package:mental_health_app/models/emotion_chart_model.dart';
import 'emotion_pie_chart.dart';

class EmotionChartPage extends StatefulWidget {
  const EmotionChartPage({super.key});

  @override
  State<EmotionChartPage> createState() => _EmotionChartPageState();
}

class _EmotionChartPageState extends State<EmotionChartPage> {
  int selectedDays = 3;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<ChartProvider>(context, listen: false);
      await provider.fetchEmotionChartData(context, days: selectedDays);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleDaysChange(int? value) {
    if (value != null) {
      setState(() => selectedDays = value);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2E7D32)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Homepage()),
            );
          },
        ),
        title: const Text(
          'Biểu đồ Cảm xúc',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        actions: [_buildTimeRangeDropdown()],
      ),

      body: _buildBodyContent(),
    );
  }

  Widget _buildTimeRangeDropdown() {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedDays,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2E7D32)),
          items: [1, 3, 7, 14]
              .map((days) => DropdownMenuItem(
                    value: days,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('$days ngày', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                    ),
                  ))
              .toList(),
          onChanged: _handleDaysChange,
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    return Consumer<ChartProvider>(
      builder: (context, chartProvider, _) {
        if (_isLoading) return _buildLoadingState();
        if (chartProvider.errorMessage != null) return _buildErrorState(chartProvider);
        if (chartProvider.emotionChartData?.data.isEmpty ?? true) return _buildEmptyState();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildEmotionChartCard(chartProvider),
              const SizedBox(height: 20),
              _buildStatsSummary(chartProvider),
              const SizedBox(height: 20),
              _buildDailyEmotionList(chartProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF2E7D32)),
          SizedBox(height: 16),
          Text('Đang tải dữ liệu cảm xúc...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildErrorState(ChartProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            'Lỗi khi tải dữ liệu: ${provider.errorMessage}',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _loadData,
            child: const Text('Thử lại', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/empty_chart.png', width: 150),
          const SizedBox(height: 20),
          const Text(
            'Chưa có dữ liệu cảm xúc',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Hãy bắt đầu ghi chép cảm xúc hàng ngày để xem thống kê',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/journal'),
            icon: const Icon(Icons.edit, color: Colors.white),
            label: const Text('Ghi chép ngay', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionChartCard(ChartProvider provider) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.greenAccent.shade100, Colors.green.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade100.withOpacity(0.6),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.insights, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Xu hướng cảm xúc',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 420,
            child: EmotionPieChart(data: provider.emotionChartData!.data),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(ChartProvider provider) {
    final dominantEmotion = _getDominantEmotion(provider.emotionChartData!.data);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 6)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.analytics, color: Color(0xFF2E7D32)),
              SizedBox(width: 8),
              Text(
                'Tổng quan cảm xúc',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatItem(
                'Cảm xúc chủ đạo',
                StringExtension(dominantEmotion.name).capitalize(),
                _getEmotionColor(dominantEmotion.name),
                dominantEmotion.count,
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                'Ngày tích cực',
                _countPositiveDays(provider.emotionChartData!.data).toString(),
                Colors.green,
                null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, Color color, int? count) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (count != null) ...[
                  const SizedBox(width: 4),
                  Text('($count lần)', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyEmotionList(ChartProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: provider.emotionChartData!.data.map((dataPoint) {
        final dominantEmotion = dataPoint.emotionCounts.entries.isNotEmpty
            ? dataPoint.emotionCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
            : 'calm';
        final gradientColor = _getEmotionColor(dominantEmotion).withOpacity(0.3);
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [gradientColor, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: gradientColor.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
            ],
          ),
          child: ExpansionTile(
            title: Text(
              dataPoint.formattedDate,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            children: dataPoint.emotionCounts.entries.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Chip(
                  label: Text('${StringExtension(e.key).capitalize()}: ${e.value}'),
                  backgroundColor: _getEmotionColor(e.key).withOpacity(0.2),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  DominantEmotion _getDominantEmotion(List<EmotionDataPoint> data) {
    if (data.isEmpty) return DominantEmotion('unknown', 0);
    final emotionCounts = <String, int>{};
    for (final day in data) {
      for (final entry in day.emotionCounts.entries) {
        emotionCounts[entry.key] = (emotionCounts[entry.key] ?? 0) + entry.value;
      }
    }
    if (emotionCounts.isEmpty) return DominantEmotion('unknown', 0);
    final dominantEntry = emotionCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
    return DominantEmotion(dominantEntry.key, dominantEntry.value);
  }

  int _countPositiveDays(List<EmotionDataPoint> data) {
    const positiveEmotions = ['joy', 'excitement', 'calm'];
    return data.where((day) {
      final positiveCount = day.emotionCounts.entries
          .where((e) => positiveEmotions.contains(e.key))
          .fold(0, (sum, e) => sum + e.value);
      return positiveCount > 0;
    }).length;
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
      default:
        return Icons.sentiment_neutral;
    }
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
}

class DominantEmotion {
  final String name;
  final int count;
  DominantEmotion(this.name, this.count);
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
