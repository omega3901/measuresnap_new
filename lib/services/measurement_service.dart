// lib/services/measurement_service.dart

import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import '../models/measurement.dart';
import '../models/reference_object.dart';

class MeasurementService extends ChangeNotifier {
  List<Measurement> _measurements = [];
  List<Measurement> get measurements => _measurements;
  
  void addMeasurement(Measurement measurement) {
    _measurements.add(measurement);
    notifyListeners();
  }
  
  void removeMeasurement(String id) {
    _measurements.removeWhere((m) => m.id == id);
    notifyListeners();
  }
  
  double calculateDistance(
    Offset start, 
    Offset end, 
    double pixelToMmRatio,
  ) {
    final distance = (end - start).distance;
    return distance * pixelToMmRatio;
  }
  
  double detectReferenceRatio(
    List<Offset> corners,
    ReferenceObject reference,
  ) {
    if (corners.length != 4) return 0;
    
    // Calculate width (average of top and bottom edges)
    final topWidth = (corners[1] - corners[0]).distance;
    final bottomWidth = (corners[3] - corners[2]).distance;
    final avgWidthPixels = (topWidth + bottomWidth) / 2;
    
    // Calculate height (average of left and right edges)
    final leftHeight = (corners[2] - corners[0]).distance;
    final rightHeight = (corners[3] - corners[1]).distance;
    final avgHeightPixels = (leftHeight + rightHeight) / 2;
    
    // Use width for ratio calculation as it's typically more accurate
    return reference.widthMm / avgWidthPixels;
  }
  
  Map<String, double> autoDetectDimensions(
    List<MeasurementLine> lines,
  ) {
    if (lines.isEmpty) return {};
    
    // Sort lines by length
    final sortedLines = List<MeasurementLine>.from(lines)
      ..sort((a, b) => b.distanceMm.compareTo(a.distanceMm));
    
    // Assume longest lines are primary dimensions
    final dimensions = <String, double>{};
    
    if (sortedLines.isNotEmpty) {
      dimensions['width'] = sortedLines[0].distanceMm;
    }
    if (sortedLines.length > 1) {
      dimensions['height'] = sortedLines[1].distanceMm;
    }
    if (sortedLines.length > 2) {
      dimensions['depth'] = sortedLines[2].distanceMm;
    }
    
    return dimensions;
  }
}