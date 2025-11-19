import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const List<BoxShadow> _kCardShadow = [
  BoxShadow(
    color: Color(0xFFE0E0E0), // Colors.grey[300]!
    offset: Offset(0, 1),
    blurRadius: 2,
  ),
  BoxShadow(
    color: Color(0xFFF5F5F5), // Colors.grey[200]!
    offset: Offset(0, -2),
    blurRadius: 10,
  ),
];

class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const SectionCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: Colors.white,
          boxShadow: _kCardShadow,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class BasicCard extends StatelessWidget {
  final Widget child;

  const BasicCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: Colors.white,
          boxShadow: _kCardShadow,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            child,
          ],
        ),
      ),
    );
  }
}
