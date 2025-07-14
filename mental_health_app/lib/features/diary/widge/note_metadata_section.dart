// note_metadata_section.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mental_health_app/features/diary/widge/buildRow_newEdit.dart';
import 'package:mental_health_app/features/diary/widge/tag_show_row.dart';
import 'package:mental_health_app/models/note.dart';

class NoteMetadataSection extends StatelessWidget {
  const NoteMetadataSection({
    super.key,
    required this.isNewNote,
    required this.note,
    required this.tags,
    required this.onAddTag,
  });

  final bool isNewNote;
  final Note? note;
  final List<String> tags;
  final void Function(String) onAddTag;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isNewNote && note != null) ...[
          BuildRowNewEdit(
            label: "Last Modified",
            value: DateFormat('dd MMM yyyy, HH:mm').format(note!.updatedAt),
          ),
          BuildRowNewEdit(
            label: "Created",
            value: DateFormat('dd MMM yyyy, HH:mm').format(note!.createdAt),
          ),
        ],
        TagShowRow(
          label: "Tags",
          tags: tags,
          onAddTag: onAddTag,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 9.0),
          child: Divider(
            color: Colors.grey,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
