import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isar/isar.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:tracks/models/exercise.dart';
import 'package:tracks/models/workout.dart';
import 'package:tracks/models/workout_exercises.dart';
import 'package:tracks/repositories/exercise_repository.dart';
import 'package:tracks/repositories/workout_repository.dart';
import 'package:tracks/ui/components/blur_away.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/components/section_card.dart';
import 'package:tracks/utils/app_colors.dart';
import 'package:tracks/utils/consts.dart';
import 'package:tracks/utils/toast.dart';

class CreateWorkoutPage extends StatefulWidget {
  final Workout? workout;

  const CreateWorkoutPage({super.key, this.workout});

  @override
  State<CreateWorkoutPage> createState() => _CreateWorkoutPageState();
}

class _CreateWorkoutPageState extends State<CreateWorkoutPage> {
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  XFile? _thumbnailImage;
  bool _thumbnailRemoved = false;
  bool _isPublic = false;

  List<WorkoutConfigParam> _selectedExercises = [];

  @override
  void initState() {
    super.initState();
    if (widget.workout != null) {
      _nameController.text = widget.workout!.name;
      _descriptionController.text = widget.workout!.description ?? '';
      _isPublic = widget.workout!.public;
      _loadExistingExercises(widget.workout!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingExercises(Workout workout) async {
    final workoutRepo = context.read<WorkoutRepository>();

    final junctions = await workoutRepo.weCollection
        .filter()
        .workout((q) => q.idEqualTo(workout.id))
        .sortByOrder()
        .findAll();

    final exercises = <WorkoutConfigParam>[];
    for (final junction in junctions) {
      await junction.exercise.load();
      if (junction.exercise.value != null) {
        exercises.add(
          WorkoutConfigParam(
            exercise: junction.exercise.value!,
            sets: junction.sets,
            reps: junction.reps,
            order: junction.order,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _selectedExercises = exercises;
      });
    }
  }

  Future<void> _pickThumbnailImage() async {
    final toast = Toast(context);
    FocusScope.of(context).unfocus();

    final ImageSource? source = await showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take a Photo'),
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

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = _selectedExercises.removeAt(oldIndex);
      _selectedExercises.insert(newIndex, item);

      // Update order fields
      for (int i = 0; i < _selectedExercises.length; i++) {
        _selectedExercises[i].order = i;
      }
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _selectedExercises.removeAt(index);
    });
  }

  Future<void> _addExercise() async {
    final Exercise? selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ExerciseSelectionPage(
          existingExerciseIds: _selectedExercises
              .map((e) => e.exercise.id)
              .toList(),
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedExercises.add(
          WorkoutConfigParam(
            exercise: selected,
            sets: 3,
            reps: 8,
            order: _selectedExercises.length,
          ),
        );
      });
    }
  }

  void _configureExercise(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExerciseConfigSheet(
        param: _selectedExercises[index],
        onSave: (sets, reps) {
          setState(() {
            _selectedExercises[index].sets = sets;
            _selectedExercises[index].reps = reps;
          });
        },
      ),
    );
  }

  Future<void> _saveWorkout() async {
    final toast = Toast(context);
    final nav = Navigator.of(context);
    final workoutRepo = context.read<WorkoutRepository>();

    if (_nameController.text.trim().isEmpty) {
      toast.error(content: const Text("Please enter a name"));
      return;
    }

    if (_selectedExercises.isEmpty) {
      toast.error(
        content: const Text("A workout must contain at least 1 exercise."),
      );
      return;
    }

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim().isEmpty
        ? null
        : _descriptionController.text.trim();

    // Update orders one last time to be sure
    for (int i = 0; i < _selectedExercises.length; i++) {
      _selectedExercises[i].order = i;
    }

    try {
      if (widget.workout != null) {
        String? pendingThumbnailPath;
        String? thumbnailPath = widget.workout!.thumbnail;

        if (_thumbnailImage != null) {
          pendingThumbnailPath = _thumbnailImage!.path;
        } else if (_thumbnailRemoved) {
          thumbnailPath = null;
          pendingThumbnailPath = null;
        }

        final updatedWorkout =
            Workout(
                name: name,
                description: description,
                thumbnail: thumbnailPath,
                pocketbaseId: widget.workout!.pocketbaseId,
                needSync: widget.workout!.needSync,
                public: _isPublic,
              )
              ..id = widget.workout!.id
              ..pendingThumbnailPath = pendingThumbnailPath;

        await workoutRepo.updateWorkout(
          workout: updatedWorkout,
          exercises: _selectedExercises,
        );

        toast.success(content: const Text("Workout updated!"));
      } else {
        final newWorkout = Workout(
          name: name,
          description: description,
          thumbnail: null,
          public: _isPublic,
        )..pendingThumbnailPath = _thumbnailImage?.path;

        await workoutRepo.createWorkout(
          workout: newWorkout,
          exercises: _selectedExercises,
        );

        toast.success(content: const Text("Workout created!"));
      }

      nav.pop(true);
    } catch (e) {
      toast.error(content: Text("Failed to save workout: $e"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlurAway(
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
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
                        widget.workout != null
                            ? "Edit Workout"
                            : "Create Workout",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Pressable(
                        onTap: _saveWorkout,
                        child: const Icon(
                          Iconsax.tick_square_outline,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),

                _ThumbnailSection(
                  thumbnailImage: _thumbnailImage,
                  existingThumbnailPath: widget.workout?.thumbnail,
                  thumbnailRemoved: _thumbnailRemoved,
                  onPickImage: _pickThumbnailImage,
                  onRemoveImage: _removeThumbnailImage,
                ),

                SectionCard(
                  title: "Workout Details",
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.00),
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
                            borderRadius: BorderRadius.circular(16.00),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: Text(
                          "Public",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          "Make this workout visible to everyone",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        value: _isPublic,
                        onChanged: (value) {
                          setState(() {
                            _isPublic = value;
                          });
                        },
                        activeThumbColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Exercises",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Pressable(
                        onTap: _addExercise,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Add",
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _selectedExercises.length,
                  onReorder: _onReorder,
                  itemBuilder: (context, index) {
                    final param = _selectedExercises[index];
                    return _ExerciseListItem(
                      key: ValueKey(param.exercise.id),
                      param: param,
                      index: index,
                      onTap: () => _configureExercise(index),
                      onDelete: () => _removeExercise(index),
                    );
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseListItem extends StatelessWidget {
  final WorkoutConfigParam param;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ExerciseListItem({
    super.key,
    required this.param,
    required this.index,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: getImage(
            param.exercise.thumbnail,
            pendingPath: param.exercise.pendingThumbnailPath,
            width: 60,
            height: 60,
          ),
        ),
        title: Text(
          param.exercise.name,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          "${param.sets} sets x ${param.reps} reps",
          style: GoogleFonts.inter(color: Colors.grey[600]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Iconsax.edit_2_outline, size: 20),
              onPressed: onTap,
            ),
            IconButton(
              icon: const Icon(
                Iconsax.trash_outline,
                size: 20,
                color: Colors.red,
              ),
              onPressed: onDelete,
            ),
            ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseSelectionPage extends StatefulWidget {
  final List<int> existingExerciseIds;

  const _ExerciseSelectionPage({required this.existingExerciseIds});

  @override
  State<_ExerciseSelectionPage> createState() => _ExerciseSelectionPageState();
}

class _ExerciseSelectionPageState extends State<_ExerciseSelectionPage> {
  String _searchQuery = "";
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exerciseRepo = context.read<ExerciseRepository>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Row(
                children: [
                  Pressable(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Iconsax.arrow_left_2_outline, size: 24),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Select Exercise",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: "Search...",
                  prefixIcon: const Icon(Iconsax.search_normal_1_outline),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<Exercise>>(
                stream: exerciseRepo.watchAllExercises(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final exercises = snapshot.data!.where((e) {
                    return e.name.toLowerCase().contains(_searchQuery);
                  }).toList();

                  // Sort: Existing ones first
                  exercises.sort((a, b) {
                    final aExists = widget.existingExerciseIds.contains(a.id);
                    final bExists = widget.existingExerciseIds.contains(b.id);
                    if (aExists && !bExists) return -1;
                    if (!aExists && bExists) return 1;
                    return a.name.compareTo(b.name);
                  });

                  return ListView.builder(
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      final isSelected = widget.existingExerciseIds.contains(
                        exercise.id,
                      );

                      return Pressable(
                        onTap: () {
                          if (!isSelected) {
                            Navigator.pop(context, exercise);
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: getImage(
                                  exercise.thumbnail,
                                  pendingPath: exercise.pendingThumbnailPath,
                                  width: 60,
                                  height: 60,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exercise.name,
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      exercise.description ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "Added",
                                    style: GoogleFonts.inter(
                                      color: Colors.grey[500],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                              else
                                const Icon(
                                  Iconsax.add_circle_outline,
                                  color: AppColors.primary,
                                ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseConfigSheet extends StatefulWidget {
  final WorkoutConfigParam param;
  final Function(int sets, int reps) onSave;

  const _ExerciseConfigSheet({required this.param, required this.onSave});

  @override
  State<_ExerciseConfigSheet> createState() => _ExerciseConfigSheetState();
}

class _ExerciseConfigSheetState extends State<_ExerciseConfigSheet> {
  late int _sets;
  late int _reps;

  @override
  void initState() {
    super.initState();
    _sets = widget.param.sets;
    _reps = widget.param.reps;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.param.exercise.name,
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildPicker(
                  label: "Sets",
                  value: _sets,
                  onChanged: (v) => setState(() => _sets = v),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPicker(
                  label: "Reps",
                  value: _reps,
                  onChanged: (v) => setState(() => _reps = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onSave(_sets, _reps);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                "Save",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
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
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: NumberPicker(
            value: value,
            minValue: 1,
            maxValue: 100,
            itemHeight: 40,
            textStyle: GoogleFonts.inter(fontSize: 16, color: Colors.grey[400]),
            selectedTextStyle: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

// Reusing _ThumbnailSection from previous code, but simplified
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
    return SectionCard(
      title: "Thumbnail",
      child: thumbnailImage != null
          ? _buildImagePreview(thumbnailImage!)
          : (existingThumbnailPath != null && !thumbnailRemoved)
          ? _buildExistingImagePreview(existingThumbnailPath!)
          : _buildUploadArea(),
    );
  }

  Widget _buildExistingImagePreview(String imagePath) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: getSafeImage(
              imagePath,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                _buildActionButton(
                  Iconsax.trash_outline,
                  Colors.red,
                  onRemoveImage,
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  Iconsax.edit_2_outline,
                  Colors.black54,
                  onPickImage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(XFile image) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(image.path),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                _buildActionButton(
                  Iconsax.trash_outline,
                  Colors.red,
                  onRemoveImage,
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  Iconsax.edit_2_outline,
                  Colors.black54,
                  onPickImage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  Widget _buildUploadArea() {
    return InkWell(
      onTap: onPickImage,
      borderRadius: BorderRadius.circular(16),
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          dashPattern: const [10, 5],
          strokeWidth: 2,
          radius: const Radius.circular(16),
          color: AppColors.secondary,
          padding: const EdgeInsets.all(16),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Iconsax.document_upload_outline,
                size: 32,
                color: AppColors.secondary,
              ),
              const SizedBox(height: 8),
              Text(
                "Upload a thumbnail",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
