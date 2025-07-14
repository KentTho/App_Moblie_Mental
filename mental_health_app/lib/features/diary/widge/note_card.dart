import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mental_health_app/change_notifiers/new_note_controller.dart';
import 'package:mental_health_app/change_notifiers/notes_provider.dart';
import 'package:mental_health_app/features/diary/page/new_or_edit_note_page.dart';
import 'package:mental_health_app/features/diary/widge/note_tag.dart';
import 'package:mental_health_app/models/note.dart';
import 'package:mental_health_app/services/note_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:another_flushbar/flushbar.dart';

import '../core/constants.dart';
import '../core/constants.dart' as Colors;

class NoteCard extends StatelessWidget {
  const NoteCard({
    required this.isInGrid,
    required this.note,
    super.key,
  });

  final bool isInGrid;
  final Note note;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final controller = NewNoteController();
        controller.userId = "1";

        Navigator.push(
          context,
          material.MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
              create: (_) => NewNoteController()..note = note ,
              child: NewOrEditNotePage(
                isNewNote: false,
                note: note,
              ),
            ),
          ),
        );
      },

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: primaryColor, width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(4, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...[
            Text(
              note.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: gray900,
              ),
            ),
            const SizedBox(height: 4),
          ],

            ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: note.tags.map((tag) => NoteTag(label: tag)).toList(),
              ),
            ),
            const SizedBox(height: 4),
          ],

            if(note.content != null)
                isInGrid ?
                   Expanded(
                    child: Text(
                      note.content ?? '',
                      maxLines: isInGrid ? 3 : null,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: gray700),
                    ),
                  )
                : Text(
                    note.content ?? '',
                    style: const TextStyle(color: gray700),
                  ),

                const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    DateFormat('dd/MM/yyyy – HH:mm').format(note.createdAt),
                    style: const TextStyle(
                      color: gray500,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.trash, size: 16, color: gray500),
                  onPressed: () async {
                    try {
                      await NoteService.deleteNote(note.id!);
                      final provider = context.read<NotesProvider>();
                      provider.removeNoteById(note.id!);

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Flushbar(
                          message: "🗑️ Đã xóa ghi chú",
                          duration: const Duration(seconds: 2),
                          margin: const EdgeInsets.all(8),
                          borderRadius: BorderRadius.circular(8),
                          backgroundColor: material.Colors.green.shade600,
                          flushbarPosition: FlushbarPosition.TOP,
                          icon: const Icon(Icons.check_circle, color: Colors.white),
                        ).show(context);
                      });

                    } catch (e) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Flushbar(
                          message: "❌ Lỗi khi xoá: $e",
                          duration: const Duration(seconds: 2),
                          margin: const EdgeInsets.all(8),
                          borderRadius: BorderRadius.circular(8),
                          backgroundColor: material.Colors.redAccent,
                          flushbarPosition: FlushbarPosition.TOP,
                          icon: const Icon(Icons.error, color: Colors.white),
                        ).show(context);
                      });
                    }
                  }

                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
