import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mental_health_app/change_notifiers/new_note_controller.dart';
import 'package:mental_health_app/change_notifiers/notes_provider.dart';
import 'package:mental_health_app/features/diary/widgets/emotion_chips.dart';
import 'package:mental_health_app/models/note.dart';
import 'package:provider/provider.dart';// Import NewNoteController
import '../core/constants.dart'; // Import constants
import '../page/new_or_edit_note_page.dart'; // Import the new page


class NoteDetailScreen extends StatefulWidget {
  final Note note;
  
  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late QuillController _quillController;
  late var note = widget.note;

  @override
  void initState() {
    super.initState();
    note = widget.note;
    _initializeQuillController();
  }

  void _initializeQuillController() {
    Document document;
    
    if (widget.note.contentJson != null && widget.note.contentJson!.isNotEmpty) {
      try {
        final jsonData = jsonDecode(widget.note.contentJson!);
        document = Document.fromJson(jsonData);
      } catch (e) {
        // Fallback to plain text if JSON parsing fails
        document = Document()..insert(0, widget.note.content ?? '');
      }
    } else if (widget.note.content != null && widget.note.content!.isNotEmpty) {
      document = Document()..insert(0, widget.note.content!);
    } else {
      document = Document();
    }
    
    _quillController = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
Widget build(BuildContext context) {
  return Theme(
    data: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    ),
    child: Scaffold(
      appBar: AppBar(
        title: Text(
          widget.note.title,
          style: const TextStyle(
            color: primaryColor,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Fredo',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: primaryColor),
            onPressed: () {
              final controller = context.read<NewNoteController>();
              controller.note = widget.note;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider.value(
                    value: controller,
                    child: const NewOrEditNotePage(isNewNote: false),
                  ),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: gray700),
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteDialog();
              } else if (value == 'share') {
                _shareNote();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share, size: 20),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.note.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const FaIcon(FontAwesomeIcons.clock, size: 14, color: gray500),
                const SizedBox(width: 4),
                Text('Created: ${_formatDate(widget.note.createdAt)}', style: const TextStyle(fontSize: 12, color: gray500)),
                const SizedBox(width: 16),
                const FaIcon(FontAwesomeIcons.penToSquare, size: 14, color: gray500),
                const SizedBox(width: 4),
                Text('Updated: ${_formatDate(widget.note.updatedAt)}', style: const TextStyle(fontSize: 12, color: gray500)),
              ],
            ),
            if (widget.note.tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: widget.note.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: primaryColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12,
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            // ✅ NEW: Display Emotions
            if (widget.note.emotions != null && widget.note.emotions!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Emotions:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: gray700,
                ),
              ),
              const SizedBox(height: 8),
              EmotionChips(emotions: widget.note.emotions ?? []),
              // Wrap(
              //   spacing: 8,
              //   runSpacing: 4,
              //   children: widget.note.emotions!.map((emotion) {
              //     return Container(
              //       padding: const EdgeInsets.symmetric(
              //         horizontal: 12,
              //         vertical: 6,
              //       ),
              //       decoration: BoxDecoration(
              //         color: Colors.blueGrey.withOpacity(0.1), // Different color for emotions
              //         borderRadius: BorderRadius.circular(16),
              //         border: Border.all(
              //           color: Colors.blueGrey.withOpacity(0.3),
              //         ),
              //       ),
              //       child: Text(
              //         emotion.toUpperCase(), // Display emotion in uppercase
              //         style: const TextStyle(
              //           fontSize: 12,
              //           color: Colors.blueGrey,
              //           fontWeight: FontWeight.w500,
              //         ),
              //       ),
              //     );
              //   }).toList(),
              // ),          
            ],
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: QuillEditor(
                controller: _quillController,
                config: const QuillEditorConfig(
                  showCursor: false,
                  autoFocus: false,
                ),
                focusNode: FocusNode(),
                scrollController: ScrollController(),
              ),
            ),
            if (widget.note.sentiment != null && widget.note.sentiment!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.psychology, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Sentiment: ${widget.note.sentiment}',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}


  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${widget.note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await context.read<NotesProvider>().deleteNote(widget.note.id!);
              if (mounted) {
                Navigator.pop(context); // Go back to list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note deleted successfully')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _shareNote() {
    // Implement share functionality
    final content = _quillController.document.toPlainText();
    final shareText = '${widget.note.title}\n\n$content';
    
    // You can use share_plus package for actual sharing
    // Share.share(shareText);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality - implement with share_plus package')),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _quillController.dispose();
    super.dispose();
  }
}
