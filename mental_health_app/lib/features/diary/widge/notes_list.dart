import 'package:flutter/cupertino.dart';
import 'package:mental_health_app/models/note.dart';

import 'note_card.dart';

class NotesList extends StatelessWidget {
  const NotesList({
    required this.notes,
    super.key
  });

  final List<Note> notes;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: notes.length,
      clipBehavior: Clip.none,
      itemBuilder: (context, index) {
        return NoteCard(note: notes[index],isInGrid: true,);
      },
      separatorBuilder:
          (context, index) => SizedBox(
        height: 8,
      ),
    );
  }
}

