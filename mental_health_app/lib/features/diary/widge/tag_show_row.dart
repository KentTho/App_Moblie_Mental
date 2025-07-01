import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mental_health_app/features/diary/core/constants.dart';
import 'package:mental_health_app/features/diary/widge/note_icon_button.dart';

class TagShowRow extends StatelessWidget {
  final String label;
  final List<String> tags;
  final VoidCallback onAddTag;

  const TagShowRow({
    super.key,
    required this.label,
    required this.tags,
    required this.onAddTag,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label: "Tags"
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: gray500,
              ),
            ),
          ),
          // Tags or "No tags added" + Add Button
          Expanded(
            flex: 5,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (tags.isEmpty)
                  const Text(
                    'No tags added',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                else
                  ...tags.map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                NoteIconButton(
                  icon: FontAwesomeIcons.circlePlus,
                  size: 20,
                  onPressed: onAddTag,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
