// lib/services/database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/measurement.dart';
import '../models/saved_space.dart';
import '../models/reference_object.dart';

class DatabaseService {
  Database? _database;
  
  Future<void> initialize() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'measuresnap.db');
    
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }
  
  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE measurements (
        id TEXT PRIMARY KEY,
        imagePath TEXT NOT NULL,
        referenceUsed TEXT NOT NULL,
        measurements TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        title TEXT,
        notes TEXT,
        roomDimensions TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE saved_spaces (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        dimensions TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        notes TEXT,
        photoIds TEXT
      )
    ''');
  }
  
  Future<void> saveMeasurement(Measurement measurement) async {
    await _database!.insert(
      'measurements',
      measurement.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<List<Measurement>> getAllMeasurements() async {
    final results = await _database!.query(
      'measurements',
      orderBy: 'createdAt DESC',
    );
    
    return results.map((json) => _measurementFromJson(json)).toList();
  }
  
  Future<void> deleteMeasurement(String id) async {
    await _database!.delete(
      'measurements',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  Future<void> saveSavedSpace(SavedSpace space) async {
    await _database!.insert(
      'saved_spaces',
      _savedSpaceToJson(space),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<List<SavedSpace>> getAllSavedSpaces() async {
    final results = await _database!.query(
      'saved_spaces',
      orderBy: 'createdAt DESC',
    );
    
    return results.map((json) => _savedSpaceFromJson(json)).toList();
  }
  
  Measurement _measurementFromJson(Map<String, dynamic> json) {
    // Convert stored JSON strings back to objects
    final measurementsList = (json['measurements'] as String);
    // Simplified - in production, properly parse JSON
    
    return Measurement(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      referenceUsed: ReferenceObject.standardObjects[0], // Simplified
      measurements: [], // Parse from JSON
      createdAt: DateTime.parse(json['createdAt'] as String),
      title: json['title'] as String?,
      notes: json['notes'] as String?,
    );
  }
  
  Map<String, dynamic> _savedSpaceToJson(SavedSpace space) {
    return {
      'id': space.id,
      'name': space.name,
      'type': space.type.toString(),
      'dimensions': space.dimensions.toString(),
      'createdAt': space.createdAt.toIso8601String(),
      'notes': space.notes,
      'photoIds': space.photoIds?.join(','),
    };
  }
  
  SavedSpace _savedSpaceFromJson(Map<String, dynamic> json) {
    return SavedSpace(
      id: json['id'] as String,
      name: json['name'] as String,
      type: SpaceType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => SpaceType.custom,
      ),
      dimensions: {}, // Parse from JSON
      createdAt: DateTime.parse(json['createdAt'] as String),
      notes: json['notes'] as String?,
      photoIds: json['photoIds']?.toString().split(','),
    );
  }
}