import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:tracks/ui/components/buttons/primary_button.dart';

class SessionFinishNoteDialog extends StatefulWidget {
  const SessionFinishNoteDialog({super.key});

  @override
  State<SessionFinishNoteDialog> createState() =>
      _SessionFinishNoteDialogState();
}

class _SessionFinishNoteDialogState extends State<SessionFinishNoteDialog> {
  String? _note;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 0,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Note',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),

            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: const TextField(
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'ex: Almost killed myself under the bench...',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),

            const SizedBox(height: 24),

            PrimaryButton(
              onTap: () {
                Navigator.of(context).pop(_note);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Next",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(MingCute.right_line, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
