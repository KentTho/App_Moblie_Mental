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
                Row(
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
                    DropdownButton(
                      value: dropdownValue,
                      items: dropdownOptions
                          .map((e) =>
                          DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                          .toList(),
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
                    ),
                  ],
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
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(blurRadius: 4, color: Colors.black12),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('This is going to be a title',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Chip(label: Text('First chip')),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text('Some content'),
                            Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('02 November'),
                                FaIcon(FontAwesomeIcons.trash, size: 16),
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
