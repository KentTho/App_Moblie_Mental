import 'package:flutter/material.dart';
import 'package:mental_health_app/change_notifiers/notes_provider.dart';
import 'package:mental_health_app/features/diary/screen/note_detail_screen.dart';
import 'package:mental_health_app/models/note.dart';
import 'package:provider/provider.dart';

class NotesSearchDelegate extends SearchDelegate<Note?> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (context, notesProvider, child) {
        final filteredNotes = notesProvider.notes.where((note) {
          final titleMatch = note.title.toLowerCase().contains(query.toLowerCase());
          final contentMatch = (note.content ?? '').toLowerCase().contains(query.toLowerCase());
          final tagMatch = note.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
          
          return titleMatch || contentMatch || tagMatch;
        }).toList();

        if (query.isEmpty) {
          return const Center(
            child: Text(
              'Enter search terms to find notes',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        if (filteredNotes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No notes found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredNotes.length,
          itemBuilder: (context, index) {
            final note = filteredNotes[index];
            return ListTile(
              title: Text(
                note.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (note.content != null && note.content!.isNotEmpty)
                    Text(
                      note.content!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  if (note.tags.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      children: note.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.deepPurple[700],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
              trailing: Text(
                _formatDate(note.updatedAt),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              onTap: () {
                close(context, note);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteDetailScreen(note: note),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
