import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mental_health_app/change_notifiers/notes_provider.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';

class SearchField extends StatefulWidget {
  const SearchField({super.key});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      context.read<NotesProvider>().filterNotes(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search notes...',
        hintStyle: TextStyle(color: gray500),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 8.0),
          child: FaIcon(
            FontAwesomeIcons.magnifyingGlass,
            size: 18,
            color: gray700,
          ),
        ),
        prefixIconConstraints: BoxConstraints(
          minWidth: 0,
          minHeight: 0,
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: FaIcon(FontAwesomeIcons.xmark, size: 18, color: gray700),
                onPressed: () {
                  _searchController.clear();
                },
              )
            : null,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
      style: TextStyle(color: primaryColor),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
