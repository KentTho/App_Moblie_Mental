import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mental_health_app/features/diary/constants.dart';


class EmotionEntry extends StatefulWidget{
    const EmotionEntry({super.key});

    @override
  State<EmotionEntry> createState() => _EmotionEntryState();
}
  class _EmotionEntryState extends State<EmotionEntry> {


    final List<String> dropdownOptions = ['Data modified', 'Date created'];
    late String dropdownValue = dropdownOptions.first;


    @override
    Widget build(BuildContext context) {
      return Theme(
        data: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          scaffoldBackgroundColor: background,
        ),
        child: Scaffold(
          appBar: AppBar(
            title: Text("Emotion Entry 📒"),
            backgroundColor: Colors.transparent,
            titleTextStyle: TextStyle(
              color: primaryColor,
              fontSize: 32,
              fontFamily: 'Fredoka',
              fontWeight: FontWeight.bold,
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: FaIcon(FontAwesomeIcons.rightFromBracket),
                style: IconButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: black, width: 2),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.large(
            onPressed: () {},
            child: FaIcon(FontAwesomeIcons.plus),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                      hintText: 'Search notes .....',
                      hintStyle: TextStyle(fontSize: 16),
                      prefixIcon: Icon(FontAwesomeIcons.magnifyingGlass, size: 17,),
                      fillColor: Colors.white,
                      filled:  true,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      prefixIconConstraints: BoxConstraints(minWidth: 42, minHeight: 42),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor)
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor)
                      ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: FaIcon(FontAwesomeIcons.arrowDown),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        constraints: BoxConstraints(),
                        style: IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap,),
                        iconSize: 18,
                        color: gray700,
                      ),
                      SizedBox(width: 16),
                      DropdownButton(
                        value: dropdownValue,
                        icon: Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: FaIcon(
                            FontAwesomeIcons.arrowDownWideShort,
                            size: 18,
                            color: gray700,
                          ),
                        ),
                        underline: SizedBox.shrink(),
                        borderRadius: BorderRadius.circular(16),
                        isDense: true,
                        items: dropdownOptions
                            .map((e) =>
                            DropdownMenuItem(
                              value: e,
                              child: Row(
                                children: [
                                  Text(e),
                                  if( e == dropdownValue) ...[
                                    SizedBox(width: 8),
                                    Icon(Icons.check, color: primaryColor)
                                  ],
                                ],
                              ),
                            ))
                            .toList(),
                        selectedItemBuilder: (context) => dropdownOptions.map((e) => Text(e)).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            dropdownValue = newValue!;
                          });
                        },
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: FaIcon(FontAwesomeIcons.bars),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        constraints: BoxConstraints(),
                        style: IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap,),
                        iconSize: 18,
                        color: gray700,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    itemCount: 15,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: primaryColor, width: 2),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 4,
                                color: Colors.black12.withOpacity(0.5),
                              offset: Offset(4, 4)
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('This is going to be a title',
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
                                          vertical: 4),
                                      margin: EdgeInsets.only(right: 8),
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
                            Expanded(
                              child: Text('Some content',
                                style: TextStyle(
                                    color: gray700
                                ),
                              ),
                            ),
                            Spacer(),
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
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
