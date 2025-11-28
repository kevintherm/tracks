import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:tracks/ui/components/buttons/primary_button.dart';

class SelectSetsRepsModal extends StatefulWidget {
  final int? initialSets;
  final int? initialReps;
  final bool canPop;

  const SelectSetsRepsModal({
    super.key,
    this.canPop = false,
    this.initialSets,
    this.initialReps,
  });

  @override
  State<SelectSetsRepsModal> createState() => _SelectSetsRepsModalState();
}

class _SelectSetsRepsModalState extends State<SelectSetsRepsModal> {
  int sets = 3;
  int reps = 8;

  @override
  void initState() {
    super.initState();
    if (widget.initialSets != null) {
      sets = widget.initialSets!;
    }

    if (widget.initialReps != null) {
      reps = widget.initialReps!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.canPop,
      child: _ModalPadding(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pick Sets & Reps',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 24),

            Row(
                children: [
                  Expanded(
                    child: _buildPicker(
                      label: "Sets",
                      value: sets,
                      onChanged: (v) {
                        setState(() => sets = v);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPicker(
                      label: "Reps",
                      value: reps,
                      onChanged: (v) {
                        setState(() => reps = v);
                      },
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            PrimaryButton(
              onTap: () => Navigator.of(context).pop((sets, reps)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Select",
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
        ),
      ),
    );
  }

  Widget _buildPicker({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black26),
          ),
          child: Center(
            child: NumberPicker(
              value: value,
              minValue: 1,
              maxValue: 20,
              haptics: false,
              axis: Axis.horizontal,
              itemWidth: 50,
              itemHeight: 50,
              textStyle: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[400],
              ),
              selectedTextStyle: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _ModalPadding extends StatelessWidget {
  final Widget child;

  const _ModalPadding({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32, left: 16, right: 16, top: 24),
      child: child,
    );
  }
}
