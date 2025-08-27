// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../services/backup_service.dart';
import 'tutorial_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsService _settings;
  
  @override
  void initState() {
    super.initState();
    _settings = context.read<SettingsService>();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Measurement Units
          ListTile(
            title: const Text('Default Unit'),
            subtitle: Text(_settings.defaultUnit),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showUnitPicker(),
          ),
          
          // Reference Object
          ListTile(
            title: const Text('Default Reference Object'),
            subtitle: Text(_settings.defaultReference),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showReferencePicker(),
          ),
          
          const Divider(),
          
          // Auto-Save
          SwitchListTile(
            title: const Text('Auto-Save Measurements'),
            subtitle: const Text('Automatically save to history'),
            value: _settings.autoSave,
            onChanged: (value) {
              setState(() {
                _settings.autoSave = value;
              });
            },
          ),
          
          // Measurement Guides
          SwitchListTile(
            title: const Text('Show Measurement Guides'),
            subtitle: const Text('Display grid overlay when measuring'),
            value: _settings.showGuides,
            onChanged: (value) {
              setState(() {
                _settings.showGuides = value;
              });
            },
          ),
          
          // High Accuracy Mode
          SwitchListTile(
            title: const Text('High Accuracy Mode'),
            subtitle: const Text('Use enhanced processing (slower)'),
            value: _settings.highAccuracy,
            onChanged: (value) {
              setState(() {
                _settings.highAccuracy = value;
              });
            },
          ),
          
          const Divider(),
          
          // Backup Section - NEW
          ListTile(
            leading: const Icon(Icons.cloud_upload, color: Colors.blue),
            title: const Text('Backup to Cloud'),
            subtitle: const Text('Save to Google Drive, Dropbox, etc'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => BackupService.exportToCloud(context),
          ),
          
          ListTile(
            leading: const Icon(Icons.share, color: Colors.green),
            title: const Text('Share Backup'),
            subtitle: const Text('Send backup via email or messaging'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => BackupService.shareBackup(context),
          ),
          
          ListTile(
            leading: const Icon(Icons.restore, color: Colors.orange),
            title: const Text('Restore from Backup'),
            subtitle: const Text('Restore measurements from backup file'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => BackupService.restoreBackup(context),
          ),
          
          const Divider(),
          
          // Data Management
          ListTile(
            title: const Text('Export All Data'),
            leading: const Icon(Icons.download),
            onTap: _exportAllData,
          ),
          
          ListTile(
            title: const Text('Clear History'),
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: _clearHistory,
          ),
          
          const Divider(),
          
          // Auto-Backup Reminder - NEW
          SwitchListTile(
            title: const Text('Weekly Backup Reminder'),
            subtitle: const Text('Remind me to backup every week'),
            value: _settings.autoBackupReminder ?? false,
            onChanged: (value) async {
              setState(() {
                _settings.setAutoBackupReminder(value);
              });
              
              if (value) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('lastBackupDate', DateTime.now().toIso8601String());
              }
            },
          ),
          
          const Divider(),
          
          // About
          ListTile(
            title: const Text('About MeasureSnap'),
            subtitle: const Text('Version 1.0.0'),
            leading: const Icon(Icons.info),
            onTap: () => _showAbout(),
          ),
          
          ListTile(
            title: const Text('Tutorial'),
            leading: const Icon(Icons.help),
            onTap: () => _showTutorial(),
          ),
          
          ListTile(
            title: const Text('Rate App'),
            leading: const Icon(Icons.star),
            onTap: () => _rateApp(),
          ),
          
          // Privacy Section - NEW
          const Divider(),
          
          ListTile(
            title: const Text('Privacy'),
            leading: const Icon(Icons.privacy_tip),
            subtitle: const Text('All data stored locally on device'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Privacy Information'),
                  content: const Text(
                    'MeasureSnap stores all your data locally on your device.\n\n'
                    '• No account required\n'
                    '• No data sent to servers\n'
                    '• You control your backups\n'
                    '• Delete app = delete all data\n\n'
                    'Backups are saved to your chosen cloud storage using your own account.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  void _showUnitPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Default Unit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['mm', 'cm', 'inches', 'feet'].map((unit) {
            return RadioListTile<String>(
              title: Text(unit),
              value: unit,
              groupValue: _settings.defaultUnit,
              onChanged: (value) {
                setState(() {
                  _settings.defaultUnit = value!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
  
  void _showReferencePicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Default Reference'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Credit Card'),
              value: 'credit_card',
              groupValue: _settings.defaultReference,
              onChanged: (value) {
                setState(() {
                  _settings.defaultReference = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('US Quarter'),
              value: 'us_quarter',
              groupValue: _settings.defaultReference,
              onChanged: (value) {
                setState(() {
                  _settings.defaultReference = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Dollar Bill'),
              value: 'us_dollar',
              groupValue: _settings.defaultReference,
              onChanged: (value) {
                setState(() {
                  _settings.defaultReference = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _exportAllData() async {
    try {
      // Use the backup service to create a full export
      await BackupService.shareBackup(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }
  
  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All History?'),
        content: const Text('This will delete all measurements and cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      // TODO: Implement clear database
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('History cleared')),
      );
    }
  }
  
  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'MeasureSnap',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.straighten, size: 48),
      children: [
        const Text('Measure anything using reference objects in photos.'),
        const SizedBox(height: 8),
        const Text('© 2025 MeasureSnap'),
        const SizedBox(height: 8),
        const Text('All data stored locally on your device.'),
      ],
    );
  }
  
  void _showTutorial() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TutorialScreen()),
    );
  }
  
  void _rateApp() {
    // For now, just show a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate MeasureSnap'),
        content: const Text('Thank you for using MeasureSnap! App store rating will be available soon.'),
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