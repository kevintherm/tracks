import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:tracks/ui/components/buttons/primary_button.dart';
import 'package:tracks/ui/components/buttons/secondary_button.dart';

class SessionFinishFailureDialog extends StatefulWidget {
  const SessionFinishFailureDialog({super.key});

  @override
  State<SessionFinishFailureDialog> createState() =>
      _SessionFinishFailureDialogState();
}

class _SessionFinishFailureDialogState
    extends State<SessionFinishFailureDialog> {
  int _failOnRep = 6;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'Failure on repetition?',
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
            value: _failOnRep,
            minValue: 1,
            maxValue: 20,
            onChanged: (value) => setState(() => _failOnRep = value),
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
              child: SecondaryButton(
                onTap: () {
                  Navigator.of(context).pop(-1);
                },
                child: Text(
                  "No Fail",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PrimaryButton(
                onTap: () {
                  Navigator.of(context).pop(_failOnRep);
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
