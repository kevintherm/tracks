import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracks/services/import_service.dart';

class ImportDataPage extends StatefulWidget {
  const ImportDataPage({super.key});

  @override
  State<ImportDataPage> createState() => _ImportDataPageState();
}

class _ImportDataPageState extends State<ImportDataPage> {
  bool _isLoading = false;
  String? _statusMessage;

  Future<void> _pickAndImport(
    String type,
    Future<void> Function(List<dynamic>) importFunction,
  ) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Picking $type file...';
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        
        setState(() {
          _statusMessage = 'Validating and importing $type...';
        });

        final json = jsonDecode(content);
        if (json is List) {
          await importFunction(json);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$type imported successfully')),
            );
          }
        } else {
          throw Exception('Invalid JSON format. Expected a list.');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing $type: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final importService = context.read<ImportService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isLoading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 16),
              Text(_statusMessage ?? 'Loading...', textAlign: TextAlign.center),
              const SizedBox(height: 32),
            ],
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () => _pickAndImport(
                        'Muscles',
                        importService.importMuscles,
                      ),
              child: const Text('Import Muscles'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () => _pickAndImport(
                        'Exercises',
                        importService.importExercises,
                      ),
              child: const Text('Import Exercises'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () => _pickAndImport(
                        'Workouts',
                        importService.importWorkouts,
                      ),
              child: const Text('Import Workouts'),
            ),
          ],
        ),
      ),
    );
  }
}
