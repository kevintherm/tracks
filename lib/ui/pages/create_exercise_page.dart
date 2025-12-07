import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isar/isar.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:tracks/models/exercise.dart';
import 'package:tracks/models/muscle.dart';
import 'package:tracks/repositories/exercise_repository.dart';
import 'package:tracks/repositories/muscle_repository.dart';
import 'package:tracks/ui/components/ai_recommendation.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/components/select_config/list_item.dart';
import 'package:tracks/ui/components/select_config/select_config.dart';
import 'package:tracks/ui/components/section_card.dart';
import 'package:tracks/ui/components/select_config/select_config_option.dart';
import 'package:tracks/utils/app_colors.dart';
import 'package:tracks/utils/toast.dart';

class CreateExercisePage extends StatefulWidget {
  final Exercise? exercise;

  const CreateExercisePage({super.key, this.exercise});

  @override
  State<CreateExercisePage> createState() => _CreateExercisePageState();
}

class _CreateExercisePageState extends State<CreateExercisePage> {
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();

  XFile? _thumbnailImage;
  bool _thumbnailRemoved = false;

  final List<SelectConfigOption> _selectedOptions = [];
  final Map<String, int> _muscleActivations = {};

  @override
  void initState() {
    super.initState();
    if (widget.exercise != null) {
      _nameController.text = widget.exercise!.name;
      _descriptionController.text = widget.exercise!.description ?? '';
      _caloriesController.text = widget.exercise!.caloriesBurned.toString();
      _loadExistingMuscles(widget.exercise!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingMuscles(Exercise exercise) async {
    try {
      final musclesParam = exercise.musclesWithActivation;

      for (final entry in musclesParam) {
        final muscle = entry.muscle;
        final activation = entry.activation;

        final muscleOption = SelectConfigOption(
          id: muscle.id.toString(),
          label: muscle.name,
          subtitle: muscle.description,
          imagePath: muscle.thumbnail,
        );

        // Apply to selected options
        if (!_selectedOptions.any((opt) => opt.id == muscleOption.id)) {
          setState(() {
            _selectedOptions.add(muscleOption);
            _muscleActivations[muscleOption.id] = activation;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        Toast(context).error(content: Text("Failed to load muscles: $e"));
      }
    }
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
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text('Take a Photo'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
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
        setState(() {
          _thumbnailImage = image;
          _thumbnailRemoved = false;
        });
      }
    } catch (e) {
      toast.error(content: Text("Failed to pick image: $e"));
    }
  }

  void _removeThumbnailImage() {
    setState(() {
      _thumbnailImage = null;
      _thumbnailRemoved = true;
    });
  }

  void _toggleMuscleSelection(SelectConfigOption option, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (!_selectedOptions.contains(option)) {
          _selectedOptions.add(option);
          _muscleActivations[option.id] = 50; // default 50%
        }
      } else {
        _selectedOptions.remove(option);
        _muscleActivations.remove(option.id);
      }
    });
  }

  void _updateMuscleActivation(String muscleId, int activation) {
    setState(() {
      _muscleActivations[muscleId] = activation;
    });
  }

  void _removeSelectedMuscle(int index) {
    setState(() {
      final option = _selectedOptions[index];
      _selectedOptions.removeAt(index);
      _muscleActivations.remove(option.id);
    });
  }

  Future<void> _saveExercise() async {
    final toast = Toast(context);
    final nav = Navigator.of(context);

    if (_nameController.text.trim().isEmpty) {
      toast.error(content: const Text("Please enter a name"));
      return;
    }

    final exerciseRepo = context.read<ExerciseRepository>();
    final isar = context.read<Isar>();
    final calories = double.tryParse(_caloriesController.text) ?? 0.0;
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim().isEmpty
        ? null
        : _descriptionController.text.trim();

    try {
      if (widget.exercise != null) {

        String? thumbnailPath;
        if (_thumbnailImage != null) {
          thumbnailPath = _thumbnailImage!.path;
        } else if (_thumbnailRemoved) {
          thumbnailPath = null;
        } else {
          thumbnailPath = widget.exercise!.thumbnail;
        }

        final updatedExercise = Exercise(
          name: name,
          description: description,
          caloriesBurned: calories,
          thumbnail: thumbnailPath,
          pocketbaseId: widget.exercise!.pocketbaseId,
          needSync: widget.exercise!.needSync,
          imported: widget.exercise!.imported,
        )..id = widget.exercise!.id;

        final muscleActivations = <MuscleActivationParam>[];
        for (final opt in _selectedOptions) {
          final muscleId = int.parse(opt.id);
          final muscle = await isar.muscles.get(muscleId);
          if (muscle != null) {
            final activation = _muscleActivations[opt.id] ?? 50;
            muscleActivations.add(
              MuscleActivationParam(muscle: muscle, activation: activation),
            );
          }
        }

        await exerciseRepo.updateExercise(
          exercise: updatedExercise,
          muscles: muscleActivations,
        );
        toast.success(content: const Text("Exercise updated!"));

      } else {

        final newExercise = Exercise(
          name: name,
          description: description,
          caloriesBurned: calories,
          thumbnail: _thumbnailImage?.path,
        );

        final muscleActivations = <MuscleActivationParam>[];
        for (final opt in _selectedOptions) {
          final muscleId = int.parse(opt.id);
          final muscle = await isar.muscles.get(muscleId);
          if (muscle != null) {
            final activation = _muscleActivations[opt.id] ?? 50;
            muscleActivations.add(
              MuscleActivationParam(muscle: muscle, activation: activation),
            );
          }
        }

        await exerciseRepo.createExercise(
          exercise: newExercise,
          muscles: muscleActivations,
        );
        toast.success(content: const Text("Exercise created!"));
        
      }

      nav.pop(true);
    } catch (e) {
      toast.error(content: Text("Failed to save exercise: $e"));
    }
  }

  @override
  Widget build(BuildContext context) {
    final muscleRepo = context.read<MuscleRepository>();

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<Muscle>>(
          stream: muscleRepo.watchAllMuscles(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final allMuscles = snapshot.data!
                .map(
                  (muscle) => SelectConfigOption(
                    id: muscle.id.toString(),
                    label: muscle.name,
                    subtitle: muscle.description,
                    imagePath: muscle.thumbnail,
                  ),
                )
                .toList();

            return SingleChildScrollView(
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
                          widget.exercise != null
                              ? "Edit Exercise"
                              : "Create Exercise",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Pressable(
                          onTap: _saveExercise,
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
                    thumbnailImage: _thumbnailImage,
                    existingThumbnailPath: widget.exercise?.thumbnail,
                    thumbnailRemoved: _thumbnailRemoved,
                    onPickImage: _pickThumbnailImage,
                    onRemoveImage: _removeThumbnailImage,
                  ),

                  // Exercise Details Section
                  SectionCard(
                    title: "Exercise Details",
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _caloriesController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*$'),
                            ),
                          ],
                          decoration: InputDecoration(
                            prefixIcon: const Icon(MingCute.fire_line),
                            labelText: 'Calories Burned (Kkal/Set)',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Targeted Muscles Section
                  SectionCard(
                    title: "Targeted Muscles",
                    child: SelectConfig<SelectConfigOption>(
                      allOptions: allMuscles,
                      selectedOptions: _selectedOptions,
                      onToggle: _toggleMuscleSelection,
                      getLabel: (option) => option.label,
                      getId: (option) => option.id,
                      itemBuilder: (option, isSelected, onChanged) {
                        return ListItem(
                          id: option.id,
                          label: option.label,
                          isSelected: isSelected,
                          onChanged: onChanged,
                          imagePath: option.imagePath,
                          subtitle: option.subtitle,
                        );
                      },
                      aiRecommendation: AiRecommendation(
                        onUse: () {},
                        buttonText: "Use",
                      ),
                    ),
                  ),

                  // Muscle Configuration Section
                  if (_selectedOptions.isNotEmpty)
                    SectionCard(
                      title:
                          "Configure Activation (${_selectedOptions.length})",
                      child: Column(
                        children: List.generate(
                          _selectedOptions.length,
                          (index) {
                            final option = _selectedOptions[index];
                            final activation =
                                _muscleActivations[option.id] ?? 50;

                            return _ConfigurableExerciseCard(
                              key: ValueKey(option.id),
                              option: option,
                              muscleActivation: activation,
                              onActivationChanged: (value) =>
                                  _updateMuscleActivation(option.id, value),
                              onDelete: () => _removeSelectedMuscle(index),
                            );
                          },
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
                                style: GoogleFonts.inter(
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// Thumbnail Section Widget
class _ThumbnailSection extends StatelessWidget {
  final XFile? thumbnailImage;
  final String? existingThumbnailPath;
  final bool thumbnailRemoved;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;

  const _ThumbnailSection({
    required this.thumbnailImage,
    this.existingThumbnailPath,
    this.thumbnailRemoved = false,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = AppColors.secondary;

    return SectionCard(
      title: "Thumbnail",
      child: thumbnailImage != null
          ? _buildImagePreview(thumbnailImage!)
          : (existingThumbnailPath != null && !thumbnailRemoved)
          ? _buildExistingImagePreview(existingThumbnailPath!)
          : _buildUploadArea(color),
    );
  }

  Widget _buildExistingImagePreview(String imagePath) {
    return AspectRatio(
      aspectRatio: 1,
      child: FutureBuilder<Uint8List>(
        future: File(imagePath).readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Container(
              color: Colors.grey[300],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.gallery_slash_outline,
                      size: 48,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load image',
                      style: GoogleFonts.inter(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return Container(
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  snapshot.data!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  cacheWidth: 500,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        onRemoveImage();
                      },
                      icon: Container(
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
                    IconButton(
                      onPressed: () {
                        onPickImage();
                      },
                      icon: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade400,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Iconsax.camera_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImagePreview(XFile image) {
    return AspectRatio(
      aspectRatio: 1,
      child: FutureBuilder<Uint8List>(
        future: image.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Container(
              color: Colors.grey[300],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.gallery_slash_outline,
                      size: 48,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load image',
                      style: GoogleFonts.inter(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return Container(
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  snapshot.data!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  cacheWidth: 500,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        onRemoveImage();
                      },
                      icon: Container(
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
                    IconButton(
                      onPressed: () {
                        onPickImage();
                      },
                      icon: Container(
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
          );
        },
      ),
    );
  }

  Widget _buildUploadArea(Color color) {
    return InkWell(
      onTap: onPickImage,
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

// Configurable Exercise Card
class _ConfigurableExerciseCard extends StatelessWidget {
  final SelectConfigOption option;
  final int muscleActivation;
  final ValueChanged<int> onActivationChanged;
  final VoidCallback? onDelete;

  const _ConfigurableExerciseCard({
    super.key,
    required this.option,
    required this.muscleActivation,
    required this.onActivationChanged,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.grey[100],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildMuscleImage(
                  option.imagePath ?? 'assets/drawings/not-found.jpg',
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              option.label,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (onDelete != null)
                            Pressable(
                              onTap: onDelete,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Iconsax.trash_outline,
                                  size: 18,
                                  color: Colors.red[400],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        option.subtitle ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Muscle Activation (EMG)",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const SizedBox(width: 32),
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black26),
                            ),
                            child: NumberPicker(
                              step: 5,
                              value: muscleActivation,
                              minValue: 5,
                              maxValue: 100,
                              haptics: false,
                              axis: Axis.horizontal,
                              itemWidth: 60,
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
                              onChanged: onActivationChanged,
                            ),
                          ),
                          Icon(
                            Iconsax.percentage_square_outline,
                            size: 32,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuscleImage(String imagePath) {
    if (imagePath.startsWith('/') || imagePath.contains('app_flutter')) {
      final file = File(imagePath);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            file,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            cacheWidth: 150,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/drawings/not-found.jpg',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                cacheWidth: 150,
              );
            },
          ),
        );
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        imagePath,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        cacheWidth: 150,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/drawings/not-found.jpg',
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            cacheWidth: 150,
          );
        },
      ),
    );
  }
}
