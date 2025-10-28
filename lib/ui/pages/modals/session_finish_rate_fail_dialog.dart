import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:tracks/ui/components/buttons/primary_button.dart';

class SessionFinishRateFailDialog extends StatefulWidget {
  const SessionFinishRateFailDialog({super.key});

  @override
  State<SessionFinishRateFailDialog> createState() =>
      _SessionFinishRateFailDialogState();
}

class _SessionFinishRateFailDialogState
    extends State<SessionFinishRateFailDialog> {
  int _failRate = 1;

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
              'Rate the struggle',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),

            NumberPicker(
              value: _failRate,
              minValue: 1,
              maxValue: 5,
              haptics: true,
              axis: Axis.horizontal,
              onChanged: (value) => setState(() => _failRate = value),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black26),
              ),
            ),

            const SizedBox(height: 24),

            PrimaryButton(
              onTap: () {
                Navigator.of(context).pop(_failRate);
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
