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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'Rate the effort',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black26),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NumberPicker(
                value: _failRate,
                minValue: 1,
                maxValue: 10,
                haptics: true,
                onChanged: (value) => setState(() => _failRate = value),
                itemWidth: 60,
                textStyle: GoogleFonts.spaceMono(
                  fontSize: 20,
                  color: Colors.grey,
                ),
                selectedTextStyle: GoogleFonts.spaceMono(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '/10',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        PrimaryButton(
          onTap: () {
            Navigator.of(context).pop(_failRate);
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
      ],
    );
  }
}
