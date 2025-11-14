import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracks/utils/consts.dart';

/// Generic exercise list item widget with checkbox
/// Displays exercise image, name, and subtitle with selection state
class ListItem extends StatelessWidget {
  final String id;
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onChanged;
  final String? imagePath;
  final String? subtitle;

  const ListItem({
    super.key,
    required this.id,
    required this.label,
    required this.isSelected,
    required this.onChanged,
    this.imagePath,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[50],
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (value) => onChanged(value ?? false),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        title: Row(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(12), child: getImage(imagePath)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle ?? "Description not available.",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
