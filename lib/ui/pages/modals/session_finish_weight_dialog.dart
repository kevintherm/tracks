import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:tracks/ui/components/buttons/primary_button.dart';
import 'package:tracks/ui/components/buttons/tertiary_button.dart';

class SessionFinishWeightDialog extends StatefulWidget {
  const SessionFinishWeightDialog({super.key});

  @override
  State<SessionFinishWeightDialog> createState() =>
      _SessionFinishWeightDialogState();
}

class _SessionFinishWeightDialogState extends State<SessionFinishWeightDialog> {
  double _weight = 25;
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateWeightFromInput(String value) {
    final parsed = double.tryParse(value);
    if (parsed != null && parsed >= 1 && parsed <= 300) {
      setState(() => _weight = parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'How heavy was the weight?',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 24),
        
        TextField(
          controller: _controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
          ],
          decoration: InputDecoration(
            hintText: 'Enter weight (kg)',
            hintStyle: GoogleFonts.inter(color: Colors.grey),
            prefixIcon: Icon(MingCute.search_line),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: GoogleFonts.spaceMono(fontSize: 16),
          onSubmitted: _updateWeightFromInput,
          onChanged: (value) {
            if (value.isNotEmpty) {
              _updateWeightFromInput(value);
            }
          },
        ),
        
        const SizedBox(height: 16),
        
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
                value: _weight.floor(),
                minValue: 1,
                maxValue: 300,
                onChanged: (value) => setState(() => _weight = value + (_weight % 1)),
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
              Text(
                '.',
                style: GoogleFonts.spaceMono(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              NumberPicker(
                value: ((_weight % 1) * 10).round(),
                minValue: 0,
                maxValue: 9,
                onChanged: (value) => setState(() => _weight = _weight.floor() + (value / 10)),
                itemWidth: 40,
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
                'kg',
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
                  Navigator.of(context).pop(_weight);
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
