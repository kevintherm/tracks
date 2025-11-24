import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:tracks/ui/components/buttons/primary_button.dart';
import 'package:tracks/ui/components/buttons/tertiary_button.dart';

class SessionFinishRepsDialog extends StatefulWidget {
  const SessionFinishRepsDialog({super.key});

  @override
  State<SessionFinishRepsDialog> createState() =>
      _SessionFinishRepsDialogState();
}

class _SessionFinishRepsDialogState extends State<SessionFinishRepsDialog> {
  int _currentReps = 6;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'How many reps was that?',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 24),
        
        NumberPicker(
          value: _currentReps,
          minValue: 1,
          maxValue: 20,
          onChanged: (value) => setState(() => _currentReps = value),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black26),
          ),
        ),
        
        const SizedBox(height: 24),
        
        Row(
          children: [
            Expanded(
              child: TertiaryButton(
                onTap: () {
                  Navigator.of(context).pop(null);
                },
                child: Text(
                  "Cancel",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: PrimaryButton(
                onTap: () {
                  Navigator.of(context).pop(_currentReps);
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
            ),
          ],
        ),
      ],
    );
  }
}
