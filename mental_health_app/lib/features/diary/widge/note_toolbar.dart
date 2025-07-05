import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mental_health_app/features/diary/core/constants.dart';

class NoteToolbar extends StatelessWidget {
  const NoteToolbar({
    super.key,
    required QuillController controller,
  }) : _controller = controller;

  final QuillController _controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: white, 
        border: Border.all(
          color: primaryColor,
          strokeAlign: BorderSide.strokeAlignOutside),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: primaryColor, offset: Offset(4, 4))]
      ),
      child: QuillSimpleToolbar(
        controller: _controller,
        config: QuillSimpleToolbarConfig(
          multiRowsDisplay: false,
          showFontFamily: false,
          showFontSize: false,
          showSubscript: false,
          showSuperscript: false,
          showSmallButton: false,
          showInlineCode: false,
          showAlignmentButtons: false,
          showDirection: false,
          showDividers: false,
          showHeaderStyle: false,
          showListCheck: false,
          showCodeBlock: false,
          showQuote: false,
          showIndent: false,
          showLink: false,
          showUndo: true,
          showRedo: true,
          showBoldButton: true,
          showItalicButton: true,
          showUnderLineButton: true,
          showColorButton: true,
          buttonOptions: QuillSimpleToolbarButtonOptions(
            undoHistory: QuillToolbarHistoryButtonOptions(
              iconData: FontAwesomeIcons.arrowRotateLeft,
              iconSize: 18
            ),
            redoHistory: QuillToolbarHistoryButtonOptions(
              iconData: FontAwesomeIcons.arrowRotateRight,
              iconSize: 18
            ),
            bold: QuillToolbarToggleStyleButtonOptions(
              iconData: FontAwesomeIcons.bold,
              iconSize: 18
            ),
            italic: QuillToolbarToggleStyleButtonOptions(
              iconData: FontAwesomeIcons.italic,
              iconSize: 18
            ),
            underLine: QuillToolbarToggleStyleButtonOptions(
              iconData: FontAwesomeIcons.underline,
              iconSize: 18
            ),
            strikeThrough: QuillToolbarToggleStyleButtonOptions(
              iconData: FontAwesomeIcons.strikethrough,
              iconSize: 18
            ),
            color: QuillToolbarColorButtonOptions(
              iconData: FontAwesomeIcons.palette,
              iconSize: 18
            ),
            backgroundColor: QuillToolbarColorButtonOptions(
              iconData: FontAwesomeIcons.fillDrip,
              iconSize: 18
            ),
            clearFormat: QuillToolbarClearFormatButtonOptions(
              iconData: FontAwesomeIcons.textSlash,
              iconSize: 18
            ),
            listNumbers: QuillToolbarToggleStyleButtonOptions(
              iconData: FontAwesomeIcons.listOl,
              iconSize: 18
            ),
            listBullets: QuillToolbarToggleStyleButtonOptions(
              iconData: FontAwesomeIcons.listUl,
              iconSize: 18
            ),
            search: QuillToolbarSearchButtonOptions(
              iconData: FontAwesomeIcons.magnifyingGlass,
              iconSize: 18
            )
          )
        ),
      ),
    );
  }
}