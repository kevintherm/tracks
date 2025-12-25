import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';

enum ConfirmType { action, delete }

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.itemName,
    required this.confirmType,
    required this.entityType,
  });

  final String itemName;
  final ConfirmType confirmType;
  final String entityType;

  IconData get _icon {
    switch (confirmType) {
      case ConfirmType.action:
        return Iconsax.info_circle_outline;
      case ConfirmType.delete:
        return Iconsax.trash_outline;
    }
  }

  Color get _iconColor {
    switch (confirmType) {
      case ConfirmType.action:
        return Colors.blue[400]!;
      case ConfirmType.delete:
        return Colors.red[400]!;
    }
  }

  String get _title {
    switch (confirmType) {
      case ConfirmType.action:
        return 'Confirm Action';
      case ConfirmType.delete:
        return 'Delete $entityType?';
    }
  }

  String get _message {
    switch (confirmType) {
      case ConfirmType.action:
        return 'Are you sure you want to proceed with this action?';
      case ConfirmType.delete:
        return 'Are you sure you want to delete "$itemName"? This action cannot be undone.';
    }
  }

  String get _confirmButtonText {
    switch (confirmType) {
      case ConfirmType.action:
        return 'Confirm';
      case ConfirmType.delete:
        return 'Delete';
    }
  }

  Color get _confirmButtonColor {
    switch (confirmType) {
      case ConfirmType.action:
        return Colors.blue[400]!;
      case ConfirmType.delete:
        return Colors.red[400]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_icon, size: 48, color: _iconColor),
        const SizedBox(height: 16),
        Text(
          _title,
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          _message,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Pressable(
                onTap: () => Navigator.pop(context, false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Cancel',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Pressable(
                onTap: () => Navigator.pop(context, true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _confirmButtonColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _confirmButtonText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
