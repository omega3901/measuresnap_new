// lib/models/measurement.dart

import 'package:uuid/uuid.dart';

class Measurement {
  final String id;
  final String imagePath;
  final ReferenceObject referenceUsed;
  final List<MeasurementLine> measurements;
  final DateTime createdAt;
  final String? title;
  final String? notes;
  final Map<String, double>? roomDimensions; // For "Will It Fit"
  
  Measurement({
    String? id,
    required this.imagePath,
    required this.referenceUsed,
    required this.measurements,
    DateTime? createdAt,
    this.title,
    this.notes,
    this.roomDimensions,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'imagePath': imagePath,
    'referenceUsed': referenceUsed.id,
    'measurements': measurements.map((m) => m.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'title': title,
    'notes': notes,
    'roomDimensions': roomDimensions,
  };
  
  double get pixelToMmRatio => measurements.isNotEmpty 
    ? measurements.first.pixelToMmRatio 
    : 1.0;
}

class MeasurementLine {
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double distanceMm;
  final double pixelToMmRatio;
  final String? label;
  
  const MeasurementLine({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.distanceMm,
    required this.pixelToMmRatio,
    this.label,
  });
  
  double get distanceInches => distanceMm / 25.4;
  double get distanceCm => distanceMm / 10;
  double get distanceM => distanceMm / 1000;
  double get distanceFeet => distanceInches / 12;
  
  Map<String, dynamic> toJson() => {
    'startX': startX,
    'startY': startY,
    'endX': endX,
    'endY': endY,
    'distanceMm': distanceMm,
    'pixelToMmRatio': pixelToMmRatio,
    'label': label,
  };
}