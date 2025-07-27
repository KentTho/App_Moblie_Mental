// lib/features/suggestions/page/suggestion_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mental_health_app/change_notifiers/suggestion_provider.dart';
import 'package:url_launcher/url_launcher.dart'; // For opening links

class SuggestionListPage extends StatefulWidget {
  const SuggestionListPage({super.key});

  @override
  State<SuggestionListPage> createState() => _SuggestionListPageState();
}

class _SuggestionListPageState extends State<SuggestionListPage> {
  String? _selectedEmotionFilter;
  final List<String> _emotionFilters = [
    'All', 'Joy', 'Sadness', 'Anger', 'Fear', 'Surprise', 'Disgust', 'Calm', 'Excitement', 'Neutral'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSuggestions();
    });
  }

  void _fetchSuggestions() {
    final provider = Provider.of<SuggestionProvider>(context, listen: false);
    provider.fetchSuggestions(
      emotion: _selectedEmotionFilter == 'All' ? null : _selectedEmotionFilter?.toLowerCase(),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  IconData _getIconForSuggestionType(String type) {
    switch (type.toLowerCase()) {
      case 'meditation':
        return Icons.self_improvement;
      case 'music':
        return Icons.music_note;
      case 'article':
        return Icons.article;
      case 'exercise':
        return Icons.fitness_center;
      case 'activity':
        return Icons.local_activity;
      default:
        return Icons.lightbulb_outline;
    }
  }

  Color _getColorForSuggestionType(String type) {
    switch (type.toLowerCase()) {
      case 'meditation':
        return Colors.teal.shade300;
      case 'music':
        return Colors.blue.shade300;
      case 'article':
        return Colors.orange.shade300;
      case 'exercise':
        return Colors.green.shade300;
      case 'activity':
        return Colors.purple.shade300;
      default:
        return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Well-being Suggestions'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: _selectedEmotionFilter,
              decoration: InputDecoration(
                labelText: 'Filter by Emotion',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.filter_list),
              ),
              items: _emotionFilters.map((String filter) {
                return DropdownMenuItem<String>(
                  value: filter,
                  child: Text(filter),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedEmotionFilter = newValue;
                });
                _fetchSuggestions();
              },
            ),
          ),
          Expanded(
            child: Consumer<SuggestionProvider>(
              builder: (context, suggestionProvider, child) {
                if (suggestionProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (suggestionProvider.errorMessage != null) {
                  return Center(
                    child: Text(
                      'Error: ${suggestionProvider.errorMessage}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                if (suggestionProvider.suggestions.isEmpty) {
                  return const Center(
                    child: Text(
                      'No suggestions available at the moment.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: suggestionProvider.suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = suggestionProvider.suggestions[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _getIconForSuggestionType(suggestion.type),
                                  color: _getColorForSuggestionType(suggestion.type),
                                  size: 28,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  suggestion.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              suggestion.description,
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                            ),
                            if (suggestion.link != null && suggestion.link!.isNotEmpty)
                              Align(
                                alignment: Alignment.bottomRight,
                                child: TextButton.icon(
                                  onPressed: () => _launchUrl(suggestion.link!),
                                  icon: const Icon(Icons.open_in_new, size: 18),
                                  label: const Text('Learn More'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.deepPurple,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
