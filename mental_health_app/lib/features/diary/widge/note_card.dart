import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mental_health_app/features/diary/page/new_or_edit_note_page.dart';
import 'package:mental_health_app/features/diary/widge/note_tag.dart';
import 'package:mental_health_app/models/note.dart';
import 'package:mental_health_app/services/note_service.dart';

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
      // 👉 Điều hướng sang trang chỉnh sửa note khi người dùng nhấn vào thẻ
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewOrEditNotePage(
              isNewNote: false,
              note: note, // 👈 truyền ghi chú vào
            ),
          ),
        );
      },


      // 📦 Thẻ note (giao diện chính)
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

        // 📄 Nội dung bên trong thẻ
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📝 Tiêu đề ghi chú
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

            // 🏷️ Danh sách tag (chạy ngang)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: note.tags.map((tag) => NoteTag(label: tag)).toList(),
              ),
            ),

            const SizedBox(height: 4),

            // 📝 Nội dung mô tả (ẩn bớt nếu ở dạng grid)
            if (isInGrid)
              Expanded(
                child: Text(
                  note.content ?? '',
                  maxLines: isInGrid ? 3 : null,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: gray700),
                ),
              )
            else
              Text(
                note.content ?? '',
                style: TextStyle(color: gray700),
              ),

            const SizedBox(height: 8),

            // 📅 Ngày tạo & 🗑️ Nút xóa
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                Text(
                    "${note.createdAt.day}/${note.createdAt.month}/${note.createdAt.year}",
                    style: const TextStyle(
                    color: gray500,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                IconButton(
                icon: const FaIcon(FontAwesomeIcons.trash, size: 16, color: gray500),
                onPressed: () async {
                  try {
                    await NoteService.deleteNote(note.id!);
                    // Sau khi xóa → gọi lại fetchNotes hoặc remove local
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("🗑️ Đã xóa ghi chú")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("❌ Lỗi khi xoá: $e")),
                    );
                  }
                },
              )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

