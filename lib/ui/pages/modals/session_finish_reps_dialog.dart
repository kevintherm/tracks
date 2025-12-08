import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:tracks/ui/components/buttons/primary_button.dart';
import 'package:tracks/ui/components/buttons/tertiary_button.dart';

class SessionFinishRepsDialog extends StatefulWidget {
  final int initialReps;

  const SessionFinishRepsDialog({super.key, this.initialReps = 8});

  @override
  State<SessionFinishRepsDialog> createState() =>
      _SessionFinishRepsDialogState();
}

class _SessionFinishRepsDialogState extends State<SessionFinishRepsDialog> {
  late int _currentReps;

  @override
  void initState() {
    super.initState();
    setState(() {
      _currentReps = widget.initialReps;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'How many reps was that?',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black26),
          ),
          child: NumberPicker(
            value: _currentReps,
            minValue: 1,
            maxValue: 20,
            onChanged: (value) => setState(() => _currentReps = value),
            itemWidth: 60,
            textStyle: GoogleFonts.spaceMono(fontSize: 20, color: Colors.grey),
            selectedTextStyle: GoogleFonts.spaceMono(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
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
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PrimaryButton(
                onTap: () {
                  Navigator.of(context).pop(_currentReps);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Next",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
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
