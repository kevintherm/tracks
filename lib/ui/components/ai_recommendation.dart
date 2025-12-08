import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracks/ui/components/buttons/primary_button.dart';

/// Generic AI recommendation banner
/// Can be used in any exercise selection context
class AiRecommendation extends StatelessWidget {
  final VoidCallback onUse;
  final String? title;
  final String? buttonText;

  const AiRecommendation({
    super.key,
    required this.onUse,
    this.title,
    this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16.00),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/ai-weight.svg',
                  width: 20,
                  colorFilter: const ColorFilter.mode(
                    Colors.black87,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title ?? "Try recommendation!",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
            PrimaryButton(
              onTap: onUse,
              child: Text(
                buttonText ?? "Use",
                style: GoogleFonts.inter(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
