import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mental_health_app/change_notifiers/new_note_controller.dart';
import 'package:mental_health_app/features/diary/core/constants.dart';
import 'package:mental_health_app/features/diary/widge/dialog_tags_card.dart';
import 'package:mental_health_app/features/diary/widge/new_notes_dialog.dart';
import 'package:mental_health_app/features/diary/widge/note_icon_button.dart';
import 'package:mental_health_app/features/diary/widge/note_tag.dart';
import 'package:provider/provider.dart';

class TagShowRow extends StatefulWidget {
  final String label;
  final List<String> tags;
  final void Function(String tag) onAddTag; // ✅ sửa từ VoidCallback → truyền tag

  const TagShowRow({
    super.key,
    required this.label,
    required this.tags,
    required this.onAddTag,
  });

  @override
  State<TagShowRow> createState() => _TagShowRowState();
}

class _TagShowRowState extends State<TagShowRow> {
  final TextEditingController _tagController = TextEditingController();

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }


  @override
Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
    child: Row(
      children: [
        // "Tags" label
        Text(
          widget.label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: gray500,
          ),
        ),

        // Nút [+]
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: NoteIconButton(
            icon: FontAwesomeIcons.circlePlus,
            size: 20,
            onPressed: () async {
              final String? tag = await showDialog<String>(
                context: context,
                builder: (context) => DialogCard(
                  onTagAdded: (String tag) {
                    Navigator.pop(context, tag);
                    widget.onAddTag(tag);
                  },
                  child: NewNoteDiaLog(
                    tagController: _tagController,
                    onTagAdded: (String tag) {
                      Navigator.pop(context, tag);
                      widget.onAddTag(tag);
                    },
                  ),
                ),
              );
              if (tag != null) {
                Provider.of<NewNoteController>(context, listen: false).addTag(tag);
              }
            },
          ),
        ),
        const SizedBox(width: 60,),
        // Danh sách tag
        Expanded(
          child: Selector<NewNoteController, List<String>>(
            selector: (_, controller) => controller.tags,
            builder: (_, tags, __) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: tags.isEmpty
                      ? [
                          const Text(
                            'No tags added',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ]
                      : tags.asMap().entries.map((entry) {
                          int index = entry.key;
                          String tag = entry.value;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: NoteTag(
                              label: tag,
                              onCLosed: () {
                                Provider.of<NewNoteController>(context, listen: false).removeTag(index);
                              },
                            ),
                          );
                        }).toList(),

                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

  
}

