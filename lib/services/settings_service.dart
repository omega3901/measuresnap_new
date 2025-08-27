// lib/services/settings_service.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  late SharedPreferences _prefs;
  
  // Settings
  String _defaultUnit = 'cm';
  String _defaultReference = 'credit_card';
  bool _autoSave = true;
  bool _showGuides = true;
  bool _highAccuracy = false;
  bool _darkMode = false;
  int _measurementCount = 0;
  bool _isPremium = false;
  bool? _autoBackupReminder;  // NEW
  
  // Getters
  String get defaultUnit => _defaultUnit;
  String get defaultReference => _defaultReference;
  bool get autoSave => _autoSave;
  bool get showGuides => _showGuides;
  bool get highAccuracy => _highAccuracy;
  bool get darkMode => _darkMode;
  int get measurementCount => _measurementCount;
  bool get isPremium => _isPremium;
  bool? get autoBackupReminder => _autoBackupReminder;  // NEW
  
  // Daily free measurement limit
  int get dailyLimit => _isPremium ? 999999 : 5;
  bool get canMeasure => _isPremium || _measurementCount < dailyLimit;
  
  // Setters
  set defaultUnit(String value) {
    _defaultUnit = value;
    _prefs.setString('defaultUnit', value);
    notifyListeners();
  }
  
  set defaultReference(String value) {
    _defaultReference = value;
    _prefs.setString('defaultReference', value);
    notifyListeners();
  }
  
  set autoSave(bool value) {
    _autoSave = value;
    _prefs.setBool('autoSave', value);
    notifyListeners();
  }
  
  set showGuides(bool value) {
    _showGuides = value;
    _prefs.setBool('showGuides', value);
    notifyListeners();
  }
  
  set highAccuracy(bool value) {
    _highAccuracy = value;
    _prefs.setBool('highAccuracy', value);
    notifyListeners();
  }
  
  set darkMode(bool value) {
    _darkMode = value;
    _prefs.setBool('darkMode', value);
    notifyListeners();
  }
  
  // NEW setter method for auto backup reminder
  void setAutoBackupReminder(bool value) {
    _autoBackupReminder = value;
    _prefs.setBool('autoBackupReminder', value);
    notifyListeners();
  }
  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Load saved settings
    _defaultUnit = _prefs.getString('defaultUnit') ?? 'cm';
    _defaultReference = _prefs.getString('defaultReference') ?? 'credit_card';
    _autoSave = _prefs.getBool('autoSave') ?? true;
    _showGuides = _prefs.getBool('showGuides') ?? true;
    _highAccuracy = _prefs.getBool('highAccuracy') ?? false;
    _darkMode = _prefs.getBool('darkMode') ?? false;
    _isPremium = _prefs.getBool('isPremium') ?? false;
    _autoBackupReminder = _prefs.getBool('autoBackupReminder') ?? false;  // NEW
    
    // Check daily measurement count
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastResetDate = _prefs.getString('lastResetDate') ?? '';
    
    if (lastResetDate != today) {
      _measurementCount = 0;
      _prefs.setInt('measurementCount', 0);
      _prefs.setString('lastResetDate', today);
    } else {
      _measurementCount = _prefs.getInt('measurementCount') ?? 0;
    }
    
    notifyListeners();
  }
  
  void incrementMeasurementCount() {
    _measurementCount++;
    _prefs.setInt('measurementCount', _measurementCount);
    notifyListeners();
  }
  
  void upgradeToPremium() {
    _isPremium = true;
    _prefs.setBool('isPremium', true);
    notifyListeners();
  }
}