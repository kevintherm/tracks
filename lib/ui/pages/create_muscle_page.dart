import 'dart:developer';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tracks/models/muscle.dart';
import 'package:tracks/repositories/muscle_repository.dart';
import 'package:tracks/ui/components/blur_away.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/components/section_card.dart';
import 'package:tracks/utils/app_colors.dart';
import 'package:tracks/utils/consts.dart';
import 'package:tracks/utils/toast.dart';

class CreateMusclePage extends StatefulWidget {
  final Muscle? muscle;

  const CreateMusclePage({super.key, this.muscle});

  @override
  State<CreateMusclePage> createState() => _CreateMusclePageState();
}

class _CreateMusclePageState extends State<CreateMusclePage> {
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  late Muscle _muscle;
  final List<String> _selectedThumbnails = [];

  @override
  void initState() {
    super.initState();
    if (widget.muscle != null) {
      _muscle = widget.muscle!;
      _nameController.text = _muscle.name;
      _descController.text = _muscle.description ?? '';
      _selectedThumbnails.addAll(
        _muscle.pendingThumbnailPaths.isNotEmpty
            ? _muscle.pendingThumbnailPaths
            : _muscle.thumbnails,
      );
    } else {
      _muscle = Muscle(name: "");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickThumbnailImage() async {
    final toast = Toast(context);

    final ImageSource? source = await showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
            child: Wrap(
              children: [
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('Choose from Gallery'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text('Take a Photo'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _selectedThumbnails.add(image.path));
      }
    } catch (e) {
      toast.error(content: Text("Failed to pick image: $e"));
    }
  }

  void _removeThumbnailImage(String image) {
    setState(() => _selectedThumbnails.remove(image));
  }

  Future<void> _save() async {
    final toast = Toast(context);
    final nav = Navigator.of(context);

    if (_nameController.text.trim().isEmpty) {
      toast.error(content: const Text("Please enter a name"));
      return;
    }

    try {
      final muscleRepo = context.read<MuscleRepository>();

      _muscle.name = _nameController.text;
      _muscle.description = _descController.text;
      _muscle.pendingThumbnailPaths = _selectedThumbnails;

      await muscleRepo.saveMuscle(_muscle);

      toast.success(content: Text("Muscle saved!"));
      nav.pop(true);
    } catch (e) {
      log(e.toString());
      toast.error(content: Text(fatalError));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlurAway(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // App Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Pressable(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Iconsax.arrow_left_2_outline,
                          size: 24,
                        ),
                      ),
                      Text(
                        widget.muscle != null ? "Edit Muscle" : "Create Muscle",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Pressable(
                        onTap: _save,
                        child: const Icon(
                          Iconsax.tick_square_outline,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),

                // Thumbnail Section
                _ThumbnailSection(
                  images: _selectedThumbnails,
                  onPickImage: _pickThumbnailImage,
                  onRemoveImage: _removeThumbnailImage,
                ),

                // Exercise Details Section
                SectionCard(
                  title: "Muscle Details",
                  child: Focus(
                    canRequestFocus: false,
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _descController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Looking for something else?",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Pressable(
                            onTap: () {},
                            child: Text(
                              "Create via Import (JSON)",
                              style: GoogleFonts.inter(color: Colors.grey[700]),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Thumbnail Section Widget
class _ThumbnailSection extends StatefulWidget {
  final List<String> images;
  final VoidCallback onPickImage;
  final void Function(String) onRemoveImage;

  const _ThumbnailSection({
    required this.images,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  @override
  State<_ThumbnailSection> createState() => _ThumbnailSectionState();
}

class _ThumbnailSectionState extends State<_ThumbnailSection> {
  int selectedIndex = 0;

  void _onSelectImage(image) {
    setState(() => selectedIndex = widget.images.indexOf(image));
  }

  @override
  Widget build(BuildContext context) {
    final Color color = AppColors.secondary;

    return SectionCard(
      title: "Thumbnail",
      child: widget.images.isNotEmpty
          ? _buildImagePreview()
          : _buildUploadArea(color),
    );
  }

  Widget _buildImagePreview() {
    return Column(
      children: [
        _buildImage(widget.images[selectedIndex], actions: true),

        const SizedBox(height: 16),

        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.images.length + 1,
            itemBuilder: (context, index) {
              final image = index < widget.images.length
                  ? widget.images[index]
                  : null;

              return _buildImage(
                image,
                onTap: image != null ? () => _onSelectImage(image) : null,
                isSelected: selectedIndex == index,
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(width: 8);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImage(
    String? image, {
    bool actions = false,
    VoidCallback? onTap,
    bool isSelected = false,
  }) {
    if (image == null) {
      return Pressable(
        onTap: widget.onPickImage,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          width: 90,
          height: 90,
          child: const Icon(MingCute.add_circle_fill),
        ),
      );
    }

    return Pressable(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: AppColors.secondary, width: 2)
              : null,
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(isSelected ? 14 : 16),
              child: AspectRatio(
                aspectRatio: 1 / 1,
                child: Image.file(
                  File(image),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  cacheWidth: 500,
                ),
              ),
            ),
            if (actions)
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Pressable(
                      onTap: () => widget.onRemoveImage(image),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Iconsax.trash_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Pressable(
                      onTap: widget.onPickImage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Iconsax.edit_2_outline,
                          color: Colors.white,
                          size: 20,
                        ),
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

  Widget _buildUploadArea(Color color) {
    return InkWell(
      onTap: widget.onPickImage,
      borderRadius: BorderRadius.circular(16),
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          dashPattern: const [10, 5],
          strokeWidth: 2,
          radius: const Radius.circular(16),
          color: color,
          padding: const EdgeInsets.all(16),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.document_upload_outline, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                "Upload a thumbnail",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Tap to select an image",
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
