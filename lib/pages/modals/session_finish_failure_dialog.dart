import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:tracks/components/buttons/primary_button.dart';
import 'package:tracks/components/buttons/secondary_button.dart';

class SessionFinishFailureDialog extends StatefulWidget {
  const SessionFinishFailureDialog({super.key});

  @override
  State<SessionFinishFailureDialog> createState() => _SessionFinishFailureDialogState();
}

class _SessionFinishFailureDialogState extends State<SessionFinishFailureDialog> {
  int _failOnRep = 6;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0)),
      elevation: 0,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Set to failure?',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),

            NumberPicker(
              value: _failOnRep,
              minValue: 1,
              maxValue: 20,
              onChanged: (value) => setState(() => _failOnRep = value),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black26),
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
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PrimaryButton(
                    onTap: () {
                      Navigator.of(context).pop(_failOnRep);
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
        ),
      ),
    );
  }
}
