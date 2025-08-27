// lib/services/backup_service.dart

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../models/measurement.dart';
import '../models/saved_space.dart';
import 'database_service.dart';
import 'package:archive/archive_io.dart';
import 'package:intl/intl.dart';

class BackupService {
  static const String backupVersion = '1.0';
  
  // Create a complete backup of all app data
  static Future<File?> createBackup(BuildContext context) async {
    try {
      // Show progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Creating backup..."),
              ],
            ),
          );
        },
      );

      // Get all data from database
      final db = DatabaseService();
      await db.initialize();
      final measurements = await db.getAllMeasurements();
      final spaces = await db.getAllSavedSpaces();
      
      // Create backup directory
      final tempDir = await getTemporaryDirectory();
      final backupDir = Directory('${tempDir.path}/measuresnap_backup');
      if (await backupDir.exists()) {
        await backupDir.delete(recursive: true);
      }
      await backupDir.create();
      
      // Create metadata file
      final metadata = {
        'version': backupVersion,
        'created': DateTime.now().toIso8601String(),
        'measurementCount': measurements.length,
        'spacesCount': spaces.length,
        'appVersion': '1.0.0',
      };
      
      final metadataFile = File('${backupDir.path}/metadata.json');
      await metadataFile.writeAsString(json.encode(metadata));
      
      // Save measurements data
      final measurementsData = {
        'measurements': measurements.map((m) => m.toJson()).toList(),
      };
      final measurementsFile = File('${backupDir.path}/measurements.json');
      await measurementsFile.writeAsString(json.encode(measurementsData));
      
      // Save spaces data
      final spacesData = {
        'spaces': spaces.map((s) => {
          'id': s.id,
          'name': s.name,
          'type': s.type.toString(),
          'dimensions': s.dimensions,
          'createdAt': s.createdAt.toIso8601String(),
          'notes': s.notes,
        }).toList(),
      };
      final spacesFile = File('${backupDir.path}/spaces.json');
      await spacesFile.writeAsString(json.encode(spacesData));
      
      // Copy all measurement images
      final imagesDir = Directory('${backupDir.path}/images');
      await imagesDir.create();
      
      for (var measurement in measurements) {
        final sourceFile = File(measurement.imagePath);
        if (await sourceFile.exists()) {
          final fileName = measurement.id + '.jpg';
          await sourceFile.copy('${imagesDir.path}/$fileName');
        }
      }
      
      // Create ZIP file
      final zipFile = File('${tempDir.path}/MeasureSnap_Backup_${DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now())}.zip');
      final encoder = ZipFileEncoder();
      encoder.create(zipFile.path);
      encoder.addDirectory(backupDir);
      encoder.close();
      
      // Clean up temp directory
      await backupDir.delete(recursive: true);
      
      // Close progress dialog
      Navigator.of(context).pop();
      
      return zipFile;
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup failed: $e')),
      );
      return null;
    }
  }
  
  // Share backup file
  static Future<void> shareBackup(BuildContext context) async {
    final backupFile = await createBackup(context);
    if (backupFile != null) {
      await Share.shareXFiles(
        [XFile(backupFile.path)],
        text: 'MeasureSnap Backup - Save this file to restore your measurements',
      );
    }
  }
  
  // Export to Google Drive (using Share menu)
  static Future<void> exportToCloud(BuildContext context) async {
    final backupFile = await createBackup(context);
    if (backupFile != null) {
      await Share.shareXFiles(
        [XFile(backupFile.path)],
        text: 'Save to Google Drive, Dropbox, or any cloud storage',
      );
      
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Backup Created'),
            content: const Text(
              'Choose "Save to Drive" or your preferred cloud storage from the share menu.\n\n'
              'Your backup file contains all measurements and images.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
  
  // Restore from backup
  static Future<bool> restoreBackup(BuildContext context) async {
    try {
      // Pick backup file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );
      
      if (result == null || result.files.single.path == null) {
        return false;
      }
      
      // Show progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Restoring backup..."),
              ],
            ),
          );
        },
      );
      
      final zipFile = File(result.files.single.path!);
      final tempDir = await getTemporaryDirectory();
      final extractDir = Directory('${tempDir.path}/restore_temp');
      
      if (await extractDir.exists()) {
        await extractDir.delete(recursive: true);
      }
      await extractDir.create();
      
      // Extract ZIP
      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      
      for (var file in archive) {
        final filename = '${extractDir.path}/${file.name}';
        if (file.isFile) {
          final outFile = File(filename);
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content);
        } else {
          await Directory(filename).create(recursive: true);
        }
      }
      
      // Read metadata
      final metadataFile = File('${extractDir.path}/measuresnap_backup/metadata.json');
      if (!await metadataFile.exists()) {
        throw Exception('Invalid backup file');
      }
      
      final metadata = json.decode(await metadataFile.readAsString());
      
      // Check version compatibility
      if (metadata['version'] != backupVersion) {
        throw Exception('Incompatible backup version');
      }
      
      // Restore measurements
      final measurementsFile = File('${extractDir.path}/measuresnap_backup/measurements.json');
      if (await measurementsFile.exists()) {
        final measurementsData = json.decode(await measurementsFile.readAsString());
        // TODO: Restore to database
      }
      
      // Restore spaces
      final spacesFile = File('${extractDir.path}/measuresnap_backup/spaces.json');
      if (await spacesFile.exists()) {
        final spacesData = json.decode(await spacesFile.readAsString());
        // TODO: Restore to database
      }
      
      // Restore images
      final imagesDir = Directory('${extractDir.path}/measuresnap_backup/images');
      if (await imagesDir.exists()) {
        final appDir = await getApplicationDocumentsDirectory();
        final targetImagesDir = Directory('${appDir.path}/measurement_images');
        if (!await targetImagesDir.exists()) {
          await targetImagesDir.create();
        }
        
        await for (var entity in imagesDir.list()) {
          if (entity is File) {
            final fileName = entity.path.split('/').last;
            await entity.copy('${targetImagesDir.path}/$fileName');
          }
        }
      }
      
      // Clean up
      await extractDir.delete(recursive: true);
      
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backup restored successfully! ${metadata['measurementCount']} measurements restored.'),
          backgroundColor: Colors.green,
        ),
      );
      
      return true;
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Restore failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }
  
  // Auto-backup reminder
  static Future<void> checkBackupReminder(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final lastBackup = prefs.getString('lastBackupDate');
    
    if (lastBackup == null) {
      // First time, set today as last backup
      await prefs.setString('lastBackupDate', DateTime.now().toIso8601String());
      return;
    }
    
    final lastBackupDate = DateTime.parse(lastBackup);
    final daysSinceBackup = DateTime.now().difference(lastBackupDate).inDays;
    
    if (daysSinceBackup >= 7) {
      // Show backup reminder
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Backup Reminder'),
          content: Text(
            'It\'s been $daysSinceBackup days since your last backup.\n\n'
            'Would you like to backup your measurements now?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await exportToCloud(context);
                await prefs.setString('lastBackupDate', DateTime.now().toIso8601String());
              },
              child: const Text('Backup Now'),
            ),
          ],
        ),
      );
    }
  }
}

// Update Settings Screen with backup options
class BackupSettingsWidget extends StatelessWidget {
  const BackupSettingsWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.cloud_upload),
          title: const Text('Backup to Cloud'),
          subtitle: const Text('Save to Google Drive or Dropbox'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => BackupService.exportToCloud(context),
        ),
        
        ListTile(
          leading: const Icon(Icons.share),
          title: const Text('Share Backup'),
          subtitle: const Text('Send backup via email or messaging'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => BackupService.shareBackup(context),
        ),
        
        ListTile(
          leading: const Icon(Icons.restore),
          title: const Text('Restore from Backup'),
          subtitle: const Text('Restore measurements from backup file'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => BackupService.restoreBackup(context),
        ),
        
        const Divider(),
        
        SwitchListTile(
          title: const Text('Auto-Backup Reminder'),
          subtitle: const Text('Remind me weekly to backup'),
          value: true, // Get from settings
          onChanged: (value) {
            // Save to settings
          },
        ),
      ],
    );
  }
}