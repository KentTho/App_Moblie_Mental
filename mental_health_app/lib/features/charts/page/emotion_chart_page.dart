import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mental_health_app/change_notifiers/chart_provider.dart';
import 'package:mental_health_app/models/emotion_chart_model.dart';
import 'emotion_line_chart.dart';

class EmotionChartPage extends StatefulWidget {
  const EmotionChartPage({super.key});

  @override
  State<EmotionChartPage> createState() => _EmotionChartPageState();
}

class _EmotionChartPageState extends State<EmotionChartPage> {
  int selectedDays = 3; // Mặc định 7 ngày
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
      appBar: AppBar(
        title: const Text('Biểu đồ Cảm xúc'),
        centerTitle: true,
        actions: [_buildTimeRangeDropdown()],
      ),
      body: _buildBodyContent(),
    );
  }

  Widget _buildTimeRangeDropdown() {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedDays,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
          items: [1, 3, 7, 14].map((days) => DropdownMenuItem(
            value: days,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('$days ngày', style: const TextStyle(fontSize: 14)),
            ),
          )).toList(),
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
          CircularProgressIndicator(),
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
            onPressed: _loadData,
            child: const Text('Thử lại'),
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
            icon: const Icon(Icons.edit),
            label: const Text('Ghi chép ngay'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionChartCard(ChartProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.insights, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text(
                  'Xu hướng cảm xúc ($selectedDays ngày)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 280,
              child: EmotionLineChart(data: provider.emotionChartData!.data),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSummary(ChartProvider provider) {
    final dominantEmotion = _getDominantEmotion(provider.emotionChartData!.data);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: Colors.deepPurple),
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
      ),
    );
  }

  Widget _buildStatItem(String title, String value, Color color, int? count) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (count != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    '($count lần)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
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
      children: [
        const Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.deepPurple, size: 18),
            SizedBox(width: 8),
            Text(
              'Chi tiết theo ngày',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: provider.emotionChartData!.data.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final dataPoint = provider.emotionChartData!.data[index];
            return _buildDayEmotionCard(dataPoint);
          },
        ),
      ],
    );
  }

  Widget _buildDayEmotionCard(EmotionDataPoint dataPoint) {
    final isToday = dataPoint.date.isAtSameMomentAs(DateTime.now().toLocal());
    
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ExpansionTile(
        title: Text(
          dataPoint.formattedDate,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isToday ? Colors.deepPurple : Colors.black,
          ),
        ),
        leading: isToday 
            ? const Icon(Icons.today, color: Colors.deepPurple)
            : const Icon(Icons.calendar_today, size: 20),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: dataPoint.emotionCounts.entries.map((entry) => Chip(
              backgroundColor: _getEmotionColor(entry.key).withOpacity(0.2),
              label: Text(
                '${StringExtension(entry.key).capitalize()}: ${entry.value}',
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 13,
                ),
              ),
              avatar: CircleAvatar(
                backgroundColor: _getEmotionColor(entry.key),
                radius: 10,
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  // Helper functions
  DominantEmotion _getDominantEmotion(List<EmotionDataPoint> data) {
  if (data.isEmpty) return DominantEmotion('unknown', 0); // tránh reduce() lỗi

  final emotionCounts = <String, int>{};

  for (final day in data) {
    for (final entry in day.emotionCounts.entries) {
      emotionCounts[entry.key] = (emotionCounts[entry.key] ?? 0) + entry.value;
    }
  }

  if (emotionCounts.isEmpty) return DominantEmotion('unknown', 0); // tránh reduce() lỗi

  final dominantEntry = emotionCounts.entries.reduce(
    (a, b) => a.value > b.value ? a : b,
  );

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