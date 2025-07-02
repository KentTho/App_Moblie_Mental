import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mental_health_app/features/diary/page/new_or_edit_note_page.dart';

import '../core/constants.dart';
import '../core/constants.dart' as Colors;

class NoteCard extends StatelessWidget {
  const NoteCard({
    required this.isInGrid,
    super.key,
  });

  final bool isInGrid;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 👉 Điều hướng sang trang chỉnh sửa note khi người dùng nhấn vào thẻ
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NewOrEditNotePage(isNewNote: false),
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
            const Text(
              'This is going to be a title',
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
                children: List.generate(
                  3,
                  (index) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: gray100,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    margin: const EdgeInsets.only(right: 4),
                    child: const Text(
                      'First chip',
                      style: TextStyle(
                        fontSize: 12,
                        color: gray700,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 4),

            // 📝 Nội dung mô tả (ẩn bớt nếu ở dạng grid)
            if (isInGrid)
              Expanded(
                child: Text(
                  'Some content',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: gray700),
                ),
              )
            else
              const Text(
                'Some content',
                style: TextStyle(color: gray700),
              ),

            const SizedBox(height: 8),

            // 📅 Ngày tạo & 🗑️ Nút xóa
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  '02 November',
                  style: TextStyle(
                    color: gray500,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                FaIcon(
                  FontAwesomeIcons.trash,
                  size: 16,
                  color: gray500,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
