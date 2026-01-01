import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/utils/app_colors.dart';

class PickAndImportDialog extends StatefulWidget {
  const PickAndImportDialog({
    super.key,
    this.modalPadding,
    required this.title,
    required this.description,
    required this.onImport,
    this.itemNameExtractor,
    this.itemDescriptionExtractor,
  });

  final EdgeInsetsGeometry? modalPadding;
  final String title;
  final String description;
  final Future<void> Function(List<dynamic> items) onImport;
  final String Function(dynamic item)? itemNameExtractor;
  final String Function(dynamic item)? itemDescriptionExtractor;

  @override
  State<PickAndImportDialog> createState() => _PickAndImportDialogState();
}

class _PickAndImportDialogState extends State<PickAndImportDialog> {
  File? _selectedFile;
  List<dynamic>? _parsedItems;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final json = jsonDecode(content);

        if (json is! List) {
          setState(() {
            _errorMessage = 'Invalid JSON format. Expected a list of items.';
            _selectedFile = null;
            _parsedItems = null;
          });
          return;
        }

        setState(() {
          _selectedFile = file;
          _parsedItems = json;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error reading file: $e';
        _selectedFile = null;
        _parsedItems = null;
      });
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _parsedItems = null;
      _errorMessage = null;
    });
  }

  Future<void> _handleImport() async {
    if (_parsedItems == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.onImport(_parsedItems!);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Import failed: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Flexible(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  widget.modalPadding ??
                  const EdgeInsets.only(bottom: 32, left: 16, right: 16, top: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.import_1_outline, size: 48, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            widget.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.error),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.danger_outline, color: Theme.of(context).colorScheme.onErrorContainer, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (_selectedFile == null)
            _buildUploadArea()
          else
            _buildFilePreviewArea(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Pressable(
                  onTap: _isLoading ? null : () => Navigator.pop(context, false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Cancel',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Pressable(
                  onTap: _isLoading || _parsedItems == null
                      ? null
                      : _handleImport,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _parsedItems == null
                          ? Colors.grey[400]
                          : AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            ),
                          )
                        : Text(
                            'Import',
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
      ),
      ),
      ),
        ),
      ],
    );
  }

  Widget _buildUploadArea() {
    return InkWell(
      onTap: _pickFile,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.document_1_outline,
              size: 32,
              color: AppColors.primary,
            ),
            const SizedBox(height: 8),
            Text(
              "Pick a file",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Tap to select a file",
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreviewArea() {
    final fileName = _selectedFile?.path.split('/').last ?? 'Unknown';
    final itemCount = _parsedItems?.length ?? 0;
    final displayItems = _parsedItems?.take(10).toList() ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  fileName,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Pressable(
                onTap: _removeFile,
                child: const Icon(Iconsax.trash_outline, color: Colors.red, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Iconsax.document_text_outline, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                '$itemCount ${itemCount == 1 ? "Item" : "Items"}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (displayItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: displayItems.length,
                itemBuilder: (context, index) {
                  final item = displayItems[index];
                  String itemName;
                  String? itemDescription;
                  
                  if (widget.itemNameExtractor != null) {
                    itemName = widget.itemNameExtractor!(item);
                  } else if (item is Map && item.containsKey('name')) {
                    itemName = item['name'].toString();
                  } else {
                    itemName = 'Item ${index + 1}';
                  }

                  if (widget.itemDescriptionExtractor != null) {
                    itemDescription = widget.itemDescriptionExtractor!(item);
                    if (itemDescription.isEmpty) {
                      itemDescription = null;
                    }
                  }

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(width: 2, color: Colors.grey),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itemName,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (itemDescription != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            itemDescription,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 4),
              ),
            ),
            if (itemCount > 10)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '... and ${itemCount - 10} more',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

}