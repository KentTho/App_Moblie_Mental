import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: primaryColor, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              blurRadius: 4,
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(4, 4)
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('This is going to be a title',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: gray900,
            ),
          ),
          SizedBox(height: 4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(3, (index) =>
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: gray100),
                    padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2),
                    margin: EdgeInsets.only(right: 4),
                    child: Text('First chip',
                      style: TextStyle(
                          fontSize: 12,
                          color: gray700
                      ),
                    ),
                  ),
              ),
            ),
          ),
          SizedBox(height: 4),
          if(isInGrid)
            Expanded(
              child: Text(
                'Some content',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: gray700
                ),
              ),
            )
          else
            Text('Some content',
              style: TextStyle(
                  color: gray700
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('02 November',
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
    );
  }
}